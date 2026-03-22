-- ══════════════════════════════════════════════════════════════════════
-- ITC LIMITED | Financial Analytics — SQL Query Suite
-- Engine   : PostgreSQL 15
-- Schema   : itc_analytics
-- All figures in ₹ Crores | profit = Segment EBIT
-- ══════════════════════════════════════════════════════════════════════

SET search_path TO itc_analytics;

-- ════════════════════════════════════════════════════════════════════
-- Q1: PROFIT (EBIT) MARGIN — Unit × Year + YoY Margin Delta
--     Technique: LAG() Window Function partitioned by business unit
-- ════════════════════════════════════════════════════════════════════
SELECT
    bu.unit_name,
    f.fiscal_year,
    f.revenue                                               AS revenue_cr,
    f.expenses                                              AS expenses_cr,
    f.profit                                                AS ebit_cr,
    ROUND((f.profit / f.revenue) * 100, 1)                 AS ebit_margin_pct,
    ROUND(
        (f.profit / f.revenue) * 100 -
        LAG((f.profit / f.revenue) * 100)
            OVER (PARTITION BY f.unit_id ORDER BY f.fiscal_year),
    1)                                                      AS margin_delta_pp,
    CASE
        WHEN ROUND((f.profit / f.revenue) * 100, 1) >= 50  THEN 'CASH COW'
        WHEN ROUND((f.profit / f.revenue) * 100, 1) >= 20  THEN 'STRONG'
        WHEN ROUND((f.profit / f.revenue) * 100, 1) >= 10  THEN 'MODERATE'
        WHEN ROUND((f.profit / f.revenue) * 100, 1) >= 0   THEN 'THIN'
        ELSE                                                     'LOSS-MAKING'
    END                                                     AS margin_grade
FROM financials f
JOIN business_units bu ON f.unit_id = bu.unit_id
ORDER BY bu.unit_id, f.fiscal_year;


-- ════════════════════════════════════════════════════════════════════
-- Q2: REVENUE GROWTH — Year-on-Year % by Segment
--     Technique: LAG() CTE + Growth Classification
-- ════════════════════════════════════════════════════════════════════
WITH rev_yoy AS (
    SELECT
        bu.unit_name,
        f.fiscal_year,
        f.revenue,
        LAG(f.revenue) OVER (
            PARTITION BY f.unit_id ORDER BY f.fiscal_year
        ) AS prev_year_revenue
    FROM financials f
    JOIN business_units bu ON f.unit_id = bu.unit_id
)
SELECT
    unit_name,
    fiscal_year,
    revenue                                                         AS revenue_cr,
    prev_year_revenue                                               AS prev_rev_cr,
    ROUND(((revenue - prev_year_revenue) / prev_year_revenue) * 100, 1)
                                                                    AS yoy_growth_pct,
    CASE
        WHEN prev_year_revenue IS NULL                              THEN 'BASE YEAR'
        WHEN revenue > prev_year_revenue * 1.20                    THEN 'HYPER GROWTH >20%'
        WHEN revenue > prev_year_revenue * 1.10                    THEN 'HIGH GROWTH >10%'
        WHEN revenue > prev_year_revenue * 1.00                    THEN 'MODERATE GROWTH'
        WHEN revenue > prev_year_revenue * 0.90                    THEN 'DECLINE <10%'
        ELSE                                                             'SHARP DECLINE >10%'
    END                                                             AS growth_flag
FROM rev_yoy
ORDER BY unit_name, fiscal_year;


-- ════════════════════════════════════════════════════════════════════
-- Q3: COST ANALYSIS — Group-Level CAGR by Cost Component (FY2020→FY2025)
--     Technique: CROSS JOIN + POWER() for CAGR + RANK()
-- ════════════════════════════════════════════════════════════════════
WITH base AS (
    SELECT raw_material, admin, marketing, logistics
    FROM group_costs WHERE fiscal_year = 2020
),
end_yr AS (
    SELECT raw_material, admin, marketing, logistics
    FROM group_costs WHERE fiscal_year = 2025
),
cost_pivot AS (
    SELECT 'Raw Material'    AS cost_head, b.raw_material AS base_val, e.raw_material AS end_val FROM base b, end_yr e
    UNION ALL
    SELECT 'Admin (Employee)',              b.admin,       e.admin       FROM base b, end_yr e
    UNION ALL
    SELECT 'Marketing & Promotion',         b.marketing,   e.marketing   FROM base b, end_yr e
    UNION ALL
    SELECT 'Logistics (Freight)',           b.logistics,   e.logistics   FROM base b, end_yr e
)
SELECT
    cost_head,
    ROUND(base_val, 2)                                              AS fy2020_cr,
    ROUND(end_val, 2)                                               AS fy2025_cr,
    ROUND(((end_val - base_val) / base_val) * 100, 1)              AS total_growth_pct,
    ROUND((POWER(end_val / base_val, 1.0/5) - 1) * 100, 1)        AS cagr_5yr_pct,
    RANK() OVER (ORDER BY POWER(end_val / base_val, 1.0/5) DESC)   AS cagr_rank
FROM cost_pivot
ORDER BY cagr_rank;


-- ════════════════════════════════════════════════════════════════════
-- Q4: PROFITABILITY RANKING — Cumulative EBIT FY2022–FY2024
--     Technique: RANK() Window + Aggregate CTE
-- ════════════════════════════════════════════════════════════════════
WITH cum_ebit AS (
    SELECT
        bu.unit_name,
        SUM(f.profit)                               AS cum_ebit_3yr,
        AVG(f.profit)                               AS avg_annual_ebit,
        MIN(f.profit)                               AS worst_year_ebit,
        MAX(f.profit)                               AS best_year_ebit,
        ROUND(AVG((f.profit / f.revenue) * 100), 1) AS avg_ebit_margin_pct,
        ROUND(
            (MAX(f.profit) - MIN(f.profit)) / NULLIF(MIN(ABS(f.profit)),0) * 100
        , 1)                                        AS ebit_volatility_pct
    FROM financials f
    JOIN business_units bu ON f.unit_id = bu.unit_id
    WHERE f.fiscal_year BETWEEN 2022 AND 2024
    GROUP BY bu.unit_id, bu.unit_name
)
SELECT
    RANK() OVER (ORDER BY cum_ebit_3yr DESC)        AS rank,
    unit_name,
    ROUND(cum_ebit_3yr, 2)                          AS cum_ebit_3yr_cr,
    ROUND(avg_annual_ebit, 2)                       AS avg_annual_cr,
    ROUND(worst_year_ebit, 2)                       AS worst_yr_cr,
    ROUND(best_year_ebit, 2)                        AS best_yr_cr,
    avg_ebit_margin_pct,
    ROUND(
        cum_ebit_3yr / SUM(cum_ebit_3yr) OVER () * 100
    , 1)                                            AS pct_of_group_ebit
FROM cum_ebit
ORDER BY rank;


-- ════════════════════════════════════════════════════════════════════
-- Q5: RISK DETECTION — Revenue ↑ but EBIT ↓ (Margin Trap)
--     Technique: LAG() Conditional Flag
-- ════════════════════════════════════════════════════════════════════
WITH yoy_compare AS (
    SELECT
        bu.unit_name,
        f.fiscal_year,
        f.revenue,
        f.profit                                            AS ebit,
        LAG(f.revenue) OVER (PARTITION BY f.unit_id ORDER BY f.fiscal_year) AS prev_rev,
        LAG(f.profit)  OVER (PARTITION BY f.unit_id ORDER BY f.fiscal_year) AS prev_ebit,
        ROUND((f.profit / f.revenue) * 100, 1)             AS curr_margin,
        ROUND(
            LAG((f.profit / f.revenue) * 100)
                OVER (PARTITION BY f.unit_id ORDER BY f.fiscal_year)
        , 1)                                                AS prev_margin
    FROM financials f
    JOIN business_units bu ON f.unit_id = bu.unit_id
)
SELECT
    unit_name,
    fiscal_year,
    revenue                                                 AS revenue_cr,
    ebit                                                    AS ebit_cr,
    ROUND((revenue - prev_rev), 2)                          AS rev_delta_cr,
    ROUND((ebit - prev_ebit), 2)                            AS ebit_delta_cr,
    curr_margin                                             AS margin_pct,
    prev_margin                                             AS prev_margin_pct,
    ROUND((curr_margin - prev_margin), 1)                   AS margin_delta_pp,
    CASE
        WHEN revenue > prev_rev AND ebit < prev_ebit        THEN 'MARGIN TRAP'
        WHEN revenue > prev_rev AND ebit > prev_ebit        THEN 'HEALTHY GROWTH'
        WHEN revenue < prev_rev AND ebit > prev_ebit        THEN 'EFFICIENCY GAIN'
        WHEN revenue < prev_rev AND ebit < prev_ebit        THEN 'DOUBLE DECLINE'
        ELSE                                                     'NO CHANGE'
    END                                                     AS risk_flag
FROM yoy_compare
WHERE prev_rev IS NOT NULL
ORDER BY
    CASE risk_flag
        WHEN 'MARGIN TRAP'    THEN 1
        WHEN 'DOUBLE DECLINE' THEN 2
        WHEN 'EFFICIENCY GAIN' THEN 3
        ELSE 4
    END,
    unit_name, fiscal_year;


-- ════════════════════════════════════════════════════════════════════
-- Q6: ADVANCED — Rolling 3-Year Margin + Annual Rank + Cost Efficiency
--     Technique: Multi-CTE + ROWS BETWEEN + DENSE_RANK() + JOIN
-- ════════════════════════════════════════════════════════════════════
WITH margin_rolling AS (
    SELECT
        bu.unit_name,
        f.unit_id,
        f.fiscal_year,
        f.revenue,
        f.profit                                            AS ebit,
        ROUND((f.profit / f.revenue) * 100, 1)             AS margin_pct,
        ROUND(
            AVG((f.profit / f.revenue) * 100)
            OVER (
                PARTITION BY f.unit_id
                ORDER BY f.fiscal_year
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ),
        1)                                                  AS rolling_3yr_avg_margin
    FROM financials f
    JOIN business_units bu ON f.unit_id = bu.unit_id
),
cost_ratios AS (
    SELECT
        fiscal_year,
        ROUND((marketing    / (SELECT SUM(revenue) FROM financials f2
                              WHERE f2.fiscal_year = gc.fiscal_year)) * 100, 2)
                                                            AS mktg_pct_group_rev,
        ROUND((logistics    / (SELECT SUM(revenue) FROM financials f2
                              WHERE f2.fiscal_year = gc.fiscal_year)) * 100, 2)
                                                            AS logi_pct_group_rev,
        ROUND((raw_material / (SELECT SUM(revenue) FROM financials f2
                              WHERE f2.fiscal_year = gc.fiscal_year)) * 100, 2)
                                                            AS rm_pct_group_rev
    FROM group_costs gc
),
annual_rank AS (
    SELECT
        unit_name,
        unit_id,
        fiscal_year,
        margin_pct,
        rolling_3yr_avg_margin,
        DENSE_RANK() OVER (PARTITION BY fiscal_year ORDER BY margin_pct DESC) AS rank_in_year
    FROM margin_rolling
)
SELECT
    ar.unit_name,
    ar.fiscal_year,
    ar.margin_pct                                           AS ebit_margin_pct,
    ar.rolling_3yr_avg_margin,
    ar.rank_in_year,
    cr.mktg_pct_group_rev                                   AS group_mktg_pct_rev,
    cr.logi_pct_group_rev                                   AS group_logi_pct_rev,
    cr.rm_pct_group_rev                                     AS group_rm_pct_rev
FROM annual_rank ar
LEFT JOIN cost_ratios cr ON ar.fiscal_year = cr.fiscal_year
ORDER BY ar.fiscal_year, ar.rank_in_year;


-- ════════════════════════════════════════════════════════════════════
-- BONUS: Revenue CAGR by segment (FY2020 → FY2025)
--        Using FIRST_VALUE and LAST_VALUE window functions
-- ════════════════════════════════════════════════════════════════════
WITH base_end AS (
    SELECT
        bu.unit_name,
        MIN(f.fiscal_year)      AS start_yr,
        MAX(f.fiscal_year)      AS end_yr,
        MAX(f.fiscal_year) - MIN(f.fiscal_year) AS n_years,
        FIRST_VALUE(f.revenue)  OVER (PARTITION BY f.unit_id ORDER BY f.fiscal_year) AS base_rev,
        LAST_VALUE(f.revenue)   OVER (PARTITION BY f.unit_id ORDER BY f.fiscal_year
                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS end_rev
    FROM financials f
    JOIN business_units bu ON f.unit_id = bu.unit_id
    GROUP BY bu.unit_id, bu.unit_name, f.unit_id, f.revenue, f.fiscal_year
)
SELECT DISTINCT
    unit_name,
    start_yr,
    end_yr,
    ROUND(base_rev, 2)                                  AS base_rev_cr,
    ROUND(end_rev, 2)                                   AS end_rev_cr,
    ROUND((POWER(end_rev / base_rev, 1.0 / n_years) - 1) * 100, 1) AS revenue_cagr_pct,
    RANK() OVER (ORDER BY POWER(end_rev / base_rev, 1.0 / n_years) DESC) AS cagr_rank
FROM base_end
WHERE n_years > 0
ORDER BY cagr_rank;
