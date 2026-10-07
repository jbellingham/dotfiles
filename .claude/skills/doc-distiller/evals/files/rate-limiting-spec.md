# API Rate Limiting — Design Specification

## Background and Motivation

As our platform has grown significantly over the past several months, we have started to see increasing strain on our API infrastructure from both legitimate high-volume users and from occasional bad actors who inadvertently (or occasionally deliberately) hammer our endpoints with rapid-fire requests. This has led to degraded performance for other users and in some cases has caused downstream service failures that have affected reliability metrics.

Rate limiting is a well-established technique in API design that allows us to control the number of requests a given client can make within a specified time window. By implementing rate limiting across our API layer, we can achieve several important goals:

1. Protect our backend services from being overwhelmed by sudden traffic spikes from any single source
2. Ensure fair resource allocation across all users and tenants of the platform, so that one heavy user cannot degrade experience for others
3. Provide clear, structured feedback to API consumers about their usage patterns and limits through standard HTTP response headers
4. Create a foundation for future tiered pricing models where higher-tier customers can be granted higher request limits as part of their subscription

## Approaches Considered

Before arriving at our chosen approach, we evaluated several common rate limiting algorithms. Understanding why we did not choose certain approaches is helpful for context:

**Fixed Window Counter**: The simplest approach. Divide time into fixed windows (e.g. one-minute intervals) and count requests within each window. Simple to implement and understand, but has a well-known edge case where a client can send double their limit in a short burst by making requests right at the boundary of two windows. For example, if the limit is 100/minute, a client could send 100 requests at 11:59 and 100 more at 12:00, sending 200 requests in two seconds. We decided this was not acceptable given our service stability concerns.

**Sliding Log**: Maintain a log of all timestamps for each client's requests. For each incoming request, count how many entries in the log fall within the lookback window. Highly accurate, but memory-intensive since you must store every timestamp. At our scale this would require significantly more Redis memory than we want to allocate.

**Token Bucket**: Each client has a conceptual "bucket" that fills at a constant rate up to a maximum capacity. Each request consumes one token. If the bucket is empty, the request is rejected. This allows for burst traffic up to the bucket capacity while enforcing an average rate. Well understood, used by many large APIs including AWS.

**Sliding Window Counter (hybrid)**: A memory-efficient approximation of the sliding log. Store two counters — one for the current window and one for the previous window — and use a weighted calculation to estimate the count for the actual sliding window. This is the approach used by Cloudflare at massive scale.

After evaluating these options, we have decided to use the **sliding window counter** approach implemented using Redis sorted sets (ZSETs). This gives us accuracy comparable to the sliding log approach with much lower memory overhead, since we store timestamps as ZSET scores and can efficiently remove expired entries.

## Implementation Plan

### Redis Data Structure

We will use one Redis ZSET per user, keyed as `ratelimit:{user_id}:{endpoint_category}`. Each entry in the ZSET will have the request timestamp (Unix milliseconds) as both the member and the score. This allows us to use `ZRANGEBYSCORE` to count requests within any time window efficiently, and `ZREMRANGEBYSCORE` to clean up old entries.

The reason we're using the timestamp as both member and score (rather than a UUID as member) is that it allows the cleanup operation to be a simple score range removal. The slight risk of collision (two requests in the same millisecond) is acceptable given our expected request volumes.

### Rate Limit Tiers

We will implement the following limits, which have been validated against our current traffic patterns:

- **Standard API (all authenticated endpoints)**: 100 requests per minute per user
- **Write operations** (`POST`, `PUT`, `PATCH`, `DELETE`): 10 requests per minute per user (additional constraint on top of the overall limit)
- **Unauthenticated endpoints** (login, register, password reset): 20 requests per 15 minutes per IP address

These limits will be stored in a configuration file at `config/rate_limits.yml` so they can be adjusted without code changes.

### Middleware Integration

Rate limiting will be implemented as a Rack middleware `RateLimitMiddleware` that runs before routing. The middleware will:

1. Extract the user identity (user_id for authenticated requests, IP for unauthenticated)
2. Determine the applicable limit tier based on the request path and method
3. Execute a Lua script on Redis that atomically: removes expired entries, counts remaining entries, and conditionally adds the new request
4. Set standard response headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
5. Return 429 Too Many Requests with a `Retry-After` header if the limit is exceeded

We use a Lua script to ensure the check-and-increment operation is atomic, avoiding race conditions that would exist if we did these as separate Redis commands.

### Response Headers

Following the IETF standard for rate limiting headers (draft-ietf-httpapi-ratelimit-headers), we will expose:
- `RateLimit-Limit: 100` — the limit that applies to this request
- `RateLimit-Remaining: 73` — requests remaining in current window
- `RateLimit-Reset: 1717200060` — Unix timestamp when the window resets

### Testing Approach

We will write unit tests for the Lua script logic directly in Ruby using mock Redis, and integration tests that spin up a real Redis instance. The integration tests will verify the boundary conditions: that the 100th request succeeds, the 101st fails, and that limits reset correctly after the window expires.

## Open Questions

- Should we implement different limits for service accounts vs. human users? Service accounts often have legitimate reasons for higher throughput (e.g. data export jobs). We could add an `is_service_account` flag to the rate limit config.
- How should we handle the case where a user's request fails mid-way (e.g. a 500 error from a downstream service)? Should failed requests count against the limit? Currently we are counting all requests regardless of outcome, which seems safest from an abuse-prevention standpoint but may frustrate users experiencing infrastructure issues.
- Do we need per-endpoint limits beyond the write/read split, or is the two-tier approach sufficient for now?
