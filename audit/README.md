# Production regression audit

Run `npm ci` and `npm test` in this directory for DOM regression tests with mocked RPC responses. These are not browser or live backend E2E tests. Run `npm run test:http` for read-only / invalid-input production HTTP checks. The public key is read from the application's existing configuration.

`database.test.sql` runs guest and authenticated-owner lifecycles against the real database inside a subtransaction that intentionally rolls back every synthetic row and edit. It verifies overlap rejection, contact validation, timezone handling, Sunday hours, owner CRUD, CRM, settings, price history and tenant isolation. Do not replace rollback with persistent fixtures. It needs the existing administration integration; do not grant these privileges to clients.

SQL files ending `.pending.sql` are proposed migrations applied only to disposable CI. Other historical migration files are already applied named production migrations. Do not rerun them. The private-helper and price-snapshot changes depend on the contact/day migration.

The guest Playwright suite is in `browser/playwright.config.cjs`. The separate `browser/owner.config.cjs` suite uses real local GoTrue, Mailpit SMTP, PostgREST and PostgreSQL. It intercepts only the backend origin to keep signed identities and synthetic records off production. Desktop Chromium uses America/Los_Angeles; mobile WebKit uses Asia/Tokyo; the business uses Europe/London. Assertions check local clock strings and persisted SQL values independently of these zones.

Run the isolated workflow to provision disposable containers, load the schema-only fixture and pending migrations, and execute authenticated browser journeys, SQL timezone tests, encrypted backup/restoration and notification integration. No source data or credentials are copied from production. Reports omit tokens, mail bodies and database dumps. Full hosted SMTP/Resend delivery and a hosted production backup still require separate controlled verification.
