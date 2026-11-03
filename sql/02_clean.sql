-- 02_clean.sql
-- Create a clean view on top of the raw table.
-- A view is a saved query: it does not copy the data, it always reads from ae_raw.
-- So when ae_raw is reloaded (01_load.sql), this view is up to date automatically.

DROP VIEW IF EXISTS ae_clean;

CREATE VIEW ae_clean AS
SELECT
    -- Turn 'MSitAE-SEPTEMBER-2026' into the date 2026-09-01
    TO_DATE(REPLACE(period_raw, 'MSitAE-', ''), 'MONTH-YYYY') AS month,
    org_code,
    TRIM(region)  AS region,       -- remove trailing spaces (same as Trim in Power Query)
    org_name,

    -- Same totals as the Excel columns "Total attendances" and "Total over 4h"
    att_type1 + att_type2 + att_other
      + att_booked_type1 + att_booked_type2 + att_booked_other            AS total_attendances,
    over4h_type1 + over4h_type2 + over4h_other
      + over4h_booked_type1 + over4h_booked_type2 + over4h_booked_other  AS total_over_4h,

    att_type1,
    dta_wait_4to12h,
    dta_wait_12h_plus
FROM ae_raw
-- Remove the England total rows.
-- They are marked in Period in most months, only in Org Code in Feb 2026,
-- and one month's Period has a hidden extra character ('TOTAL' + 1 character).
-- NOT ILIKE '%total%' catches all of them, whatever the case or extra characters.
WHERE period_raw NOT ILIKE '%total%'
  AND org_code   NOT ILIKE '%total%';


-- Checks (same as the Checks sheet in analysis/london_trend.xlsx)

-- Check 1: total rows found in the raw data (expected: 18, one per month)
SELECT COUNT(*) AS total_rows_in_raw
FROM ae_raw
WHERE period_raw ILIKE '%total%'
   OR org_code   ILIKE '%total%';

-- Check 2: rows and months in the clean view (expected: 3533 rows, 18 months)
SELECT COUNT(*)              AS clean_rows,
       COUNT(DISTINCT month) AS number_of_months
FROM ae_clean;

-- Check 3: reconciliation with NHS England, September 2026
-- (expected: 2444743 attendances, 626751 over 4 hours)
SELECT SUM(total_attendances) AS sep_2026_attendances,
       SUM(total_over_4h)     AS sep_2026_over_4h
FROM ae_clean
WHERE month = '2026-09-01';
