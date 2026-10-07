# Soft Deletes for the Users Table — Migration Plan

## Overview and Context

Currently, when a user account is deleted in our system, the corresponding row in the `users` table is hard-deleted using a simple `DELETE` SQL statement. This is the simplest possible approach and works fine in many cases, but we have run into several practical problems with it that have prompted this design work:

**Referential integrity issues**: We have foreign keys in several tables (notably `audit_logs`, `billing_records`, and `session_tokens`) that reference `users.id`. When we hard-delete a user, we either need to cascade delete all of this associated data — which may be legally problematic given GDPR retention requirements for billing records — or set the FK to null, which loses the association. Neither is great.

**Regulatory requirements**: Our legal team has advised that billing and transaction records must be retained for seven years under applicable tax law, even if the user has requested account deletion. This means we cannot simply cascade delete all related records, but we also need to ensure the user data itself is not accessible through the normal application interface.

**Audit trail gaps**: Support team has repeatedly asked for the ability to look up recently-deleted accounts to investigate reports. With hard deletion, this is impossible. Data has to be restored from backups, which is slow and expensive.

**Accidental deletions**: We have had two incidents in the past year where user accounts were accidentally deleted due to bugs. Recovery required database backup restoration, taking significant engineering time.

Soft deletes are a well-known pattern in database design where instead of actually removing a row from the table, you set a flag or timestamp indicating the row is "deleted". All queries that retrieve active records add a `WHERE deleted_at IS NULL` clause. The row remains in the database, preserving referential integrity and allowing recovery, but is invisible to normal application queries.

## Approaches Considered

There are a few ways to implement soft deletes at the database/application layer:

**Boolean flag (`is_deleted`)**: Simple boolean field. The main disadvantage is you lose the timestamp of when the deletion occurred, which has forensic and compliance value. We are not considering this approach.

**Timestamp field (`deleted_at`)**: Nullable timestamp. NULL means active, non-null means deleted with the time of deletion recorded. This is the most common approach. Allows range queries ("show me all accounts deleted in the last 30 days"). This is our chosen approach.

**Separate "deleted" table**: Move deleted rows to a `deleted_users` table instead of marking them in place. Keeps the main table clean, easier to query without worrying about filters. Downsides: more complex migrations, foreign keys in other tables still reference the original `users` table, and you need to handle the case of a user being un-deleted (would require moving back). Not worth the complexity.

**Paranoia gem (Rails)**: The `paranoia` gem auto-adds `deleted_at` scoping to all ActiveRecord queries. Convenient but introduces implicit magic that can cause hard-to-debug issues, particularly with `unscoped` queries. We have had bad experiences with this gem before. We will implement soft deletes manually to keep the behavior explicit.

## Chosen Approach: Manual `deleted_at` + `deleted_by`

We will add two new columns to the `users` table:

- `deleted_at TIMESTAMPTZ` — nullable; set to the current UTC time when the user is deleted
- `deleted_by UUID` — nullable FK to `users.id`; records which user (or which admin) performed the deletion

The `deleted_by` column is important for our compliance requirements and the audit trail. It tells us whether this was a self-deletion (user_id = deleted_by) or an admin action.

## Migration Strategy

The migration must be zero-downtime because we deploy continuously. The three-step approach:

**Step 1 — Add nullable columns** (deploy immediately, safe):
```sql
ALTER TABLE users
  ADD COLUMN deleted_at TIMESTAMPTZ,
  ADD COLUMN deleted_by UUID REFERENCES users(id);

CREATE INDEX CONCURRENTLY idx_users_deleted_at
  ON users(deleted_at)
  WHERE deleted_at IS NOT NULL;
```

Using `CONCURRENTLY` on the index creation is important — without it, this takes an `ACCESS SHARE` lock that blocks writes for potentially several minutes on a large table.

**Step 2 — Update application code** (deploy before Step 3):
- Add `WHERE deleted_at IS NULL` to all queries that retrieve active users. In our Rails app this means adding a default scope to the `User` model and auditing every place we use `User.unscoped`.
- Change the `UserDeletionService#delete!` method to set `deleted_at = Time.current` and `deleted_by = acting_user.id` instead of calling `user.destroy`.
- Update the admin interface to show soft-deleted users in a separate "Deleted accounts" view with a restore button.

**Step 3 — Remove old hard-delete code paths** (deploy after Step 2 is stable):
- Remove the `destroy` calls that bypass soft-delete
- Add a database-level trigger or Rails callback to prevent hard deletes as a safety net

## Index Considerations

Beyond the partial index on `deleted_at`, we should review whether existing indexes need updating. The `idx_users_email` unique index currently enforces email uniqueness across all users including deleted ones. This means a user cannot re-register with an email address that was previously used by a deleted account. We need to decide:

- **Option A**: Keep unique constraint across all records, including deleted. Simplest. Means deleted email addresses are permanently unavailable. Acceptable for our current user base.
- **Option B**: Change to a partial unique index: `CREATE UNIQUE INDEX ON users(email) WHERE deleted_at IS NULL`. Allows re-registration with previously-used emails after deletion. More complex.

We propose going with Option A for now and revisiting if user complaints surface.

## Open Questions

- What do we do with `session_tokens` for soft-deleted users? They should be invalidated immediately on deletion. Current plan: the `UserDeletionService` explicitly invalidates all active sessions as part of the deletion transaction. Is there a race condition here we need to worry about?
- Should we implement automatic hard-deletion of users deleted more than 7 years ago (for GDPR minimisation)? Defer to a follow-up — legal needs to confirm the retention period and what "deletion" means for billing records that reference the user.
