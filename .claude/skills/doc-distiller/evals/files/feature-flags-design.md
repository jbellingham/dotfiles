# In-House Feature Flag System — Design Document

## Why We're Building This

Feature flags (also known as feature toggles or feature switches) are a software development technique that allows you to enable or disable functionality in production without deploying new code. They are widely considered a best practice in continuous delivery workflows because they decouple deployment from release. You can deploy code to production with a feature flag disabled, verify the deployment was successful, and then turn the feature on independently — and if something goes wrong, turn it off again just as quickly.

We have been operating without feature flags for the first two years of the product. This has worked fine when the team was small and features were simple, but as we've grown we've run into situations where it would have been valuable to be able to:

- Roll out a new feature to a subset of users for beta testing before general availability
- Quickly disable a feature that is causing production issues without a full deploy
- A/B test different implementations with different user segments
- Enable certain features only for internal team members while still in development

We considered several commercial products: LaunchDarkly, Statsig, and Split.io. LaunchDarkly is the market leader and very capable, but at $400/month for our user count, it's hard to justify for what is essentially a key-value lookup. Statsig and Split.io are similarly priced. We have also looked at the open-source options: Unleash (self-hosted) is mature but requires running and maintaining additional infrastructure. Flagsmith is another solid open-source option.

Given that our feature flag requirements are currently quite simple (boolean on/off and percentage rollouts), we've decided to build a minimal in-house implementation. This gives us full control and avoids a recurring SaaS cost. If our requirements become significantly more complex (e.g. we need complex targeting rules, A/B test analytics integration, or multi-variate flags), we can migrate to a commercial product at that point with the in-house implementation serving as a learning exercise.

## Design

### Storage

Feature flags will be stored in a new `feature_flags` database table with the following schema:

```sql
CREATE TABLE feature_flags (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  enabled     BOOLEAN NOT NULL DEFAULT false,
  rollout_pct SMALLINT NOT NULL DEFAULT 0
                CHECK (rollout_pct BETWEEN 0 AND 100),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

The `name` field is the identifier used in code, e.g. `new_dashboard_ui`. The `rollout_pct` field allows gradual rollouts: when set to 50, approximately 50% of users will see the feature enabled. The percentage assignment is deterministic based on a hash of the user_id and flag name, so the same user always gets the same experience (sticky sessions).

We are deliberately keeping this simple — no user targeting rules, no environment-specific flags, no multivariate support. Those can be added later if needed.

### Caching

Reading from the database on every request would add latency and load. We will cache flag state in Redis with a TTL of 60 seconds. The cache key is `feature_flag:{name}` and the value is the serialised flag record (JSON). When a flag is updated via the admin API, we will explicitly invalidate its cache key.

The 60-second TTL means that flag changes will propagate to all servers within one minute, which is acceptable for our use cases. If we need near-instant propagation in the future (e.g. for emergency killswitches), we can implement a Redis Pub/Sub invalidation mechanism, but we are deferring that complexity for now.

### Evaluation

Flag evaluation will be encapsulated in a `FeatureFlags` module:

```ruby
module FeatureFlags
  def self.enabled?(flag_name, user: nil)
    flag = fetch(flag_name)
    return false unless flag&.enabled

    if flag.rollout_pct == 100
      true
    elsif flag.rollout_pct == 0
      false
    else
      bucket(user&.id, flag_name) < flag.rollout_pct
    end
  end

  private

  def self.bucket(user_id, flag_name)
    Digest::SHA256.hexdigest("#{user_id}:#{flag_name}").hex % 100
  end
end
```

The `bucket` method produces a stable 0–99 value for a given user+flag combination, ensuring consistent user experience across requests.

Usage in application code:
```ruby
if FeatureFlags.enabled?(:new_dashboard_ui, user: current_user)
  render "dashboard/new"
else
  render "dashboard/legacy"
end
```

### Admin API

An internal API at `/internal/flags` (authenticated with the internal API key, not accessible to end users) will allow flag management:

- `GET /internal/flags` — list all flags with current state
- `POST /internal/flags` — create a new flag
- `PATCH /internal/flags/:name` — update `enabled` or `rollout_pct`
- `DELETE /internal/flags/:name` — remove a flag (should only be used once a flag's code has been removed)

We will also build a simple React admin UI at `/admin/flags` for the team to manage flags without needing to use the API directly. This will be a basic table with toggle switches.

### Cleanup Policy

Feature flags accumulate over time if not managed. We will adopt the following policy:
- Flags that have been at 100% rollout for more than 30 days should have their branching code removed and the flag deleted
- Old flags should be reviewed in the monthly engineering retrospective

This is primarily a cultural/process matter rather than a technical one.

## Rollout Plan

1. Create the `feature_flags` table and deploy the migration
2. Implement the `FeatureFlags` module and Redis caching layer with tests
3. Implement the internal admin API with authentication
4. Build the admin UI
5. Migrate the two existing ad-hoc feature flag implementations we have (the `ENABLE_NEW_BILLING` env var and the `admin_users` table hack) to use the new system
6. Document the system in our internal wiki and run a brief team walkthrough

## Open Questions

- Should we support flag evaluation for unauthenticated contexts (e.g. the marketing landing page)? Currently the `enabled?` check gracefully handles `user: nil` by ignoring the rollout percentage (treating it as 0% unless global rollout is 100%). This should be fine for now but we should confirm.
- How should we handle a flag name that doesn't exist? Currently `fetch` returns nil and `enabled?` returns false. Should we raise an error instead to catch typos in development? Probably yes, in development/test mode only.
