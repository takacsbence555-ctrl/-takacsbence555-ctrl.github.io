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
