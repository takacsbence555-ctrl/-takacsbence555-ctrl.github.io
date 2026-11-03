# Transactional notification runtime — prepared, disabled, not deployed

The native Node.js Web API entry points are api/notification-worker.mjs and api/resend-webhook.mjs. No framework replacement, new dependency or scheduler is required. They are prepared source, not evidence of a Vercel deployment or real Resend delivery. Default settings prevent processing; keeping credentials configured does not itself enable sending.

## Server configuration requiring separate operator approval

Configure only in secure Vercel server environment fields; never in app.js, URLs, browser storage, public workflow arguments or chat. Do not use public CI fixture credentials.

| Setting | Meaning / safe default |
|---|---|
| NOTIFICATION_WORKER_SECRET | Cryptographically random secret with at least 32 characters; required in server-side Authorization: Bearer header; no query-token or browser-origin trigger |
| NOTIFICATIONS_ENABLED | Absent/false keeps sending disabled; literal true requires explicit approval |
| NOTIFICATIONS_PROVIDER_VERIFIED | Absent/false prevents processing; literal true only after real sender/provider verification |
| NOTIFICATION_APPROVED_RECIPIENTS | JSON array of explicitly approved recipients, maximum 100; absent/empty rejects before claiming jobs. Do not use this configuration as permission to send marketing |
| RESEND_FROM / RESEND_API_KEY | Verified permitted sender and private server API credential; provider key is never returned or logged |
| APP_ORIGIN | Exact approved HTTPS application origin, without path/query, for management links |
| SUPABASE_SERVICE_ROLE_KEY | Server-only queue access key; requires the reviewed pending notification migration |
| SUPABASE_URL | Optional; if present must match existing lpnewhfsbpwyjgdpoxqj project. Runtime does not support arbitrary destination databases |
| NOTIFICATIONS_WEBHOOK_ENABLED | Independent explicit opt-in for receiving signed events; absent/false returns disabled before reading payload |
| RESEND_WEBHOOK_SECRET | Provider-issued Svix signing secret configured privately; never use a worker trigger secret here |

The private per-business communication_delivery flags must also be approved and true; demo businesses and non-transactional templates remain excluded. No flag, key, domain, webhook or business delivery setting has been activated by preparing this source. No external customer email is sent during testing.

## Processing and security behavior

Worker accepts only authenticated POST, rejects browser Origin requests and ignores caller-provided recipients/job details. Each call claims at most one due job. The existing SQL queue owns leasing, maximum attempts, backoff and stale-claim recovery. The provider receives the stable notification ID as its idempotency key. Recipient allowlist and current eligibility are checked before sending. An idempotency key and eligibility check cannot recall an email already accepted by a provider; cancellations and opt-outs must be recorded promptly and in-flight race outcomes reviewed.

An accepted count means provider acceptance, not inbox delivery. Provider failure is stored for bounded retry; unacknowledged provider success returns HTTP 503 and a counter, preserving the same-key retry behavior. Do not manually create replacement jobs or change IDs to bypass idempotency. A retry may wait for the existing lease/backoff; inspect safe queue counters before intervention.

Webhook reads original bytes with a 64 KiB cap and five-second body deadline, validates signature/timestamp before database access, and waits for durable event persistence before a success response. Duplicate events are safe. Invalid signatures return 400; ledger/storage failure returns 503 so the provider can retry. Signature-verified unsupported events are ignored without storing tracking data. Bounce/complaint/suppression records prevent future eligible sends; terminal negative outcomes are not overwritten by a late delivery event.

No asynchronous fire-and-forget acknowledgement or raw event logging is used. Runtime logs contain bounded event names, aggregate counters and generic codes, without names, email addresses, booking links, token bodies, provider credentials or raw exceptions. HTTP responses use private/no-store. These logs are not an active alerting service; operator routing and retention remain approval/configuration tasks.

## Activation and verification sequence

1. Restore administration access, review actual hosted schema/permissions and pending migration compatibility, and complete the hosted backup gate. Obtain explicit migration approval before applying the reviewed file. No historical migration should be replayed.
2. Confirm hosting eligibility and a verified sender/domain arrangement at the approved cost. No purchase is authorised by this document. Obtain approval for a controlled test sender and recipient/simulator.
3. After explicit deployment approval, inspect the actual Vercel commit, Function build/status, default-disabled responses and method/auth controls. CI native Web Request tests and local HTTP integration do not certify platform routing or cold-start behavior.
4. Configure the Resend webhook on the approved reachable deployment for only the needed delivery/failure/bounce events. Use the real signing secret and confirm signature failure, duplicate delivery and durable correlation against synthetic jobs. Keep opening/click tracking disabled unless separately assessed.
5. Approve one controlled transactional send with approved allowlist and per-business flags. Verify provider ID, webhook outcome and recipient/simulator result. Never infer inbox arrival from queue sent or HTTP 200. Test provider rejection/rate limiting in an authorised test environment, not by deliberately spamming real recipients.
6. Review actual latency, cost/usage caps, rate/abuse controls, failure alerts and the named operator. Customer sending and any periodic trigger require a separate explicit activation decision. No cron has been installed. Vercel GET cron cannot invoke this POST-only worker directly; use a separately approved secure server-side trigger with the existing integration/resources.
7. Disable the send flag first to pause new dispatch; retain signed-webhook receipt as appropriate for in-flight outcomes. Do not destroy the delivery ledger or suppression records to recover from a failure. Record incident scope without posting private payloads.

## Test scope

Unit tests cover default-off behavior, bearer and Origin rejection, method restrictions, configuration validation, single-job limit, ignored caller recipients, redacted logs, raw-body integrity, signature/replay failures, oversized/slow streams, durable acknowledgement, unsupported events and ledger failure. Isolated CI exercises the worker and webhook through a loopback HTTP boundary with actual PostgreSQL/PostgREST queue transitions and a local Resend-contract provider. No real provider or customer communication is used. Actual platform deployment and provider verification remain separate release gates.

References: https://vercel.com/docs/functions/runtimes/node-js and https://vercel.com/kb/guide/how-do-i-get-the-raw-body-of-a-serverless-function .


3 November regressions: missing/blank business timezone now fails closed instead of using the worker machine's timezone. Supported signed webhook types with malformed provider IDs return an error rather than an ignored success. In the pending SQL, late delivery_delayed does not overwrite delivered; bounce/complaint/suppression/failure remain terminal. Migration aborts with INCOMPATIBLE_NOTIFICATION_BASE if a legacy acknowledgement guard has drifted. CI uses a loopback provider only, never Resend delivery. No webhook, sender, trigger or scheduler was configured. Resend idempotency is bounded to the provider's documented 24-hour window; it is not an unlimited exactly-once guarantee. Reference: https://resend.com/docs/dashboard/emails/idempotency-keys .
