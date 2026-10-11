.bail on
.timeout 10000
PRAGMA foreign_keys = ON;

-- Run against an existing database after making a SQLite backup.
-- Every row is marked with a unique batch ID for later identification.
BEGIN IMMEDIATE;
CREATE TEMP TABLE seed_batch AS
SELECT 'TEST-' || lower(hex(randomblob(6))) AS marker,
       strftime('%Y-%m-%dT%H:%M:%fZ', 'now') AS created;

CREATE TEMP TABLE seed_values AS
WITH RECURSIVE numbers(n) AS (
  SELECT 1 UNION ALL SELECT n + 1 FROM numbers WHERE n < 1000
)
SELECT n,
       CASE WHEN (random() & 3) = 0 THEN 'organization'
            ELSE 'individual' END AS subscriber_type,
       CASE (random() & 7)
         WHEN 0 THEN 'Anita' WHEN 1 THEN 'Ravi' WHEN 2 THEN 'Meera'
         WHEN 3 THEN 'Arun' WHEN 4 THEN 'Priya' WHEN 5 THEN 'Vijay'
         WHEN 6 THEN 'Lakshmi' ELSE 'Dev' END AS first_name,
       CASE (random() & 7)
         WHEN 0 THEN 'Rao' WHEN 1 THEN 'Nair' WHEN 2 THEN 'Sharma'
         WHEN 3 THEN 'Menon' WHEN 4 THEN 'Kumar' WHEN 5 THEN 'Patel'
         WHEN 6 THEN 'Das' ELSE 'Iyer' END AS last_name,
       (random() & 3) AS location,
       printf('%010d', 9000000000 + ((random() & 2147483647) % 1000000000)) AS phone,
       1 + ((random() & 2147483647) % 250) AS street_number
FROM numbers;

INSERT INTO subscribers (
  subscriber_type, name, contact_person_name, email, phone, postal_address,
  city, state, postal_code, country, created_at, updated_at
)
SELECT subscriber_type,
       first_name || ' ' || last_name ||
         CASE WHEN subscriber_type = 'organization' THEN ' Library' ELSE '' END ||
         ' [' || marker || '-' || printf('%04d', n) || ']',
       CASE WHEN subscriber_type = 'organization'
         THEN first_name || ' ' || last_name ELSE NULL END,
       lower(first_name) || '.' || lower(last_name) || '.' || n ||
         '.' || lower(marker) || '@example.com',
       phone,
       street_number || ' Test Street',
       CASE location WHEN 0 THEN 'Kochi' WHEN 1 THEN 'Chennai'
         WHEN 2 THEN 'Bengaluru' ELSE 'Mumbai' END,
       CASE location WHEN 0 THEN 'Kerala' WHEN 1 THEN 'Tamil Nadu'
         WHEN 2 THEN 'Karnataka' ELSE 'Maharashtra' END,
       CASE location WHEN 0 THEN '682001' WHEN 1 THEN '600001'
         WHEN 2 THEN '560001' ELSE '400001' END,
       'India', created, created
FROM seed_values CROSS JOIN seed_batch;

CREATE TEMP TABLE seeded_ids AS
SELECT id FROM subscribers
WHERE instr(name, '[' || (SELECT marker FROM seed_batch) || '-') > 0;

INSERT INTO audit_logs (subscriber_id, previous_values, updated_values, modified_at)
SELECT id, NULL, json_object(
  'id', id, 'subscriberType', subscriber_type, 'name', name,
  'contactPersonName', contact_person_name, 'email', email, 'phone', phone,
  'postalAddress', postal_address, 'city', city, 'state', state,
  'postalCode', postal_code, 'country', country,
  'createdAt', created_at, 'updatedAt', updated_at, 'archivedAt', archived_at
), updated_at
FROM subscribers WHERE id IN (SELECT id FROM seeded_ids);
COMMIT;

SELECT 'Batch: ' || marker FROM seed_batch;
SELECT 'Inserted subscribers: ' || COUNT(*) FROM seeded_ids;
SELECT 'Inserted audits: ' || COUNT(*) FROM audit_logs
WHERE subscriber_id IN (SELECT id FROM seeded_ids);
SELECT 'Total subscribers: ' || COUNT(*) FROM subscribers;
PRAGMA quick_check;
