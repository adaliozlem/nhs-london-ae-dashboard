-- 04_data_quality.sql
-- Data quality checks on the ae_clean view.
-- Run after every reload (01_load.sql) to confirm the data is safe to use.
-- Each check says what result to expect.
-- (Row counts and the NHS reconciliation are in 02_clean.sql.)


-- DQ1. Duplicates: does any trust appear more than once in the same month?
-- HAVING filters after grouping (WHERE filters before).
-- Expected: 0 rows.
SELECT month, org_code, COUNT(*) AS times_seen
FROM ae_clean
GROUP BY month, org_code
HAVING COUNT(*) > 1;


-- DQ2. Missing values: are any attendance totals NULL?
-- A blank cell in the CSV loads as NULL, and NULL rows would drop out of every SUM.
-- Expected: 0.
SELECT COUNT(*) AS rows_with_missing_totals
FROM ae_clean
WHERE total_attendances IS NULL
   OR total_over_4h IS NULL;


-- DQ3. Coverage: how many providers report each month?
-- A sudden drop in one month could mean missing data in that month's file.
-- Expected: about 190-200 providers a month; 24-25 in London.
-- Observed: London fell from 25 to 24 providers in April 2026.
--           When comparing a trust over time, check for organisational changes.
SELECT month,
       COUNT(*) AS providers,
       COUNT(CASE WHEN region = 'NHS ENGLAND LONDON' THEN 1 END) AS london_providers
FROM ae_clean
GROUP BY month
ORDER BY month;
