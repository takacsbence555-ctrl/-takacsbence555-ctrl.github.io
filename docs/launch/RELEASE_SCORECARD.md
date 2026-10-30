# KAVELYQ release scorecard

Preparation checkpoint, 30 October 2026. Recommendation: **NOT READY** for a live customer pilot or public paid launch. Safe synthetic evaluation can continue. This scorecard distinguishes candidate test evidence from hosted operation. The exact final commit's Actions results are recorded in PR #10; an older green run is not a release approval.

Status meanings: PASS = evidence supports the stated scope; FAIL = known current gap; BLOCKED = verification/activation needs access, configuration or approval. Categories: 1 = safe engineering completed/automatable; 2 = operator approval/account setup; 3 = conditional spending; 4 = optional improvement. No provider purchase, company registration, email campaign, payment activation, merge, production deployment or hosted migration was performed.

| Critical area | Closed pilot | Public paid | Evidence / remaining gate | Category |
|---|---|---|---|---|
| Guest booking, manage, reschedule, cancellation | PASS | PASS | Desktop/mobile candidate suite exercises persisted synthetic demo bookings and concurrent conflicts; release still needs controlled deployed-candidate verification | 1 / 2 |
| Owner Calendar, CRM, staff, services, settings, branding, import, industries | PASS | PASS | Actual isolated signed-owner journeys, not mocked persistence; salon production records not exercised | 1 |
| Real iPhone/Safari Owner sign-in | BLOCKED | BLOCKED | Callback/provisioning fixes are in PR; production still runs old commit; controlled hosted email and physical-iPhone verification require approval | 2 |
| First-time versus existing Owner routing | PASS | PASS | Real local magic links opened in fresh browser contexts without shared storage or redirect intent; identity and membership checked | 1 |
| Session refresh/logout/expired links | BLOCKED | BLOCKED | Local regression and signed-isolated coverage exist; final full CI and hosted Safari verification required; sessionStorage is browser/tab scoped | 1 / 2 |
| Tenant isolation and staff permissions | PASS | PASS | Two signed isolated owners and staff-role escalation tests; this does not replace current hosted permissions review | 1 |
| Current hosted schema, RLS, advisors and migration history | PASS | PASS | Connection recovered: 70 migrations reviewed, required functions present, all 81 application/private function definitions match the isolated fixture, 18 tenant-scoped policies reviewed, public RLS enabled and dangerous client grants absent. Advisor residuals documented below | 1 |
| Booking conflicts, local time and DST | PASS | PASS | Concurrent synthetic guest attempts; database exclusion; three session timezones, winter/summer offsets, DST gap rejection and atomic invalid-week rollback | 1 |
| Pending migration compatibility/application | BLOCKED | BLOCKED | Hosted base signatures/source and legacy role patch compatibility checked; both additions absent as expected. Backup and explicit hosted migration approval still required | 2 |
| Released candidate and rollback verification | FAIL | FAIL | Production independently remains 81edb461569b0eb8d80cde8873f298219c903c9f; no release authorised | 2 |
| Dependencies and source credential patterns | PASS | PASS | Both npm audit trees reported zero vulnerabilities; pinned manifests/locks and source/deployment guards; not a full penetration test | 1 |
| Desktop/mobile accessibility and layout | PASS | PASS | Chromium and touch WebKit workflows and module WCAG scans; physical devices/manual screen-reader review remains additional evidence | 1 / 4 |
| Notification foundation | PASS | PASS | Native worker/webhook entry points prepared with default-off controls; local queue/provider-contract tests cover retries, idempotency, stale leases, signed webhooks, suppression and duplicates | 1 |
| Actual Auth SMTP / external Owner delivery | BLOCKED | BLOCKED | Own-account delivery does not prove external owners; built-in SMTP is restricted testing infrastructure; inspect actual SMTP configuration | 2 / 3 |
| Automated customer notification delivery | PASS | BLOCKED | Pilot can explicitly use salon-managed communication with automation disabled; public automated service needs approved deployment/configuration of the prepared routes, a verified sender, webhook and real provider evidence | 2 / 3 |
| Encrypted synthetic recovery drill | PASS | PASS | 47-table disposable backup/restoration, integrity/authenticated encryption, restored RLS and grant-tampering checks; never a production restore | 1 |
| Hosted off-site backup and measured recovery | BLOCKED | BLOCKED | Secure export access, owner-held keys, existing private storage and approved drill required; source/config/storage asset coverage must be checked | 2 |
| Active scheduled monitoring and alert routing | FAIL | FAIL | Smoke workflow absent from main; no scheduled runs; Vercel log drains empty; PR-only cron is not operational monitoring | 2 |
| Pilot incident owner/support channel | BLOCKED | BLOCKED | Runbook drafted; operator must name contact/hours and test incident routing; manual staffed review may suffice for a tiny supervised pilot | 2 |
| Export, customer anonymisation and consent | PASS | PASS | Isolated CRM lifecycle and existing privacy regression tests; no real customer erased during preparation | 1 |
| Business closure, retention/deletion jobs and backup erasure | BLOCKED | BLOCKED | Procedures drafted; periods and requests/contact authority need approval; no deployed retention job or full hosted account-closure proof | 2 |
| Approved privacy, terms, DPA, identity and tax/legal obligations | BLOCKED | BLOCKED | Draft review pack complete; no policy activated or legal entity invented | 2 / 3 |
| Hosting commercial eligibility | BLOCKED | BLOCKED | Connected tools do not expose plan; Hobby excludes commercial use. Confirm existing eligible plan or written eligibility; do not assume a free pilot is exempt | 2 / 3 |
| Limited pilot access | BLOCKED | BLOCKED | Public signup currently enabled. Review users and configure approved invitation-only Auth onboarding; an unlisted URL is not enforcement | 2 |
| Billing and paid entitlements | PASS | FAIL | Disabled billing is correct for a free pilot; payment integration, tax/invoices, entitlement/usage enforcement and payment lifecycle tests needed before sale | 2 |
| Rules-based intelligence / outreach approvals | PASS | PASS | Accurately labelled recorded-data foundation with internal approvals; no connected generative AI, guaranteed uplift or automatic customer outreach | 1 |
| Broad load tests, SSO/MFA expansion, advanced telemetry | BLOCKED | BLOCKED | Can follow a tightly bounded pilot after a risk/limits decision; not claimed implemented; public scale requires capacity evidence | 4 |

| Password policy / leaked-password warning | BLOCKED | BLOCKED | One existing confirmed Auth account has a password credential. Review password strength and restricted signup before pilot; leaked-password protection is disabled and is a paid Pro feature. Do not infer compromise or buy an upgrade | 2 / 3 |
| Broader booking abuse controls | BLOCKED | BLOCKED | Per-contact limits exist; approve bounded pilot monitoring and review broader IP/edge controls before public scale. No CAPTCHA/provider or paid firewall rule activated | 2 / 4 |

## Current hosted security and operational findings

Read-only access recovered during this session. There is one confirmed Auth account, no business memberships/non-demo businesses, and zero enabled delivery configurations. First-time business onboarding is therefore needed; an Auth account alone is not a provisioned salon workspace. No user identity, password hash, token or customer row was retrieved.

Security advisor: 3 INFO deny-all tables; 10 WARN anonymous SECURITY DEFINER APIs; 27 WARN authenticated SECURITY DEFINER APIs; 1 WARN leaked-password protection. The 37 execution-surface findings correspond to intentional guest capabilities and provisioning/Owner functions. All 81 base function definitions match the exercised fixture; policy predicates were reviewed for tenant ownership. This is scoped evidence, not a penetration-test certification, and execution grants must not be revoked blindly to silence warnings.

The leaked-password warning remains unresolved. The UI uses magic links, but the hosted account has a password credential, so the warning is not dismissed as irrelevant. A strong unique password/password-policy review and curated signup are zero-cost mitigations requiring account approval; paid leaked-password checking remains outside the €0 budget. No password was read, reset or changed. Reference: https://supabase.com/docs/guides/auth/password-security .

Performance advisor: 2 INFO unindexed foreign keys and 25 INFO unused indexes. Review against actual workload later; do not drop indexes from low-traffic statistics or apply hosted DDL without approval. The sampled 24-hour edge log window contained two Data API 502 responses; current smoke/browser checks pass, but this does not establish uptime or explain those historical responses. Active alerts and incident correlation remain operational gates. Only status/source aggregates were inspected, without URLs, IPs, emails or raw log messages.

Advisor references: https://supabase.com/docs/guides/database/database-linter?lint=0028_anon_security_definer_function_executable and https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable .

## Completed safe engineering in this continuation

- Verified Supabase identity and business membership before Owner UI/onboarding; recover without redirect query or prior Gmail browser storage.
- Recover 401/403 access-token failures once using the refresh token; reject unsupported code/token_hash callback contracts with an explicit recovery path and scrub sensitive callback fields and discard guest-booking/navigation parameters from Owner callbacks.
- Keep Sign out available during verification; stale verification/refresh cannot restore a signed-out session.
- Add fresh-browser real-link tests, consumed-link and network-failure checks, retaining all existing lifecycle and logout-race assertions.
- Add read-only schema preflight, pinned CI action references, recurring-on-commit dependency/source/deployment security guards.
- Prepare default-disabled, authenticated single-job worker and raw-body signed webhook native entry points, with privacy-safe logs and unit/local HTTP regression coverage; no runtime activated.
- Draft pilot/public legal documents, DPA/storage/retention disclosure and incident/privacy/release/pilot runbooks without activating policies.

## Minimum operator actions and incremental cost

| Blocker | iPhone-friendly minimum action | Minimum incremental cost |
|---|---|---|
| Hosted schema access | Resolved automatically; read-only preflight, migrations, policies and advisors now inspected. No reconnection action needed | €0 |
| Hosted callback release proof | After other safety gates, approve the exact candidate deployment and one fresh email to a controlled inbox; verify actual Owner dashboard in Safari, refresh and logout | €0 if existing hosting/Auth entitlements permit |
| Hosted backup | Choose existing private storage, configure export credentials securely and retain the decryption key; approve read-only export and isolated restore, never production overwrite | €0 if suitable existing private storage/export access is available; otherwise unresolved, no purchase authorised |
| External Owner/Auth SMTP | Inspect SMTP settings; supply an eligible existing sender/domain and secure provider credentials; approve a controlled test. Do not add salons as project administrators | €0 with suitable existing resources; new domain/provider cost is conditional and not approved |
| Resend delivery | Approve test sender/recipient and configure verified sender/webhook/worker securely; keep customer delivery disabled until independently verified | Existing free testing can cost €0; actual custom-domain sending needs domain authority |
| Hosting eligibility | Vercel Safari dashboard → team Settings → Billing; report only plan name. Confirm allowed commercial use | €0 if an eligible plan already exists; if Hobby and no applicable permission, Pro advertised from US$20/month plus tax/usage is a conditional blocker, not a recommendation to buy |
| Pilot access | Approve disabling public signup and review existing users; provision only authorised owners after SMTP is ready | €0 configuration under existing account |
| Monitoring | Approve release/merge of reviewed workflow; enable existing GitHub failure notifications and verify an actual scheduled run; name incident owner | €0 for available existing notifications/manual pilot review; no paid monitoring selected |
| Legal/support | Provide operator identity, contact/hours and retention decisions; review and approve drafts with jurisdiction-appropriate professional help where needed | Drafts €0; professional/registration/regulatory costs cannot be determined from current records |
| Paid launch | Approve billing/provider/tax setup and a separately tested payment lifecycle only when Stage A evidence is satisfactory | Not activated; future processing fees/required costs must be quoted before consent |

## Two-stage plan

Stage A: up to three named salons, one onboarded at a time, 14 days free, no card/automatic conversion, synthetic rehearsal first, approved restricted access and data processing, fallback appointment record, named support and daily staffed checks. Manual salon communications are explicit; automation stays off. Review day 7, export/delete or separately approve extension at day 14. Start only after the blocked/failed mandatory pilot gates above are resolved and the operator approves activation. If eligibility/resources cannot be provided at €0, continue only supervised synthetic usability evaluation.

Stage B: after a successful pilot, resolve all public-paid gates, activate approved sender/worker/webhooks, billing and enforced tiers, approved legal documents, hosted recovery, dependable alerts/support and actual deployed-device evidence. Publish pricing and checkout only after explicit approval. No launch date or revenue claim is invented.
