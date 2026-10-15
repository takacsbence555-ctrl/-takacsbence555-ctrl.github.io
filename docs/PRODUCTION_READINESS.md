# KAVELYQ — production readiness, 15 October 2026

**Status: functional product checkpoint; NOT production-ready.** The existing vanilla HTML/CSS/JavaScript application, GitHub repository, Supabase database and Vercel project were extended in place. The premium visual identity was retained. No marketing emails, SMS, real customer communications, subscriptions or charges were sent/activated.

Repository: https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io

Production: https://takacsbence555-ctrl-github-io.vercel.app/

## Infrastructure diagnosis

The existing Supabase project was INACTIVE and was restored. Initial probes during recovery temporarily returned no application tables; that diagnosis was superseded when recovery completed. The original tables, RPCs and migration history are present. No original schema or customer records were recreated. The remaining catalog failure was the synthetic Demo Studio's expired trial (10 October), not missing schema. A private, client-inaccessible registry now permits only the registered demo to operate independently of billing. Subscription status and paid-provider fields were not activated.

Vercel uses the existing static project (framework unset, Node 24). Project environment metadata returned no configured variables. Public Supabase configuration remains publishable; no service-role credentials or passwords were embedded in source. The first frontend checkpoint, `ef32efe4b486d3578cb4fedd450b7a6c90390d1b`, was preview-tested, passed GitHub Actions run `38732263235`, and deployed from main as `dpl_2pJffsuKpoYmSUhCiZioxVoafebg` (READY). A preview promotion request failed with 422; main's independent Git deployment succeeded. Later release evidence is recorded below or in the final delivery.

## Implemented and repaired

- Fixed the startup selector error that aborted event initialization and routing.
- Booking uses the existing persisted RPCs, real availability and staff/service durations. Confirmation requires a booking id and valid management token. Missing backend catalog fails closed. Any-barber resolved staff and tenant-scoped drafts survive navigation; expired drafts clear stale times.
- Kept guest booking details and management credentials out of persistent localStorage; guest session state is scoped to the booking business. Added no-referrer and defensive response headers, drawer focus handling and keyboard Tab wrap.
- Restored the existing synthetic booking demo without enabling live billing. Demo policy explicitly states fictional details, no real appointment and no fees.
- A simultaneous real HTTP booking test exposed an exclusion-index deadlock. Added a per-professional transaction advisory lock before validation; the original exclusion constraint remains. Retest returned exactly one HTTP 200 and one HTTP 400 `SLOT_ALREADY_BOOKED`.
- Live owner views no longer fall back to simulated metrics or actions. Unsupported live modules explain their status. Static demo count badges are hidden in live owner mode.
- Added actual day/week/month/date/staff appointment lists via a bounded, timezone-aware calendar RPC, rather than treating a 50-record dashboard snapshot as a complete calendar.
- Added monthly staff/service performance and returning-customer reporting from database records. Completed service value is labelled separately from collected payments.
- Added live customer/contact search, returning/inactive segments, appointment history, consent visibility, notes and existing export/anonymization controls. Corrected CRM snapshot contact/consent fields and exclusion of anonymized customers.
- Added persistent business branding: accent colour, approved typography, HTTPS logo/business imagery and description. Button foreground uses readable contrast. Customisation is confined to the business booking page.
- Added customer/staff/service CSV preview and server validation, duplicate detection in-file and against the current tenant, bounded atomic imports, row errors and explicit commit. Customer marketing consent is always false on import. Staff use the established default weekday setup; services use explicit integer minutes and minor currency units.
- Added explicit timezone/currency to new business onboarding, with owner-boundary validation. UK defaults are Europe/London and GBP. Existing businesses retain their timezone/currency.
- Added owner access-token refresh/retry and server sign-out requests; no claim of full magic-link delivery testing.
- Added tenant-restricted audit metadata for business, staff, services, schedules, CRM, branding and booking mutations. Logs contain entity/record identifiers, actor, operation and timestamp, not copied customer payloads.
- Live intelligence is honestly labelled a rules-based foundation over recorded bookings/CRM. It shows known booked value, missing price snapshots, overdue customers and cancellations, with uncertainty and no invented uplift or completed actions. Customer outreach stays disabled.
- Proposed pricing configuration: Essential £19 / Intelligence £39. Billing remains disabled; these are not activated subscriptions or fully enforced paid entitlements.
- Added pinned regression dependencies and GitHub Actions checks.

## Prioritised issue register

| Priority | Issue | Current state |
|---|---|---|
| P0 | JavaScript startup abort | Fixed and regression-tested |
| P0 | Inactive backend and expired synthetic demo | Restored; catalog and public HTTP checks pass |
| P0 | Booking success without valid backend response | Fixed; negative regression passes |
| P0 | Simultaneous booking deadlock | Fixed; one winner / clean conflict verified by simultaneous HTTP requests |
| P0 | Simulated metrics/actions in live owner workspace | Separated; live values derive from stored records |
| P1 | Staff/service/settings/CRM persistence | Existing lifecycle suite passes inside rollback-only transaction |
| P1 | Tenant isolation | Existing and new feature SQL suites deny an unrelated authenticated identity; full role/HTTP penetration testing remains open |
| P1 | Magic-link delivery, rotated session and logout in an actual browser | Refresh/retry mocked regression passes; controlled test owner/inbox still required |
| P1 | Actual narrow viewport / mobile Safari and touch QA | Not verified with current browser capabilities; release gate |
| P1 | Notification provider and production approvals | Not configured or activated; queued foundation is not delivery |
| P1 | Verified backups, recovery drill and incident alerts | Operational configuration and restore drill still required |
| P1 | Public booking abuse protection | Existing per-contact rate limit remains; broader edge/IP throttling and token abuse review still required |
| P2 | Full AI forecasting / optimisation and attribution | Rules-based foundation only; no connected AI provider or guaranteed uplift |
| P2 | Full waitlist/rebooking/reactivation scheduler | Existing demo/operator foundations only; no production scheduler/delivery activated |
| P2 | Branding image uploads | HTTPS image URLs supported; managed upload/storage workflow not implemented |
| P2 | Import history/undo and competitor-specific mappings | Atomic validated import exists; rich mapping UI and import-history rollback not implemented |
| P2 | Paid plan enforcement and usage metering | Proposed configuration only; billing deliberately disabled |

## Test evidence

Commands: `cd audit && npm ci --ignore-scripts && npm test`, `python3 audit/http.test.py`, syntax checks, and `git diff --check`.

- UI regression: 22 jsdom scenarios (mocked RPCs), including startup, all modules, booking lifecycle, duplicate submission, invalid input, malformed success, backend outage, guest storage, live-data separation, keyboard drawer handling, refresh-token retry, branding save and import preview-before-commit.
- Pure product logic: 12 calendar/timezone/insight/CSV/pricing checks plus 4 branding validation/contrast checks.
- Production HTTP: 10/10 public-access, invalid-input and catalog checks passed after demo repair.
- Existing rollback SQL suite: 12 scenario groups passed: persisted guest lifecycle, overlap rejection, timezone/Sunday/hours validation, owner mutations, CRM, consent, stable historical prices, staff/services/settings and unrelated-tenant denial.
- Added rollback SQL suite: 12 scenario groups passed: persistent branding, validation, authorised import/duplicates/consent, staff/service import, full-range calendar, real performance report, tenant audit metadata, unrelated-tenant denial and UK timezone/currency onboarding.
- True concurrent HTTP requests: before fix one 200 and one 500 deadlock; after fix one 200 and one 400 SLOT_ALREADY_BOOKED. Accepted disposable reservations were cancelled, and the exact synthetic fixtures were removed. An earlier SQL-tool concurrency attempt was inconclusive because the operations did not overlap; it is not counted as a passing concurrency test.
- Database cleanup check after SQL/concurrency QA: zero bookings, zero customers, one existing demo business, zero queued notifications. Rollback-only suites never commit their temporary owner/users or records.
- First preview browser: all 18 Owner demo modules render and carry demo labels; preferences persist after refresh; Back/Forward restores the page. No updated-application script errors were captured.
- Initial production browser checkpoint verified the landing, honest outage state and Owner demo. The final browser booking lifecycle and release status are recorded at delivery.

A passing jsdom test is not a browser E2E test. An SQL test with authenticated role claims is not proof of magic-link delivery or a real browser session. Mobile QA has not passed.

## Security assessment

RLS and explicit RPC grants remain in place. New data APIs use SECURITY INVOKER except the bounded public branding projection and the new-business-only onboarding wrapper, which require privileged access and validate their scope. The staff lock complements the existing database exclusion constraint; it does not replace it. SQL migrations are tracked in the audit directory and in Supabase migration history; do not rerun applied scripts blindly.

Supabase advisors flag the intentional anonymous SECURITY DEFINER booking interfaces and owner SECURITY DEFINER mutators, plus deny-by-default private/rate-limit tables with no client policies. These warnings require review, not a claim of a clean security audit. See [anonymous function guidance](https://supabase.com/docs/guides/database/database-linter?lint=0028_anon_security_definer_function_executable), [authenticated function guidance](https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable) and [RLS policy guidance](https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy).

Remaining work includes complete staff-role tests, real-session verification, external security review, wider booking abuse protection, management-token lifecycle review, retention-job configuration, comprehensive monitoring and verified backups. Keep secrets and backups out of this public repository.

## Operational gates for the first paying shop

1. Provision an authorised test owner and controlled inbox; verify real magic-link delivery, refresh, logout and owner/staff boundaries in the browser.
2. Finish desktop/mobile/touch E2E, including branded booking, admin calendar, CSV import and privacy deletion.
3. Establish daily backups, target RPO 24h / RTO 4h for the pilot, and complete a restore drill into an isolated environment. These are targets, not verified guarantees.
4. Configure error/uptime alerts and a documented support/incident owner.
5. Connect approved email/SMS providers and verified domains only when authorised; test consent/opt-out, bounded retries and reminders with controlled recipients. Do not infer marketing consent from a customer import.
6. Complete waitlist/reactivation scheduling, import-history rollback and required legal/retention settings for the pilot country.
7. Validate the proposed £19/£39 economics and entitlements; obtain separate explicit approval before live billing.

Rollback: previous application checkpoint is retained in Vercel; revert commits or use deployment rollback. Database changes are additive, apart from scoped function repairs. Remove the demo registry entry to restore its previous entitlement behaviour; revert the staff-validation function from migration history if necessary while retaining the exclusion constraint. Back up data before rolling back new feature tables; never drop customer data to roll back a UI change.
