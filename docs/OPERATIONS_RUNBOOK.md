# KAVELYQ operations and remaining release gates

## Release rule

Do not label the platform production-ready until real Owner authentication and authenticated desktop/mobile management journeys pass, notification infrastructure is configured and verified with an approved test inbox, and recoverable off-site backups have passed an isolated restore drill. Never enable live billing as part of testing.

## Identity and first-business onboarding

The inspected production database has zero auth users and zero non-demo businesses. No account/inbox was invented or borrowed for authentication tests.

1. Obtain an explicitly authorised test inbox. Configure Supabase Auth sender/SMTP and allowlist the production origin and onboarding redirect. Do not paste secrets into chat or source control.
2. Start the trial using that inbox. Verify the received magic link redirects to the existing app with new_business=1. Existing-owner login uses view=hq. GoTrue requests must use the redirect_to query parameter.
3. Complete signup for each of the five supported industries in a controlled test workflow. Verify the returned business_id, stored type, timezone/currency and tenant membership. The rollback-only database tests already cover industry persistence; they are not email-delivery E2E evidence.
4. Exercise Calendar, CRM, staff, services, settings, refresh, logout and expired-session recovery using actual signed sessions. Verify a second authorised business cannot access the first.
5. Keep credentials in the provider's secure configuration or protected CI secrets, never test reports or screenshots. Browser traces and videos are disabled.

## Notifications

No Edge Functions were deployed and no communication provider is activated. Every business defaults to disabled delivery.

The private communication_delivery table is admin-only. Claiming requires both transactional_enabled and provider_verified; demo businesses and marketing templates are excluded. Do not flip these flags merely to make a test pass.

The database queue now permits processing, caps attempts at five, waits ten minutes before failed-job retries and recovers stale processing claims after fifteen minutes. Claims older than 24 hours are excluded. Queue status sent is not independent proof that an email reached an inbox. A production worker still needs verified sender credentials, provider idempotency keys, delivery webhooks, suppression handling and an approved test recipient before activation.

Rescheduling cancels stale pending/failed/processing jobs and queues updated transactional payloads. Customer-facing rebooking/reactivation and approved decision drafts do not dispatch.

## Monitoring

Production smoke CI checks the public shell, referrer/framing headers and fifteen anonymous/API checks. The workflow is configured every 30 minutes and on main pushes; cron execution is subject to GitHub scheduling and is not an uptime SLA.

Vercel has no configured log drains. A recent runtime-error query returned no records, but this static frontend does not emit browser failures into Vercel Function logs. The browser regression checks and provider/database logs are separate evidence; external browser-error alerting remains unconfigured.

Owner notification status displays actual queue counters and whether delivery is enabled. It cannot certify delivery.

## Privacy and account lifecycle

Owner/manager access is enforced by RPCs and direct-table policies. Customer exports include associated appointments, notes, notification metadata, outreach and matching waitlist requests. Bearer management tokens are excluded.

The explicit customer-erasure workflow clears contact data, notes and queued payloads, withdraws matching waitlist requests, cancels related draft decisions and invalidates appointment-management tokens. Rollback-only tests verify the affected tables. Backups and future third-party provider records need their own documented retention/deletion handling.

Business-account closure, deletion of actual auth users and verification of revocation across real sessions remain unverified until controlled identity tests are available. Do not remove real accounts or restore a production database without separate approval.

## Backup and recovery

The connected Supabase organisation is on the Free plan. The integration exposes no backup download/restore operation. Supabase recommends regular manual CLI exports and off-site backups for Free projects:
https://supabase.com/docs/guides/platform/backups

Required inputs: securely configured database connection credentials, private encrypted/off-site backup storage, a retention/RPO/RTO decision and a disposable restore target. Do not infer recoverability from a healthy database or from Git source history.

Suggested drill after provisioning:
1. Create a consistent database dump with the documented Supabase CLI/pg_dump workflow; include roles, schema and data according to current provider guidance.
2. Encrypt and store it off-site; record timestamp, checksum and retention.
3. Restore only into an isolated disposable target. Never overwrite production for a drill.
4. Verify row counts, constraints, RLS, membership boundaries, booking exclusion/locking and representative application journeys.
5. Record restore duration and measured data-loss window, then require approval before destroying the drill target.

The isolated CI workflow implements this drill using only synthetic application/Auth records. Its result is recorded in recovery-result.json when that step passes. This is not evidence that a hosted production backup exists. No paid plan, PITR upgrade or new paid resource was activated.

## Rollback

Retain the prior confirmed deployment and main commit 81edb461569b0eb8d80cde8873f298219c903c9f. Revert frontend commits or restore that deployment if necessary, then verify the public URL and commit. Keep the restrictive database grants/policies and additive queue fixes; do not reintroduce dangerous client privileges or drop customer data as part of an application rollback.

## Security advisor notices

INFO notices on private/admin-only tables with deny-all RLS are intentional. Public guest SECURITY DEFINER RPC warnings and authenticated privileged RPC warnings require function-by-function review, not blanket public-table grants. Owner-only erasure and delivery-status functions explicitly check tenant ownership. Dangerous client TRUNCATE/TRIGGER/REFERENCES grants were removed and tested.

Remediation reference:
https://supabase.com/docs/guides/database/database-linter?lint=0028_anon_security_definer_function_executable

Automated checks are evidence of tested paths, not a comprehensive penetration-test certification.


## Pending PR #10 release changes (not deployed)

Keep automatic Vercel deployment disabled for release/final-20261015. Do not merge or deploy until required checks and release approval are satisfied. Preserve production commit 81edb461569b0eb8d80cde8873f298219c903c9f for rollback.

The form refresh fix locks setup controls until mutation and both setup/dashboard reads finish. Weekly hours remain business-local SQL `time without time zone`; the atomic owner_set_staff_week_hours RPC never converts them to UTC. Apply audit/owner-atomic-hours.pending.sql before releasing the frontend that calls it. It adds an owner-checked, authenticated-only transaction that validates the entire week before writing. A failed week cannot partially persist. Existing RPCs remain available for rollback.

The notification adapter in server/notifications.cjs is disabled by default and has no deployed route or scheduler. audit/notification-adapter.pending.sql adds service-role-only acknowledgement/webhook/lease functions, private delivery-event records and per-business hashed suppression records, and corrects modern JWT role lookup in legacy acknowledgements. Apply only during an authorised coordinated release, after checking deployed schema compatibility. Keep service credentials in secure server configuration; never expose them to the static frontend. Require an approved recipient allowlist, verified sender, signature-verified webhook and durable event ledger before enabling delivery. Provider acceptance and final delivery are distinct states.

CI notification integration uses an explicit loopback provider contract server, not the actual Resend service. It covers a real database queue, 429 backoff/retry, stable provider idempotency, stale leases, signature verification, durable duplicate events, bounces and suppression. To verify Resend at zero purchase cost, the owner must approve a permitted test sender and controlled recipient (or Resend simulator address) and configure existing credentials securely. A custom production sender needs a verified domain; no domain has been purchased or sender activated here.

For a hosted backup drill at zero additional infrastructure cost, securely provide a read/export-capable database connection, an encryption public certificate (retain the private key outside CI), existing private off-site storage, and agree retention/RPO/RTO. Restore only into the disposable local Docker target; never restore over production. Supabase Storage object bytes and project configuration are separate recovery assets and are not included in pg_dump. Do not publish dumps or decryption keys as GitHub artifacts. Pending migrations must be included in schema review and future recovery manifests.
