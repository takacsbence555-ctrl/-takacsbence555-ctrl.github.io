# Recovered KAVELYQ backlog

Recovery sources: current conversation and saved personal context, all nine GitHub branch heads, PRs #1–#7 and their states, recent commit history, source, audit scripts and live Supabase/Vercel metadata. Complete transcripts of every earlier Work session are not available. Requirements without a recoverable implementation or test are explicitly unverified rather than assumed complete.

At reconciliation, main was f5c04ffa; production dpl_8mcuNAA6Kij18tKcEGRCU7PAXHbK was READY. Readiness branch d3a0d868 had unmerged persistent features; PR #3 had unmerged privileged-RPC tests. PRs #1, #2 and #4–#7 were merged. All prior branches were retained.

| Requirement / issue | Recovered state | Required completion / evidence |
|---|---|---|
| Premium UI, English default, map, fixed booking navigation | Existing implementation, repeated earlier click failures | Regressions and deployed browser tests; preserve visual identity |
| Guest service/staff/date/time/review/confirmation | Persisted API plus newer unmerged safeguards | Integrate safeguards; browser lifecycle and database confirmation |
| Any professional, staff schedules/durations, holidays/breaks | Existing availability/blocked-time backend | Validate non-barber services and concurrent attempts |
| Manage, reschedule, cancel | Existing secure-token RPCs | Production browser plus SQL lifecycle |
| Duplicate submissions / concurrent writes | Lock fix applied in DB; script only on readiness branch | Carry source history and rerun HTTP concurrency evidence |
| Refresh/back/forward/draft expiry | Readiness implementation | Preserve tenant scoping and test routes |
| Owner authentication | Magic links; unmerged refresh/logout | Integrate; actual owner/inbox E2E remains unverified |
| Customer authentication | Guest management tokens; Apple/Google explicitly disconnected | Keep guest booking functional; do not imply social auth works |
| Calendar day/week/month/staff | Main uses loaded snapshot; readiness has date-range RPC/UI | Integrate full-range implementation and retest |
| CRM/history/notes/search/segments/consent/export/deletion | Existing backend plus unmerged contact/history fixes | Integrate and test persistence/tenant denial |
| Staff/services/prices/assignments/hours/time off/settings | Existing admin RPCs/editors | Keep working editors; lifecycle and role checks |
| Revenue, retention, staff/service reports | Persistent report implemented but frontend unmerged | Integrate; distinguish service value from collected payments |
| Branding/logo/colours/fonts/images/description | DB changes exist; UI and migrations only on readiness | Merge, validate URLs/contrast/persistence |
| CSV migration of staff/services/customers | Main placeholder; readiness atomic preview/commit exists | Merge, duplicates/consent/errors/role verification |
| Business timezone/currency | Readiness onboarding wrapper; industry wrapper on main omits these | Combine without losing industry selection |
| Multi-industry onboarding/profile | Main partially implemented; tattoo still offered | Five allowed industries; postpone tattoo |
| Multi-industry public booking | Main swaps static preview DOM without integrating controllers | Use the same persisted booking engine with actual industry catalog |
| AI operator/forecast/reactivation/waitlist/rebooking | Honest rules foundation, other pages illustrative | Operational persisted recommendations/approvals; no invented outcomes |
| Reminders/cancellation/notification queue | Existing delivery queue foundations | Provider/scheduler/consent/opt-out verification; no unauthorised sends |
| Waitlist / rebooking | Demo/local and operator foundations | Persist matching preferences and safe owner-reviewed actions |
| RBAC/RLS/RPC/tenant isolation | Representative SQL tests; PR #3 not run live | Merge/run security tests, inspect elevated grants and role boundaries |
| Audit logging | New metadata-only DB trigger; source only readiness | Carry migration and test tenant-read controls |
| Mobile/touch/accessibility/performance | Desktop partial; mobile unverified | Browser/device capability limits recorded; no false pass |
| Billing £19/£39/no commission | Proposed config only | Remain disabled; no provider subscriptions/charges |
| Backups/recovery/monitoring/retention | Strategy recorded; no restore drill or alerts verified | Operational release gates; do not label ready |
| Managed branding upload and import undo/mapping | Not implemented | Track separately from implemented URL branding and atomic import |

Critical integration debt: backend and frontend branches drifted. READY deployments did not imply all requested code was in main. Initial no-schema finding was transient during Supabase restoration and has been superseded; do not rebuild the database.

Marketing outreach, domain purchasing, live billing and tattoo-specific features are outside this completion scope. Do not send marketing emails.

## Integrated verification checkpoint — 15 October 2026

Integrated readiness branch and all merged multi-industry work. Persisted five industry catalogs, shared booking routing, industry/timezone/currency onboarding, waitlist with private withdrawal, rules-based forecast and consent-aware prepare/approve decisions implemented. Owner-only mutation/export/intelligence guards added; customer-facing delivery remains disabled.

Executed: 25 jsdom UI scenarios, 16 product/branding checks, 15 live HTTP security/API checks, 12 original database scenario groups, 12 extension groups, and 6 industry/intelligence/RBAC groups. SQL suites rolled back their fixtures. True simultaneous HTTP booking attempts previously produced one success and one SLOT_ALREADY_BOOKED after the staff lock fix; the original deadlock was resolved. GitHub workflow 38804451629 passed for 13b3152f.

Preview browser: five industry catalogs; Beauty service → any professional → future slot → synthetic phone-only booking confirmed; direct database read confirmed price/duration/timezone persistence; refresh → private manager → reschedule → database confirmation → cancel → database confirmation. Waitlist save → private link → withdrawal confirmed in database. The run exposed stale guest confirmation time/status and an industry-button startup race; both fixed, with regression assertions. Preview build READY is checked separately from functional verification.

### Remaining release gates / limitations

- Full earlier Work transcripts unavailable; recovery is based on nine branches, seven PRs, source, saved context and infrastructure records.
- Actual owner magic-link delivery, signup and browser login require a controlled owner account/inbox and configured authentication delivery; SQL-authenticated role tests and token-refresh simulations are not equivalent.
- Real mobile viewport/touch, screen-reader, full keyboard audit and device matrix remain unverified; current cloud browser exposes no viewport control. Desktop DOM tests do not satisfy mobile QA.
- Outbound communication provider/sender, scheduler, opt-out delivery and country-specific campaign requirements have not been operationally verified. No customer messages were sent. Approved drafts do not dispatch.
- No connected generative AI. Operator is explicitly rules-based; forecasts are service-value heuristics with uncertainty, not guaranteed revenue or cash collection.
- Payments, subscription activation and live billing disabled. No payment collection or commission enabled. Financial reconciliation/refunds are outside recorded-service reporting.
- Backup retention/PITR entitlement, actual restore drill, production error alerting, load testing and disaster recovery remain operational gates. Database restoration during this work is not a tested backup recovery procedure.
- Branding accepts validated HTTPS image URLs; managed upload library is absent. CSV imports use fixed documented columns; no arbitrary competitor mapping or undo workflow.
- Non-core illustrative modules (inventory, simulator, goals, multi-location operations and some automation demonstrations) remain demo-only or explicitly unavailable in live mode. Do not equate these with implemented business operations.
- Public demonstration bookings use fictional contacts and the real persistence engine. Five catalogs have no real customers or paid subscriptions. Disposable QA lifecycle records are identified by QA names and test phone numbers.
- Tattoo remains postponed. Legacy backend type is retained for compatibility but is absent from new onboarding.

KAVELYQ must not yet be labelled production-ready. First-paying-business onboarding requires closing the identity/delivery, mobile/accessibility, recovery/monitoring and operational privacy gates above, followed by a controlled pilot.

## Production evidence and final security follow-up

PR #8 merged as 5e8e411e2ebda0d6ca6ab8f48f833935d22821df. Vercel production deployment dpl_5FBbgnqCAR666AcNDHFnLV3ZT3kS was independently confirmed READY on that exact commit. Checks 38805646077 and 38805653327 passed for tested head 9d806c42.

Production browser verified the Nails catalog, service/professional/date/time/review, a persisted synthetic booking and refresh, then rescheduling. Independent DB reads confirmed £35, 45-minute duration and London timezone conversion, followed by the rescheduled date/time. Browser transport disconnected before final production cancellation could be verified in the UI; cancellation was completed through the existing booking RPC and DB read confirmed cancelled. Preview browser cancellation and restored cancelled summary passed. Do not report the disconnected browser step as passed. A repeat shell HTTP run was interrupted by transport/network approval cancellation; the earlier 15/15 live HTTP run remains the completed evidence.

Supabase security advisor returned warnings for intentionally exposed guest SECURITY DEFINER RPCs and authenticated definer RPCs, plus informational notices for two deny-all RLS internal tables. These require threat review, not blind revocation that breaks guest booking. Guidance: https://supabase.com/docs/guides/database/database-linter?lint=0028_anon_security_definer_function_executable and https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable . No clean security certification is claimed.

Follow-up inspection found owner_setup_snapshot and owner_subscription_snapshot still accepted same-tenant staff. Applied owner-snapshot-role-boundary.sql: both now limit reads to owners/managers. Removed obsolete €49/€490 pricing from the snapshot in favour of explicitly provisional £19/£39 values and live_billing_enabled=false. Executed snapshot-roles.test.sql: staff reads return null, owner setup remains available, proposed pricing matches and billing remains disabled; fixtures rolled back.

Rollback: retain prior main/Vercel deployments and readiness/completion branches. Application rollback can target the previous confirmed deployment. Keep additive database migrations and security guards; do not drop tables or undo data while rolling back frontend assets. The two cancelled QA bookings and withdrawn QA waitlist request contain fictional data only.

Additional rollback-only onboarding test passed for all five business types: persisted business_type, Europe/London timezone and GBP currency were asserted for each new business; all users/businesses rolled back. This is API/database verification, not a completed real email/signup browser journey.

## Final production-completion pass

Observed baseline main/production: 81edb461569b0eb8d80cde8873f298219c903c9f, confirmed unchanged at start. PRs #1–#9 reviewed; #3 is superseded and closed. Changes for this pass are in PR #10.

### Reproduced and fixed

- Staff could modify service prices directly under legacy membership-only RLS. Client roles also held dangerous TRUNCATE/TRIGGER/REFERENCES grants. Reproduced with rollback-only fixtures; replaced policies with owner/manager checks and revoked anonymous table access and dangerous grants. Owner operations and guest RPCs retained.
- Notification claims tried to use processing despite a status constraint that prohibited it. Fixed state validation and fail-closed provider activation; retry/backoff/stale-claim/max-attempt tests pass without any real messages.
- Rescheduling left stale reminders queued. Updated queue handling and excluded marketing templates from transactional delivery claims.
- Customer erasure omitted queued/waitlist contact information. Export and erasure now cover associated records; management tokens are excluded from exports and revoked on erasure.
- Owner OTP calls used an ignored body redirect field. Corrected redirect_to query semantics for signup and login, added request-contract tests, cancellation, form validation and duplicate-submit handling. Actual received-email E2E remains blocked.
- Time off could overlap existing bookings. Added database-trigger validation using the same staff lock as booking creation, tested rejection, availability and removal.
- Time-off form values were interpreted as server timestamps. Added business-local conversion and tested BST/GMT plus invalid spring-forward wall times. Form labels and displayed absence times use the business timezone.
- Mobile operator action controls overflowed. Corrected action stacking and wrapped headers. Automated contrast failures on booking labels were repaired without changing the visual identity.
- Added CSP, repeatable real browser CI and read-only scheduled production smoke checks. Browser CI mirrors Vercel security headers before release and targets the production URL on main.

### Evidence checkpoint

Local UI regression: 30 scenarios passed. Product/branding: 16 checks passed. Four original database suites rerun successfully after permission/scheduling changes (30 named scenario groups plus snapshot/onboarding assertions). New direct-table permissions, notification retries/privacy, time-off conflicts and local-time DST suites pass with rolled-back fixtures. Additional owner delivery-status role assertions passed.

Real browser run 38820762380 passed all 18 cases: desktop Chromium and touch-enabled mobile WebKit, five catalogs, persistent booking/refresh/reschedule/cancel, history/validation, waitlist withdrawal, unavailable-network handling, demo navigation/invalid login, invalid references, anonymous denial, WCAG 2.1 AA booking scan and simultaneous slot attempts. Later source/security-header changes must pass their own required checks before merge.

Synthetic CI bookings are cancelled in finally blocks and database checks confirm no active QA appointments. No customer notifications, real charges, paid resources or real account deletions occurred.

### Remaining gates

- P0: Controlled test inbox and actual auth session are still required. Production contains zero auth users; Owner email/signup/login and authenticated Owner desktop/mobile E2E remain unverified.
- P2: Verified notification provider/worker, approved test delivery and delivery webhooks remain absent. Default claim eligibility is disabled for every business.
- Recovery: Free-plan project; no actual off-site backup/isolated restore drill was available. Secure database credentials, backup storage and a restore target are needed.
- Monitoring: Read-only smoke workflow exists; external client-error alerting and log drains remain absent. Empty Function logs do not certify a static frontend.
- Physical mobile devices, manual screen-reader testing, full Owner accessibility and capacity/load testing remain unverified.
- Existing non-core demonstration modules remain illustrative or unavailable in live mode; they are not completed business operations. Generative AI and live billing remain unconnected/disabled.

Release recommendation remains NOT READY until the P0 identity/Owner E2E gate and remaining operational requirements are closed. See docs/OPERATIONS_RUNBOOK.md for concrete prerequisites and safe procedures.
