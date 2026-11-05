# KAVELYQ release scorecard

## 5 November pilot gate — latest verified candidate

**NO-GO for real customer data.** This supersedes older preparation dates below. Verified executable candidate: `4a44af08032ce71edfa72e00db4d9b9e868a4bc2`. All eight visible push/PR Actions runs completed successfully; no failed test remains at that revision. A documentation-only follow-up must also retain green CI. Completed candidate tests do not establish live operation.

| Critical requirement | Status | Verified scope / remaining founder action |
|---|---|---|
| Guest booking, confirmation, cancellation, rescheduling, concurrent attempts | PASS | 26/26 isolated desktop Chromium and touch WebKit cases; persisted disposable database only |
| Authenticated Owner, onboarding, five industries, Calendar, CRM, staff, services/settings and navigation | PASS | 26/26 actual local Auth/Mailpit/PostgREST journeys, no skipped test |
| Tenant isolation, roles, RLS, timezone and DST | PASS | Four SQL suites, 14 cross-tenant RPC denials, staff/table boundaries, winter/summer/gap and three database session zones |
| Pending migrations, order and rollback | PASS | Local only: owner-atomic-hours.pending.sql then notification-adapter.pending.sql; atomic rollback and incompatible-base rejection |
| Standard age X25519 encryption and synthetic recovered-key restore | PASS | Six payload sizes including STREAM boundaries; recovered identity used after removing ORIGINAL SYNTHETIC identity; 47 tables/3 sequences restored, source unchanged |
| Corruption, truncation, wrong identity/passphrase and incomplete output | PASS | CLI authentication failures, protected recovery-payload damage, missing identity, private quarantine and existing-output preservation |
| Notification retries/idempotency/webhook security | PASS | Local mock-provider HTTP + real disposable database, signed durable events, suppression/backoff/stale leases; no external email |
| Dependency/source/deployment guards and responsive accessibility | PASS | Both audited dependency trees zero vulnerabilities; 92-source-file guards; desktop/touch WebKit and scoped WCAG checks |
| Founder recovery PDF custody and iPhone recovery | BLOCKED | Retrieve durable separate off-device copy; privately open saved recovery payload and verify recovered-key challenge. No key/PDF/passphrase may be supplied to us |
| Live backup and measured recovery | BLOCKED | Separately approve precise export destination/scope and isolated restore after private recovery evidence; secure runner and owner-local decryption handoff need approval |
| Hosted migrations and controlled candidate release | BLOCKED | Approve each pending migration after backup, then exact merge/deployment separately. No production change authorised |
| Physical Safari sign-in and full deployed first-salon lifecycle | BLOCKED | After approved release, approve controlled inbox/account/booking test and perform on iPhone |
| Restricted signup/password review, external-owner Auth SMTP | BLOCKED | Review existing users; approve exact Auth settings and eligible sender. No public registration or real email activated |
| Notifications in real pilot | BLOCKED | Select explicit salon-managed communications with automation disabled, or approve/configure verified sender and separate delivery test |
| Monitoring, incident/support and rollback | BLOCKED | Name support contact/hours, approve active failure notifications/release and verify incident routing. Existing documentation is not active monitoring |
| Hosting commercial eligibility | BLOCKED | Confirm existing plan/permission in Vercel Billing without upgrade. A free pilot is not assumed exempt |
| Legal/privacy/retention/account closure | BLOCKED | Supply operator/contact and retention decisions; approve reviewed pilot terms/DPA and deletion process/provider use |
| Pilot scope and payments | BLOCKED | Approve at most three named salons, one at a time, 14 days free/no card, with explicit limitations. Payments remain disabled |

No new application defect was reproduced by the latest complete suite. These PASS entries are deliberately limited to candidate/isolation evidence; no live launch, penetration-test certification, physical-device or founder-recovery pass is claimed. Residual hosted advisor findings and conditional provider timezone restrictions remain documented below and require review, not indiscriminate grant removal.

### Exact completed Actions evidence

- Product PR [41683889618](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41683889618), push [41683876443](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41683876443): success.
- Guest/browser [41683876432](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41683876432): 26/26 plus SQL suites.
- Owner/recovery PR [41683889292](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41683889292), push [41683876610](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41683876610): 26/26, age recovery/47-table restore and mock notification integration.
- Security PR [41683889076](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41683889076), push [41683876422](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41683876422): success, zero dependency vulnerabilities.
- Production smoke [41683876438](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41683876438): existing production non-booking-write smoke only, not candidate deployment proof.

Smallest next founder action: follow [AGE_BACKUP_RECOVERY.md](AGE_BACKUP_RECOVERY.md#exact-private-iphone-verification-procedure) privately using the saved separate recovery copy, without deleting/resetting the original identity. Same-vault duplicate recognition is useful but not an independent recovered-key decryption proof. Report only pass/fail, never secret material. All production actions remain separate later decisions.

Preparation checkpoint, 3 November 2026. Recommendation: **NOT READY** for a live customer pilot or public paid launch. Safe synthetic evaluation can continue. This scorecard distinguishes candidate test evidence from hosted operation. The exact final commit's Actions results are recorded in PR #10; an older green run is not a release approval.

Status meanings: PASS = evidence supports the stated scope; FAIL = known current gap; BLOCKED = verification/activation needs access, configuration or approval. Categories: 1 = safe engineering completed/automatable; 2 = operator approval/account setup; 3 = conditional spending; 4 = optional improvement. No provider purchase, company registration, email campaign, payment activation, merge, production deployment or hosted migration was performed.

| Critical area | Closed pilot | Public paid | Evidence / remaining gate | Category |
|---|---|---|---|---|
| Guest booking, manage, reschedule, cancellation | PASS | PASS | Desktop/mobile candidate suite now runs against disposable PostgreSQL/PostgREST only, with preserved booking, waitlist, cancellation and concurrency assertions; release still needs controlled deployed-candidate verification | 1 / 2 |
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
| Notification foundation | PASS | PASS | Default-off worker/webhook; missing business timezone and malformed known-event identifiers fail closed; late delay cannot downgrade delivered; local queue/provider-contract tests cover retries, idempotency, stale leases, signed webhooks, suppression and duplicates | 1 |
| Actual Auth SMTP / external Owner delivery | BLOCKED | BLOCKED | Own-account delivery does not prove external owners; built-in SMTP is restricted testing infrastructure; inspect actual SMTP configuration | 2 / 3 |
| Automated customer notification delivery | PASS | BLOCKED | Pilot can explicitly use salon-managed communication with automation disabled; public automated service needs approved deployment/configuration of the prepared routes, a verified sender, webhook and real provider evidence | 2 / 3 |
| Encrypted synthetic recovery drill | PASS | PASS | Disposable backup/restoration plus standard age X25519 compatibility, corrupt/truncated archive and wrong-identity rejection, explicit sequence state comparison and tampering checks; never a production restore | 1 |
| Hosted off-site backup and measured recovery | BLOCKED | BLOCKED | Private Google Drive destination selected; founder reports locally generated AgePony X25519 identity, never inspected. Encrypted recovery PDF storage/import and physical-device decryption remain UNVERIFIED. Secure export access and approved drill required; source/config/storage asset coverage must be checked | 2 |
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

## 31 October release-control follow-up

Estimated live-pilot readiness: 65% (judgement estimate, not a test statistic); recommendation remains NO-GO. See APPROVAL_SEQUENCE.md for nine separate decisions, exact command templates, risks, effects, prerequisites, iPhone steps and a private feedback process. The new read-only release-gate evaluator rejects blanket approval, missing backups and missing pilot prerequisites. It is not connected to production and cannot authorise or execute a release.


## 3 November safe continuation

Source re-established through the GitHub integration: PR #10 OPEN at ac48a7b before this continuation; all eight baseline runs successful. Main/production independently confirmed 81edb461569b0eb8d80cde8873f298219c903c9f; latest preview is older 6b810a8, not the current candidate. Deployment guard retained. No hosted write/export, email, merge or deployment performed.

Fresh hosted read-only evidence: 70 migrations, 81/81 application/private function hashes match the base fixture after whitespace/statement-terminator normalization, public tables without RLS 0, anonymous public table grants 0, Auth users 1, memberships 0. Both pending additions remain absent; exact legacy notification patch guard present. Advisor residuals unchanged: 3 deny-all INFO, 10 anonymous and 27 authenticated SECURITY DEFINER findings, and disabled leaked-password protection. Resend has no domains/webhooks.

The old guest CI targeted hosted demo records. It has been moved to disposable Auth/Mailpit/PostgREST/PostgreSQL, with all lifecycle/concurrency assertions retained and outbound page requests blocked. Production smoke now has 14 non-booking-write checks; its former invalid booking assertion runs against the isolated backend instead. This avoids both test pollution and assuming demo mutations are harmless hosted writes. No hosted records were cleaned up or altered during this correction.

New standard age CLI tests generate ephemeral synthetic identities in a temporary 0700 directory only; no founder identity or public recipient is accepted. Successful local checks: X25519 round-trip, wrong identity, truncation and tampering rejection. The full CI restores the age-decrypted database archive and compares sequence state as well as rows/schema/RLS/grants. None of this proves that the founder's recovery PDF contains a usable identity or is stored safely. A paper passphrase alone is not an identity backup.

New provider tests cover missing timezone and signed malformed identifiers; SQL protects delivered outcomes against late delayed events. Notification migration now rejects incompatible base definitions atomically instead of silently applying an ineffective replacement. Both workflows use the documented hours → notification order, with an isolated transactional rollback and incompatible-base rehearsal. Existing hosted migrations were not replayed.

Business-configured HTTPS privacy/terms links are now rendered on booking review. Unsafe schemes, credential-bearing URLs and absent links are omitted. No platform legal draft has been published or approved. The business remains responsible for the configured destination and actual legal content; this is link integration, not a compliance certification.

Conditional timezone gate: hosted PostgreSQL reports 17.6. Supabase's 30 October advisory identifies older service builds with incorrect conversions for America/Vancouver, America/Edmonton and Africa/Casablanca. Hosted conversion probes and index metadata were read; there are zero timezone-expression indexes. No upgraded service version or corrected rules have been verified. A supervised Europe/London/Europe/Vienna pilot is a narrower scope; do not approve businesses in the affected zones without service-version/support verification. Any hosted upgrade causes potential downtime and needs separate approval after backup. Source: https://supabase.com/changelog/tzdata-local-time-vancouver-edmonton-casablanca .

Current-head CI evidence and remaining failures are recorded in NOVEMBER_VERIFICATION.md and PR #10. Local browser installation was blocked by truncated browser downloads; real desktop/touch-WebKit results must come from completed GitHub Actions, never that failed installation attempt.

The expanded booking-review WCAG scan exposed low-contrast text and mismatched social-button accessible names that the earlier first-step scan did not cover. Contrast/name corrections preserve the existing palette/layout. Guest CI also runs four existing transactional SQL suites (14 cross-tenant RPC denials, tenant-table/staff boundaries, snapshot roles/all industries, local DST conversion). Final pass/fail evidence must be taken from the final completed runs, not the first failing review scan.


Age recovery follow-up: founder setup is corrected to existing AgePony X25519 identity plus a reported 32-character recovery passphrase privately in Bitwarden and a protected paper PDF. No secret/PDF was requested or inspected. AGE_BACKUP_RECOVERY.md records public upstream source at 788f596df6027ce4e629acd41d0f68ffea06074d and separates standard-format compatibility, protected-identity payload recovery, same-vault dedup checks and independent fresh-vault/device proof. The native PDF renderer/scanner, founder identity, off-device custody and device-loss restoration remain BLOCKED/UNVERIFIED. Synthetic age recovery now checks six STREAM input sizes, final authentication before atomic plaintext publication, wrong recovery passphrases, missing keys and an intact existing output. No other production gate is bypassed.
