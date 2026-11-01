# Data Dictionary — NHS England Monthly A&E Attendances and Emergency Admissions

**Source:** NHS England, *A&E Attendances and Emergency Admissions* (Monthly Situation Report, MSitAE), provider-level CSV.
**Coverage in this project:** April 2025 – September 2026 (18 monthly files, `data/raw/ae_YYYY_MM.csv`).
**Grain:** One row per provider organisation per month.
**Columns:** 22 (4 identifiers + 18 numeric measures).

## Key terms

| Term | Meaning |
|---|---|
| Type 1 | Major A&E department: consultant-led, 24-hour service with full resuscitation facilities. |
| Type 2 | Consultant-led single-specialty A&E service (e.g. eye or dental hospital). |
| Other A&E Department (Type 3) | Now Urgent Treatment Centres (UTCs): GP-led, open at least 12 hours a day, every day, bookable via NHS 111 or GP referral (NHS England methodology, Sept 2026 commentary). |
| Booked appointments | Attendances booked in advance (e.g. via NHS 111) rather than walk-ins. |
| DTA | Decision to admit: the time a clinician decides the patient needs a hospital bed. |
| 4-hour standard | Share of A&E attendances admitted, transferred or discharged within 4 hours of arrival. |

## How to read the columns

The 22 columns follow a patient's journey through urgent and emergency care. They fall into five groups:

| Group | Columns | Question it answers |
|---|---|---|
| 1. Identifiers | 1–4 | Which month and which organisation is this row about? |
| 2. Attendances | 5–10 | How many patients came? Split by department type and walk-in vs booked. |
| 3. Over 4 hours | 11–16 | How many of them spent more than 4 hours in A&E before being admitted, transferred or discharged? |
| 4. Waits after decision to admit | 17–18 | Once a doctor decided the patient needed a bed, how long did they wait to get one? |
| 5. Emergency admissions | 19–22 | How many patients were admitted to hospital as an emergency, via A&E or by other routes? |

**Worked example.** A patient arrives at a major emergency department with chest pain:
1. On arrival they count as one **Type 1 attendance** (group 2).
2. Still in A&E after 5 hours, they count as one **Type 1 attendance over 4 hours** (group 3).
3. A clinician decides to admit them, but a bed becomes available 14 hours later: one **12+ hour wait from decision to admit** (group 4).
4. When they reach the ward, they count as one **emergency admission via A&E – Type 1** (group 5).

**Reading the 4-hour percentage.** Higher is better. 74.4% means that out of every 100 patients, about 74 left A&E (admitted, transferred or discharged) within 4 hours and 26 waited longer. Type 3 percentages are naturally higher than Type 1 because Urgent Treatment Centres see less complex cases, so the two should not be compared directly. This is why the analysis flags trusts with a Type 1 department (`Has Type 1 A&E`) and ranks only those.

## Collection and coverage

- Data is submitted monthly by NHS Trusts, NHS Foundation Trusts, Social Enterprises and GP Practices averaging more than 200 attendances or 40 emergency admissions a month, via the Strategic Data Collection Service (SDCS).
- Submissions are quality-checked by NHS England against each provider's previous submissions; outliers are queried before publication.
- **Limitation:** very small providers below the reporting threshold are not included.

## Columns

| # | Original column name | Proposed SQL name | Type | Description | Example |
|---|---|---|---|---|---|
| 1 | Period | `period_raw` | text | Reporting month as text, e.g. `MSitAE-SEPTEMBER-2026`. Converted to a date (`period_month`) during loading. | MSitAE-SEPTEMBER-2026 |
| 2 | Org Code | `org_code` | text | Provider organisation code (unique ID). Join key to the system mapping file. | AJN |
| 3 | Parent Org | `region` | text | NHS England region. Has a trailing space in the source; trim before use. London rows = `NHS ENGLAND LONDON`. | NHS ENGLAND SOUTH EAST |
| 4 | Org name | `org_name` | text | Provider organisation name (trust, walk-in centre or independent provider). | ASHFORD WALK-IN-CENTRE |
| 5 | A&E attendances Type 1 | `att_type1` | integer | Unplanned attendances at Type 1 departments. | 0 |
| 6 | A&E attendances Type 2 | `att_type2` | integer | Unplanned attendances at Type 2 departments. | 0 |
| 7 | A&E attendances Other A&E Department | `att_other` | integer | Unplanned attendances at other (Type 3) departments. | 2584 |
| 8 | A&E attendances Booked Appointments Type 1 | `att_booked_type1` | integer | Booked attendances at Type 1 departments. | 0 |
| 9 | A&E attendances Booked Appointments Type 2 | `att_booked_type2` | integer | Booked attendances at Type 2 departments. | 0 |
| 10 | A&E attendances Booked Appointments Other Department | `att_booked_other` | integer | Booked attendances at other departments. | 0 |
| 11 | Attendances over 4hrs Type 1 | `over4h_type1` | integer | Type 1 attendances with a total time in A&E over 4 hours. | 0 |
| 12 | Attendances over 4hrs Type 2 | `over4h_type2` | integer | Type 2 attendances over 4 hours. | 0 |
| 13 | Attendances over 4hrs Other Department | `over4h_other` | integer | Other-department attendances over 4 hours. | 273 |
| 14 | Attendances over 4hrs Booked Appointments Type 1 | `over4h_booked_type1` | integer | Booked Type 1 attendances over 4 hours. | 0 |
| 15 | Attendances over 4hrs Booked Appointments Type 2 | `over4h_booked_type2` | integer | Booked Type 2 attendances over 4 hours. | 0 |
| 16 | Attendances over 4hrs Booked Appointments Other Department | `over4h_booked_other` | integer | Booked other-department attendances over 4 hours. | 0 |
| 17 | Patients who have waited 4-12 hs from DTA to admission | `dta_wait_4to12h` | integer | Patients waiting 4–12 hours from decision to admit to admission ("hs" is a typo in the source header). | 0 |
| 18 | Patients who have waited 12+ hrs from DTA to admission | `dta_wait_12h_plus` | integer | Patients waiting more than 12 hours from decision to admit to admission. | 0 |
| 19 | Emergency admissions via A&E - Type 1 | `adm_via_ae_type1` | integer | Emergency admissions through Type 1 A&E. | 0 |
| 20 | Emergency admissions via A&E - Type 2 | `adm_via_ae_type2` | integer | Emergency admissions through Type 2 A&E. | 0 |
| 21 | Emergency admissions via A&E - Other A&E department | `adm_via_ae_other` | integer | Emergency admissions through other A&E departments. | 0 |
| 22 | Other emergency admissions | `adm_other` | integer | Emergency admissions not via A&E (e.g. direct GP referral). | 0 |

## Derived measures (confirmed against NHS England published figures)

| Measure | Formula |
|---|---|
| Total attendances | att_type1 + att_type2 + att_other + att_booked_type1 + att_booked_type2 + att_booked_other |
| Total over 4 hours | over4h_type1 + over4h_type2 + over4h_other + over4h_booked_type1 + over4h_booked_type2 + over4h_booked_other |
| 4-hour performance (all types) | (Total attendances − Total over 4 hours) / Total attendances |
| 4-hour performance (Type 1) | (att_type1 + att_booked_type1 − over4h_type1 − over4h_booked_type1) / (att_type1 + att_booked_type1) |
| Total emergency admissions | adm_via_ae_type1 + adm_via_ae_type2 + adm_via_ae_other + adm_other |

> **Reconciliation (September 2026, England):** Our calculation including booked appointments gives 2,444,743 total attendances, 1,817,992 within 4 hours and 74.4% performance. These match the NHS England statistical commentary exactly, which confirms booked appointments are included in the published 4-hour measure.

**Operational standard:** 95% of patients should be admitted, transferred or discharged within 4 hours of arrival (NHS Constitution, as stated in the NHS England statistical commentary).

## Initial data quality observations

1. **Trailing whitespace:** `Parent Org` values end with a space (`"NHS ENGLAND SOUTH EAST "`). Trim during loading.
2. **Text period:** `Period` is text with a prefix (`MSitAE-`), not a date. Parse it to the first day of the month.
3. **Many zero rows:** Walk-in centres and independent providers report only Type 3 activity, so most columns are 0. Zeros here mean "no service", not missing data.
4. **Header typo:** "4-12 hs" in column 17. Rename to a clean SQL name.
5. **Long, special-character headers:** Spaces, `&` and `+` in column names. Rename to snake_case before loading into PostgreSQL.
6. **To check across all 18 files:** identical column order and count (schema drift), duplicate `org_code` per month, negative values, and over-4-hour counts exceeding attendances.
