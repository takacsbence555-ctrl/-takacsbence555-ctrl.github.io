# KAVELYQ production readiness — 15 October 2026

Status: **NOT production-ready**. Existing application extended in place; no visual redesign or database replacement.

## Verified infrastructure

Repository: `takacsbence555-ctrl/-takacsbence555-ctrl.github.io`. Vanilla HTML/CSS/JavaScript; Vercel framework unset, Node 24. Existing production deployment before this work: `dpl_XCTcgVdokAc376EYZ4EVi5EaC39H`, commit `c06a27a64d0e1bf856a78fa168dad97f34e83928`, READY.

Supabase project `lpnewhfsbpwyjgdpoxqj` was INACTIVE. Restore accepted; now ACTIVE_HEALTHY. Read-only SQL independently confirmed zero public tables, and the migration history table is absent. Cause and historical data recovery remain unknown. No database DDL, replacement records, deletion or destructive migration was performed. Security advisor returned no lints, which is NOT meaningful assurance for a missing schema.

## Prioritised issue register

| ID | Priority | Finding | Status / evidence |
|---|---|---|---|
| P0-01 | Critical | Startup uses a single-element selector followed by forEach; JS initialization aborts | Fixed; DOM startup regression runs |
| P0-02 | Critical | Backend contains no application schema | BLOCKED: obtain original schema/migrations and recoverable backup or establish cause with Supabase; do not fabricate recovered data |
| P0-03 | Critical | Booking could display success for malformed successful HTTP response | Fixed: booking id and management token required; negative regression |
| P0-04 | Critical | Fallback catalog and static times can imply booking works when backend is absent | Fixed: fail closed, visible error, disabled selections/confirmation |
| P0-05 | Critical | Live owner views mixed simulated revenue and business actions with live records | Fixed in frontend: distinct live workspace, no simulated module fallback; mocked-data tests only |
| P1-01 | High | Guest booking/contact details and tokens persisted in localStorage | Fixed: guest data scoped to tenant in sessionStorage; old persistent guest values removed; same-origin scripts remain a risk |
| P1-02 | High | Refresh of any-barber selection loses resolved staff; catalog resets date | Fixed: scoped draft preserves resolved staff/date; expired dates clear time |
| P1-03 | High | Calendar week control was a drawer of unfiltered records; month absent | Implemented day/week/month/date/staff filtering of loaded backend records; not live E2E verified |
| P1-04 | High | No complete live customer search/segmentation | Added full loaded-record search and returning/inactive segments; persistence remains blocked |
| P1-05 | High | Drawer focus escapes and does not return | Fixed focus return and Tab wrap; regression |
| P1-06 | High | No reproducible CI test gate | Added pinned dependencies/lockfile and GitHub Actions test workflow |
| P1-07 | High | Double-booking, concurrency and tenant isolation not currently testable | BLOCKED by missing schema; existing SQL suite must run against recovered disposable staging database |
| P1-08 | High | Magic-link auth/session refresh, roles and access controls unverified | BLOCKED: restore auth application configuration and controlled test-owner/inbox; no magic emails sent |
| P1-09 | High | Token in manage URL can leak through referrer | Added no-referrer metadata and response header; token expiry/revocation requires restored backend |
| P1-10 | High | Staff, services, business settings depend on missing RPCs | Existing editors preserved, no claim of persistence |
| P2-01 | Medium | AI business operator implies unsupported revenue uplift | Demo labelled; live rules foundation uses loaded records, explains missing prices and uncertainty; communications disabled |
| P2-02 | Medium | Migration preview absent | Added bounded CSV parser, invalid rows, duplicate-in-file checks, escaped preview; import intentionally disabled until backend validation and tenant-aware commit exist |
| P2-03 | Medium | Pricing contradicts proposed £19/£39 | Landing and live price copy updated; configuration exposes proposed plans with billing disabled; no payment integration activated |
| P2-04 | Medium | Branding, notifications, backups, monitoring incomplete | Backend recovery and operational configuration required; do not sell as complete |

## Tests and limits

Run `cd audit && npm ci && npm test`. UI tests use jsdom and mocked RPC responses, not authenticated browser or database E2E. Product tests cover timezone/calendar boundaries, known-value insights, CSV validation/duplicates and disabled billing configuration. Syntax and whitespace checks run separately.

Existing `python3 audit/http.test.py` currently FAILS because backend tables/RPCs are missing. Its legacy “data exposed” assertion on a missing-table error is not evidence of a data leak. The database lifecycle suite was NOT run: its required relations do not exist. Do not interpret missing relations or empty advisor output as tested tenant isolation.

No real booking, customer email, SMS, subscription or charge was created during this work. Live appointment creation/reschedule/cancel, staff/settings/CRM persistence, concurrent writes, authenticated sessions and cross-tenant attacks remain unverified.

Cloud browser does not currently expose viewport resizing; desktop browser checks cannot be claimed as mobile-device coverage. Mobile Safari/touch and actual narrow viewport verification remain release gates.

## Recovery and release gates

1. Recover original public schema and migration history into isolated staging. Preserve/inspect available backups before any replacement. Repository audit SQL files are follow-up patches, not a base schema.
2. Confirm recoverable historical customer data, ownership and retention requirements. Never publish database backups or secrets in this public repository.
3. Run rollback-only SQL lifecycle suite, true two-session conflict tests, and owner/staff/foreign-tenant authorization tests.
4. Provision controlled test owner and inbox; verify magic-link delivery, expiry, sign-out and route protection. Configure production redirect allowlist.
5. Verify database policies, SECURITY DEFINER grants/search_path, booking-management expiry, rate limits and audit logs against recovered schema.
6. Configure backups with a restore drill, monitoring and alerting; set recovery objectives. No provider is assumed configured.
7. Complete branding persistence, tenant-aware migration commit/rollback, notification consent/opt-outs and owner approvals. No provider sends without separate explicit authorisation.
8. Verify mobile/desktop deployed flows before onboarding a first barbershop. Keep billing disabled; £19/£39 remains provisional.

Rollback: retain prior Vercel deployment above; revert release commits or use Vercel rollback to that deployment. No database rollback needed for this change because none was changed beyond restoring project availability.
