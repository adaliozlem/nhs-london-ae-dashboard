-- 01_load.sql
-- Load the combined monthly A&E file into PostgreSQL.
-- Run this in DataGrip on the nhs_ae database.
-- Run it again whenever a new month is added (after running scripts/combine_months.sh).

-- 1. Start fresh: remove the old table if it exists
DROP TABLE IF EXISTS ae_raw;

-- 2. Create an empty table with the 22 columns from the NHS file
--    (column names match docs/data-dictionary.md)
CREATE TABLE ae_raw (
    period_raw            TEXT,     -- e.g. MSitAE-SEPTEMBER-2026
    org_code              TEXT,
    region                TEXT,     -- "Parent Org" in the NHS file
    org_name              TEXT,

    att_type1             INTEGER,  -- attendances
    att_type2             INTEGER,
    att_other             INTEGER,
    att_booked_type1      INTEGER,
    att_booked_type2      INTEGER,
    att_booked_other      INTEGER,

    over4h_type1          INTEGER,  -- attendances over 4 hours
    over4h_type2          INTEGER,
    over4h_other          INTEGER,
    over4h_booked_type1   INTEGER,
    over4h_booked_type2   INTEGER,
    over4h_booked_other   INTEGER,

    dta_wait_4to12h       INTEGER,  -- waits from decision to admit
    dta_wait_12h_plus     INTEGER,

    adm_via_ae_type1      INTEGER,  -- emergency admissions
    adm_via_ae_type2      INTEGER,
    adm_via_ae_other      INTEGER,
    adm_other             INTEGER
);

-- 3. Copy the CSV file into the table (HEADER = skip the first row with column names)
COPY ae_raw
FROM '/Users/ozlem/Documents/nhs-london-ae-dashboard/data/processed/ae_all_months.csv'
WITH (FORMAT csv, HEADER true);

-- 4. Check: should be 3551 rows (same as the combine script output)
SELECT COUNT(*) AS rows_loaded
FROM ae_raw;
