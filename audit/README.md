# Production regression audit

Run `npm ci` and `npm test` in this directory for DOM regression tests with mocked RPC responses. These are not browser or live backend E2E tests. Run `npm run test:http` for read-only / invalid-input production HTTP checks. The public key is read from the application's existing configuration.

`database.test.sql` runs guest and authenticated-owner lifecycles against the real database inside a subtransaction that intentionally rolls back every synthetic row and edit. It verifies overlap rejection, contact validation, timezone handling, Sunday hours, owner CRUD, CRM, settings, price history and tenant isolation. Do not replace rollback with persistent fixtures. It needs the existing administration integration; do not grant these privileges to clients.

The SQL changes in this directory are already applied named production migrations. Do not rerun them. The private-helper and price-snapshot changes depend on the contact/day migration.

Live browser verification covers public navigation, service/staff/date/time selection, DE/EN switching, Owner demo pages and dialogs, history and refresh. No real payments, emails or SMS are used. Full magic-link delivery and authenticated browser workflows need a provisioned test owner and controlled inbox. Persistent production booking creation was blocked by automatic approval review; use the transactional database suite plus mocked submission tests. Mobile touch/Safari and a true narrow viewport could not be verified with the available browser controls; CSS fixes are not a substitute for device E2E testing.
