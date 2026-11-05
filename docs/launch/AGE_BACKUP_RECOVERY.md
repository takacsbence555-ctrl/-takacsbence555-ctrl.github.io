# Standard age backup and founder recovery gate

3 November 2026. Preparation only: no production export, hosted data/schema change,
release, real email or backup activation is authorised by this document.

## Decision and corrected custody facts

Use standard **age v1, native X25519 recipient-based encryption** for the proposed
KAVELYQ archive. A PostgreSQL custom-format dump is arbitrary binary input to age;
its schema/data format need not change. A future export runner needs only the
verified PUBLIC recipient. It must never hold the founder's private identity,
recovery PDF or passphrase. OpenPGP is a different format and is not required.
The existing CMS tests are legacy regressions, not a requirement to create an RSA
key/certificate or replace the existing iPhone identity.

Founder-reported setup, not independently inspected: an X25519 identity was created
locally in AgePony; a 32-character recovery passphrase is held privately in
Bitwarden; AgePony generated a passphrase-protected paper-recovery PDF. Durable
storage and successful restoration of that particular PDF remain **UNVERIFIED**.
Never retrieve Bitwarden items or ask for a screenshot, PDF, identity or passphrase.
Do not restart key generation. Password length alone is not an entropy assessment.

The archive destination is the separate private KAVELYQ Google Drive. Keep the
identity/recovery material OUT of that archive destination, GitHub, workflow
artifacts, chat and logs. Choose independently recoverable owner-controlled storage
for the recovery PDF; a file that only survives on the iPhone is insufficient.
A paper passphrase copy does not recreate an age identity. Do not assume a free
Bitwarden plan supports PDF attachments or that paid storage has been purchased.

## Compatibility: what was actually examined

The reference age CLI accepts native `age1...` X25519 recipients and standard age
identity files. AgePony documents bidirectional age v1 interoperability. Its
post-quantum `age1pq1...` format is distinct and requires newer implementations;
this release tests the founder-reported classical X25519 type, not PQ, SSH,
GitHub-username recipient discovery, signing bundles or hardware-key extensions.
Let an established age implementation validate Bech32/checksum/type; do not use a
prefix-only test or implement cryptography in the application.

Reviewed PUBLIC upstream source at **788f596df6027ce4e629acd41d0f68ffea06074d**:

- [PaperBackup.swift](https://github.com/norsehorse-dev/AgePonyiOS/blob/788f596df6027ce4e629acd41d0f68ffea06074d/Sources/AgePonyCore/Portability/PaperBackup.swift): `seal` creates an armored age scrypt payload containing an identity file. Default work factor is 18. `open` decodes/decrypts it.
- [PaperBackupView.swift](https://github.com/norsehorse-dev/AgePonyiOS/blob/788f596df6027ce4e629acd41d0f68ffea06074d/AgePony/Features/Portability/PaperBackupView.swift): the PDF contains that payload as QR/text, with public recipient/metadata. It is the embedded secret payload that is age-encrypted; do not assume the PDF container itself has a PDF-open password. The protected page omits the passphrase.
- [PaperRestoreView.swift](https://github.com/norsehorse-dev/AgePonyiOS/blob/788f596df6027ce4e629acd41d0f68ffea06074d/AgePony/Features/Portability/PaperRestoreView.swift): Settings restore supports scanning OR pasted text, a separate passphrase prompt, preview, then Add to vault. It does not reset the vault or make imported identities active.
- [KeyPortability.swift](https://github.com/norsehorse-dev/AgePonyiOS/blob/788f596df6027ce4e629acd41d0f68ffea06074d/AgePony/Services/Portability/KeyPortability.swift): derives the X25519 public key from recovered secret material; import deduplicates by full public key and type. The preview shortens the public key, so a short preview/name alone is not a full comparison.

This is source/format review, NOT execution or independent security certification
of the installed iOS binary, PDF renderer, QR scanner or the founder's PDF.

## Reproducible synthetic evidence (no founder input)

Install standard distribution age/age-keygen in a disposable Linux runner. Run:

```sh
python3 audit/isolated/age_recovery.py
```

No arguments, connection URLs, uploaded files, user keys or user passphrases are
accepted. The script generates fresh identities and a random synthetic recovery
passphrase in a temporary 0700 directory, sets private files to 0600 and suppresses
CLI output. A non-echoing pseudo-terminal supplies the TEST passphrase to standard
age; it never appears in argv, environment, source fixtures or report output.
No cipher, KDF or key-format implementation is written in KAVELYQ.

Cases: empty/one-byte input; 65,535/65,536/65,537-byte STREAM boundaries; a multi-chunk
131,089-byte file; round-trip SHA-256 equality; malformed recipient; wrong/missing
identity; corrupted header/late payload; empty, mid-file and final-byte truncation;
existing-destination preservation. Decryption writes into private quarantine first;
only a successful full CLI exit can atomically publish the result. Failed output
is discarded, never handed to pg_restore. Abrupt process/host loss still requires
private quarantine cleanup; this is not a secure-erasure guarantee.

Recovery-payload case: standard age passphrase+armor protects the generated test
identity, the payload is decrypted, the recovered public recipient is compared,
the ORIGINAL SYNTHETIC identity file is removed, and only the recovered identity
is used to decrypt the original test archive. A wrong recovery passphrase, corrupted/truncated protected recovery payload and
missing identity fail. This models the protected payload embedded in the PDF,
not native PDF rendering/selection/scanning. Only generated fixtures are removed;
NEVER delete/reset the founder's original identity to test recovery.

The existing isolated GitHub workflow additionally creates the disposable database,
loads its schema/pending candidates, runs real local Owner/browser/SQL tests, dumps
synthetic data, exercises this same recovery chain and restores into a fresh
`qa_restore_...` database. It compares 47 tables, three sequence states,
functions/policies/grants/constraints, verifies restored tenant boundaries and
detects deliberate grant/sequence tampering. The source is unchanged after the
fixture setup. The workflow prints only redacted evidence; it removes the cluster.
See `.github/workflows/isolated.yml` for the exact reproducible container order.
No hosted URL is accepted by the recovery script.

## Future approved export and complete restore order

These are procedural templates for a later separately authorised operation, not
commands run during preparation. No production runner or scheduler is activated.

1. Verify exact source, approved scope, installed tool versions, trusted export
   connection, independently confirmed public recipient and private destination.
   Do not discover recipients dynamically from GitHub usernames. Record reviewed
   migration/schema revision, capture time and ciphertext hash privately.
2. Encrypt the custom-format stream with the public recipient only, under
   `umask 077` and `set -euo pipefail`. An illustrative pipeline is
   `pg_dump --dbname="$BACKUP_DATABASE_URL" --format=custom --serializable-deferrable | age --encrypt --recipient "$BACKUP_PUBLIC_RECIPIENT" --output "$PRIVATE_STAGING_ARCHIVE"`.
   Both producer and encryptor must succeed before publishing/uploading; discard
   partial output on either failure. Never run it against hosted data without
   export/destination approval. Never publish a dump or production archive in CI.
3. Read back the encrypted archive from the approved store and compare its SHA-256
   against independently trusted evidence. age authenticates its contents against
   tampering, but encryption to a public recipient does NOT prove who created an
   archive. An attacker can encrypt a different valid file to a public recipient.
   A co-located editable checksum is not sender authentication. Require trusted
   provenance before letting any database archive execute SQL in a restore target.
4. Decrypt on a founder-controlled trusted device with the recovered identity,
   keeping secret material there. A generic owner-local CLI template is
   `age --decrypt --identity "$OWNER_LOCAL_IDENTITY_FILE" --output "$PRIVATE_QUARANTINE_DUMP" "$ENCRYPTED_ARCHIVE"`.
   This is NOT a request for the file/path/value and must never run in public CI
   with the founder's key. Fully verify success before proceeding. Do not pipe
   streaming decryption directly to pg_restore; late corruption can follow already
   emitted valid chunks. Any partial plaintext remains private and is discarded.
5. Only after decryption and origin checks, inspect the complete custom archive
   using matching pg_restore, then restore to an explicitly approved DISPOSABLE
   target, without production credentials/provider secrets or outbound dispatch:
   `pg_restore --exit-on-error --single-transaction --dbname="$ISOLATED_RESTORE_DATABASE_URL" "$PRIVATE_QUARANTINE_DUMP"`.
   No --clean/overwrite against production. Restore of an untrusted archive can
   execute SQL; isolate it even when its age authentication passes.
6. Compare counts/hashes, schema, constraints, sequence last_value/is_called,
   policies/grants and tenant/booking behavior. Verify Auth/global roles/provider
   configuration and Storage OBJECT BYTES separately: pg_dump is not a full
   Supabase service backup. Replay authorised deletion records before any restored
   service is exposed. Measure actual RPO/RTO; synthetic CI duration is not hosted
   recovery evidence. The production trial/expiry clock may change restored UI.
7. Destroy disposable restore infrastructure and approved temporary plaintext;
   retain only reviewed encrypted archives and redacted evidence under an approved
   retention policy. Production replacement remains an incident-specific approval.

An iPhone can handle the private identity and age file decryption. It is not a
PostgreSQL server: full database restoration needs a trusted isolated runner and
an approved secure plaintext handoff if decryption happens only on the phone.
That handoff/production scope is NOT implemented or authorised here. The founder's
private identity must not be transferred to make public CI a production restore
runner. Do not promise unattended disaster recovery with a founder-only offline key.

## Exact private iPhone verification procedure

Current source-backed UI labels are below; installed versions may differ. If a
label/behavior differs, stop without Reset Vault, deleting the app or removing the
original identity. Do not send screenshots containing secrets or the PDF.

1. Retain the original AgePony identity untouched. Ensure the protected recovery
   PDF exists in durable owner-controlled off-device storage SEPARATE from the
   KAVELYQ archive Drive, and the recovery passphrase remains privately accessible
   in Bitwarden without depending solely on this iPhone. A temporary share-sheet
   PDF or local Files entry alone does not prove this. No new purchase is required
   if suitable private storage already exists; do not use public print/QR services.
2. Privately obtain the PDF from THAT saved copy, not a newly regenerated backup.
   Using only trusted on-device viewing, copy its complete ARMORED ENCRYPTED backup
   text, or scan its QR from a trusted private print/display. Do not copy the
   underlying secret key. Do not upload the PDF or use an online QR decoder.
3. In AgePony Settings choose **Restore from a paper backup** / **Restore from
   paper**. On the same iPhone use **...or type or paste the text**, then
   **Continue**. Use **Scan the page** only when a trusted separate display/print
   is available. Enter the recovery passphrase ONLY into the backup's **Passphrase**
   field, then **Open backup**; this is not the vault-unlock/duress-password screen.
4. Successful opening must show a recovered identity, not merely a PDF preview or
   passphrase prompt. Confirm the expected identity/type and full public recipient
   where available. The paper preview is abbreviated. **Add to vault** should
   report **That key is already in your vault** when the original is still there;
   reviewed source compares the full derived key/type and skips duplicates without
   replacing/activating the original. Unexpected keys/mismatches are a failure.
5. Separately create a NON-SENSITIVE text challenge, encrypt it to the same native
   public recipient and decrypt locally. For definitive recovery proof use a
   fresh trusted owner-controlled vault/device containing ONLY the recovered key,
   or a local standard age command explicitly using that recovered identity. No
   original key deletion, vault reset or app uninstall is permitted as a shortcut.
   The source-backed same-vault preview/dedup is useful evidence that the recovery
   payload opened and parsed; same-vault decryption alone does not demonstrate
   independence from the original cached identity. A fresh-device drill remains
   unverified if only the same-vault check can be completed.
6. Privately retain only date, installed version, matching-public-recipient result,
   saved-copy retrieval result and challenge/recovery outcome. Report pass/fail
   only if needed; never send secret material, PDFs or decrypted backup data.

**Smallest next founder action:** make and retrieve the durable separate protected
PDF copy, then run the non-destructive Settings restore check on the phone. This
is preparation only. Full device-loss recovery sign-off additionally requires the
independent recovered-key challenge above; no production export approval is implied.

## Sources and limits

- [Reference age format](https://age-encryption.org/v1)
- [Reference implementation and CLI](https://github.com/FiloSottile/age)
- [AgePony recipient/interoperability documentation](https://agepony.com/docs.php)
- [AgePony security model](https://agepony.com/security.php)
- Pinned source links above were inspected through read-only GitHub access.

Standard-format compatibility is supported; this particular founder identity,
PDF custody/restoration, installed app behavior, hosted backup and production
recovery remain unverified until the appropriate private/approved tests succeed.
