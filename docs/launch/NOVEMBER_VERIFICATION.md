# 3 November 2026 verification — PR #10 only

Release recommendation: **NO-GO for a real closed pilot**. Candidate engineering results below do not authorise production operations. No founder identity, recovery PDF, passphrase, hosted dump or real customer content was requested or retrieved.

## Established state

- Baseline PR head ac48a7b33c841033d7a99d7f91b527965946843f, OPEN, eight successful Actions runs, confirmed through GitHub integration.
- Main and independently listed READY production deployment: 81edb461569b0eb8d80cde8873f298219c903c9f. Latest preview is 6b810a8 and is not the current candidate. Branch auto-deployment remains disabled.
- Supabase: 70 migrations; base fixture matches all 81 hosted application/private function hashes after formatting/statement-terminator normalization; 18 policies; zero public tables without RLS; zero anonymous table grants; zero dangerous authenticated grants. One Auth account with a password credential and zero memberships. Notification configuration disabled. No hosted schema or data change made.
- Public Auth settings: email enabled, automatic confirmation false, public signup still enabled. SMTP delivery to external owners is unverified. Resend has zero domains and zero webhooks. Account/hosting eligibility and paid protection were not changed.
- Security advisor: 3 deny-all-table INFO, 10 anonymous and 27 authenticated SECURITY DEFINER exposure warnings; disabled leaked-password protection. Function hash/role tests are scoped evidence, not a penetration test or reason to dismiss warnings.
- Branch-protection administration read returned 403 to the integration. All visible workflow runs are checked; the exact configured protected-branch required-check list cannot be certified from this connection. Do not merge.

## Implemented changes

1. Guest E2E now uses disposable PostgreSQL/PostgREST/GoTrue/Mailpit and five synthetic catalogs. Page requests outside loopback/the intercepted backend are blocked; remote BASE_URL is refused. Full lifecycle and concurrent-conflict assertions are retained. Production smoke no longer calls the booking creation RPC, even with invalid input; that negative assertion moved to isolated CI.
2. Both pending migrations are rehearsed in documented hours → notifications order inside a transaction and rolled back. An intentionally drifted legacy notification guard must abort without partial schema effects. Function/table ACLs and policies are included in rollback fingerprints. No hosted migration performed; historical migrations are never replayed.
3. Notification timezone must be explicit/nonblank. Signed supported events with malformed identifiers fail instead of being ignored/acknowledged. Late delayed events cannot downgrade delivered; negative terminal outcomes remain authoritative. Default-off controls, recipient allowlist and authenticated triggering remain intact.
4. Standard distribution-packaged age CLI, no custom cryptography: ephemeral synthetic X25519 identities, correct/wrong identity, corruption and truncation tests. Actual isolated dump is restored from age-decrypted bytes. Manifest now checks three sequence states and deliberate sequence tampering as well as rows/functions/policies/grants/constraints. Legacy CMS integrity regression retained.
5. Private-key pattern checks include age identities and encrypted PEM, and guard plaintext configuration files. Backup/identity archive file types are forbidden in the source tree and ignored by git. No founder key handling is added to any workflow.
6. Business-configured HTTPS Privacy/Terms links appear in booking review with safe URL parsing and noreferrer/noopener; absent, insecure or credential-bearing links are omitted. No platform legal draft has been published. Expanded booking-review WCAG tests exposed and prompted fixes for contrast and social-button label/name mismatch, preserving layout/branding.
7. Existing cross-tenant (14 RPC denials), direct-table/staff permissions, industry/snapshot roles and local DST SQL suites now also execute automatically in disposable guest CI.

## Evidence and failure history

- Local initial regression: 16 product checks, 50 UI scenarios and 24 Node tests passed.
- Local expanded regression: 16 product checks, 51 UI scenarios and 26 Node tests passed; both npm dependency audits report zero vulnerabilities. Source guards and syntax checks passed.
- Local standard age CLI: X25519 round-trip, wrong identity, truncation and tampering rejection passed. Generated keys and archive material were temporary synthetic fixtures only.
- Commit 2abfd96ad5f1b8e2d7e68d08ab00865bcc18df9c: Owner workflow [41674726951](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41674726951) passed 26 desktop/mobile cases, none skipped, migration/rollback rehearsal, schema preflight, SQL DST, age+CMS recovery of 47 tables/3 sequences, restored RLS, grant/sequence tampering and HTTP notification/PostgreSQL integration. Reported recovery elapsed time 46.16 seconds is a synthetic CI measurement, not hosted RTO.
- That commit's guest run passed 22 and failed 2: barber fixture services did not match the existing barber markup. Fixed fixture names without changing assertions. No application redesign was needed.
- Commit 433172390d436355efa4a97cce134892876fe262: guest run passed 24 and failed the 2 new review accessibility checks (contrast and label-content-name mismatch). The scan stayed enabled; labels/contrast were repaired. Owner/recovery push workflow passed.
- Later current-head outcomes must be read from completed Actions/PR #10, not inferred from these earlier runs. Final evidence is appended below after completion.
- Local Playwright browser installation failed because downloaded Chromium archives were truncated. No local real-browser pass is claimed. Browser evidence comes from actual GitHub Actions Chromium and touch WebKit runs, not a physical iPhone.

## Remaining release gates

BLOCKED: separate founder identity backup/recovery PDF custody and private re-import/decryption proof; approved hosted export and isolated restore; hosted migration approval; exact candidate release/deployment; restricted signup/password review; real Safari magic-link/Owner journey; eligible Auth SMTP and any actual notification delivery; active monitoring/incident routing; hosting commercial eligibility; legal operator/contact/retention/DPA and provider terms including intended Google Drive backup use. Billing/public registration/customer messaging remain inactive or unapproved.

Postgres reports 17.6. The [30 October Supabase advisory](https://supabase.com/changelog/tzdata-local-time-vancouver-edmonton-casablanca) makes affected-zone verification a conditional gate for Vancouver, Edmonton and Casablanca; no hosted upgrade was executed. There are zero timezone-expression indexes. Do not infer that London/Vienna DST tests certify every zone or the provider's latest service build.

The single next founder-dependent prerequisite is private verification that the separately stored age identity backup can actually be recovered and decrypt a synthetic challenge. A paper passphrase is not a key backup. No private identity, PDF or decrypted data should be uploaded to ChatGPT, GitHub, logs or the archive Drive. Export approval is a later, separate decision.


Confirmed expanded guest evidence at f69362004ecd3cab4f32b60bdafa9f4175c3ba00: [Browser regression 41676542744](https://github.com/takacsbence555-ctrl/-takacsbence555-ctrl.github.io/actions/runs/41676542744) passed all 26 desktop/mobile cases, including review WCAG and configured-policy URL safety. Its four SQL regression scripts also passed, including 14 cross-tenant RPC denials. A follow-up strengthens the invalid-contact case to use a real future available slot, assert INVALID_CONTACT / CONTACT_REQUIRED / INVALID_EMAIL / INVALID_PHONE individually and compare availability before/after; it no longer accepts PAST_BOOKING as an accidental negative-test pass. Final-head pipeline results are recorded in PR #10 after completion.
