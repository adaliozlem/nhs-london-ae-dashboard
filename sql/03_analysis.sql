-- 03_analysis.sql
-- Five business questions about London A&E performance, answered with SQL.
-- Data: ae_clean view (see 02_clean.sql).
-- No dates are hard-coded: "latest month" is found with MAX(month),
-- so every query updates automatically when a new month is loaded.


-- Q1. How many A&E attendances did London have each month?
-- Includes all A&E types and booked appointments (same as NHS published totals).
-- Check: matches the Excel pivot (Apr 2025 = 403,616; Sep 2026 = 432,712).
SELECT month,
       SUM(total_attendances) AS attendances
FROM ae_clean
WHERE region = 'NHS ENGLAND LONDON'
GROUP BY month
ORDER BY month;


-- Q2. What share of London A&E patients were seen within 4 hours each month?
-- 100.0 forces decimal division (integer / integer would return 0).
-- Check: matches the Excel pivot (Apr 2025 = 77.2%; Jan 2026 = 75.1%).
SELECT month,
       SUM(total_attendances) AS attendances,
       SUM(total_over_4h)     AS over_4h,
       ROUND(100.0 * (SUM(total_attendances) - SUM(total_over_4h)) / SUM(total_attendances), 1) AS pct_within_4h
FROM ae_clean
WHERE region = 'NHS ENGLAND LONDON'
GROUP BY month
ORDER BY month;


-- Q3a. Which 5 London trusts had the highest 4-hour performance in the latest month?
-- Only trusts with a Type 1 (major) A&E department, so like-for-like comparison.
-- The latest month is found with MAX(month), so the query updates when a new month is loaded.
-- Check: matches Excel Part 1 (Sep 2026: Hillingdon 81.9% highest).
SELECT org_name,
       ROUND(100.0 * (total_attendances - total_over_4h) / total_attendances, 1) AS pct_within_4h
FROM ae_clean
WHERE region = 'NHS ENGLAND LONDON'
  AND att_type1 > 0
  AND month = (SELECT MAX(month) FROM ae_clean)
ORDER BY pct_within_4h DESC
LIMIT 5;


-- Q3b. Which 5 London trusts had the lowest 4-hour performance in the latest month?
-- Same filters as Q3a, sorted from lowest to highest.
-- Check: matches Excel Part 1 (Sep 2026: King's College 69.2% lowest).
SELECT org_name,
       ROUND(100.0 * (total_attendances - total_over_4h) / total_attendances, 1) AS pct_within_4h
FROM ae_clean
WHERE region = 'NHS ENGLAND LONDON'
  AND att_type1 > 0
  AND month = (SELECT MAX(month) FROM ae_clean)
ORDER BY pct_within_4h ASC
LIMIT 5;


-- Q4. Which 5 London trusts had the most patients waiting 12+ hours
--     from decision to admit in the latest month?
-- Counts, not rates: larger trusts will naturally have higher numbers (see Q4b).
SELECT org_name,
       dta_wait_12h_plus
FROM ae_clean
WHERE region = 'NHS ENGLAND LONDON'
  AND att_type1 > 0
  AND month = (SELECT MAX(month) FROM ae_clean)
ORDER BY dta_wait_12h_plus DESC
LIMIT 5;


-- Q4b. 12+ hour waits per 1,000 Type 1 attendances (latest month)
-- Adjusts Q4 for trust size, so large and small trusts can be compared fairly.
-- Finding (Sep 2026): Royal Free stays 1st; Barts drops from 2nd to 5th.
SELECT org_name,
       dta_wait_12h_plus,
       att_type1,
       ROUND(1000.0 * dta_wait_12h_plus / att_type1, 1) AS waits_per_1000
FROM ae_clean
WHERE region = 'NHS ENGLAND LONDON'
  AND att_type1 > 0
  AND month = (SELECT MAX(month) FROM ae_clean)
ORDER BY waits_per_1000 DESC
LIMIT 5;


-- Q5. How does London's 4-hour performance compare with England each month?
-- CASE WHEN keeps only London rows inside the SUM (like SUMIFS in Excel),
-- so London and England can be shown side by side in one query.
-- Check: Sep 2026 London = 77.0%, England = 74.4% (NHS published figure).
SELECT month,
       ROUND(100.0 * SUM(CASE WHEN region = 'NHS ENGLAND LONDON' THEN total_attendances - total_over_4h END)
                   / SUM(CASE WHEN region = 'NHS ENGLAND LONDON' THEN total_attendances END), 1) AS london_pct,
       ROUND(100.0 * (SUM(total_attendances) - SUM(total_over_4h)) / SUM(total_attendances), 1) AS england_pct
FROM ae_clean
GROUP BY month
ORDER BY month;
