# Database and repository safety review

The database now uses schema version 7. No production database was opened or
modified during this review.

| Problem | Change |
| --- | --- |
| An upgrade could commit subscription corrections before a later step failed. | All upgrade steps and the schema version now commit in one transaction. A failure rolls back data and schema changes together. |
| Retired subscriber columns were discarded, and old subscription terms were overwritten. | `migration_snapshots` retains the complete original rows before those changes. Existing plan duration rules remain in effect. |
| Rebuilding tables could reset the highest subscriber or subscription number previously issued. | Rebuilds preserve `sqlite_sequence`, including numbers belonging to previously deleted rows. |
| Upgrades did not validate foreign key relationships, and older schemas could miss indexes. | Upgrades validate references before committing, re-enable foreign key enforcement, and create missing declared indexes. Inconsistent data blocks an upgrade and remains intact. |
| An older app could open a newer database and change its version marker. | Opening a newer schema throws before writing anything. |
| Saving an old subscriber or subscription object could overwrite newer edits or reverse an archive. | Updates check the saved `updated_at` version and reject stale objects. Update timestamps advance even if the system clock moves backwards. Creation timestamps are preserved. |
| Subscription writes and the subsequent read were separate operations. | Creation and updates run in transactions, so a failed read after a write also rolls back the write. |
| Deleting a subscription permanently removed its data. | Deletion archives the row. `restoreSubscription(id)` restores it; reads include archived rows only when `includeArchived: true` is passed. Archive operations preserve all other fields. |
| The subscriber seed utility referenced removed columns and failed against the current schema. | The script uses current subscriber and audit fields. An integration test checks that seeding preserves existing subscriber and subscription data. |

Subscriber creation, registration, edits, archive and restore already used
transactions with audit writes. Regression tests now also check that an audit
failure rolls back the associated subscriber changes.

Recovery snapshots use `source_table`, `row_id`, `source_version`, and
`values_json`. For example, this read returns retired subscriber information:

```sql
SELECT row_id, source_version, values_json
FROM migration_snapshots
WHERE source_table = 'subscribers';
```

Snapshots are created when upgrading databases that still contain the old
values. Values already removed by an earlier release cannot be reconstructed
by this migration. Snapshots remain in the same database; they are not an
independent backup. Keep separate SQLite backups to recover from file deletion,
device failure or database corruption. The restoration API is available in the
repository; this change does not add an archive management screen.

Tests cover upgrades from versions 1 through 6, preservation of contact and
archive data, recovery snapshots, issued number sequences, file reopening,
rollback after constraint and foreign key failures, downgrade rejection, stale
edits, audit failures and subscription archive/restoration.

The migration transaction and foreign key handling follow the
[Drift migration guidance](https://drift.simonbinder.eu/migrations/api/).

## Subscriber status filters

The subscriber list's **Active** and **Expired** filters use non-archived
subscriptions and compare each subscription's `expiry_date` with today's
calendar date:

- **Active** includes a subscriber with at least one non-archived subscription
  whose expiry date is today or later. The comparison is inclusive, so a
  subscription expiring today is still active. A future `start_date` does not
  prevent the subscription from counting as active.
- **Expired** includes a subscriber with at least one non-archived subscription
  and no non-archived subscription expiring today or later. A subscriber with
  both expired and active subscriptions is Active.
- Subscribers with no non-archived subscriptions, or only archived
  subscriptions, appear in neither status filter. They remain visible under
  **All**.
- Archived subscribers are excluded from the list regardless of the selected
  filter.

The expiry check uses date-only values in `YYYY-MM-DD` format. The repository
tests cover the inclusive today boundary, future-start subscriptions, mixed
active and expired subscriptions, and subscribers with no current subscription.
