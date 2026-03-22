-- ══════════════════════════════════════════════════════════════════════
-- ITC LIMITED | Seed Data — Real Figures from Annual Reports
-- All values in ₹ Crores | Source: ITC Standalone Annual Reports
-- ══════════════════════════════════════════════════════════════════════

SET search_path TO itc_analytics;

-- ─── BUSINESS UNITS ───────────────────────────────────────────────────
-- Source: ITC Annual Report — Business Overview section
INSERT INTO business_units (unit_name, segment, status, notes) VALUES
    ('FMCG – Cigarettes',
     'Consumer Goods – Tobacco',
     'Active',
     'Indias largest cigarette manufacturer. Brands: Gold Flake, Classic, Navy Cut. ~62% EBIT margin. Primary cash engine of ITC group.'),
    ('FMCG – Others',
     'Consumer Goods – Non-Tobacco',
     'Active',
     'Foods (Aashirvaad, Sunfeast, Bingo), Personal Care (Fiama, Engage, Savlon), Stationery (Classmate). High-growth low-margin turning profitable.'),
    ('Hotels',
     'Hospitality',
     'Demerged FY2025',
     'Luxury and upscale hotels under ITC Hotels, WelcomHotel, Fortune brands. Demerged as ITC Hotels Ltd effective FY2025. Data available FY2020-FY2024 only.'),
    ('Agri Business',
     'Agri-Commodities',
     'Active',
     'Leaf tobacco, wheat, spices, coffee, soya, seafood. Trading + value-added processing. High revenue volatility due to commodity price cycles.'),
    ('Paperboards, Paper & Packaging',
     'Manufacturing',
     'Active',
     'Specialty paperboards, printing & writing paper, packaging boards, specialty papers. Facing headwinds from Chinese imports and weak demand FY2024-25.');


-- ─── FINANCIALS ───────────────────────────────────────────────────────
-- Source: Note 28 (FY2020-2023) / Note 29 (FY2024) / Note 30 (FY2025)
-- "Segment Reporting" — "Segment Revenue" (External) and "Segment Results"
-- expenses = revenue - segment_results (EBIT)
-- profit   = GENERATED (revenue - expenses = segment results/EBIT)
--
-- FORMULA CHECK: expenses = revenue - EBIT
-- UNIT 1: FMCG – CIGARETTES

INSERT INTO financials (unit_id, fiscal_year, revenue, expenses) VALUES
-- FY2020: Rev 21201.74, EBIT 14852.55 → Expenses = 6349.19
(1, 2020, 21201.74,  6349.19),
-- FY2021: Rev 20333.12, EBIT 12720.41 → Expenses = 7612.71 (COVID: excise hike + volume drop)
(1, 2021, 20333.12,  7612.71),
-- FY2022: Rev 23451.39, EBIT 14869.07 → Expenses = 8582.32
(1, 2022, 23451.39,  8582.32),
-- FY2023: Rev 28206.83, EBIT 17927.06 → Expenses = 10279.77
(1, 2023, 28206.83, 10279.77),
-- FY2024: Rev 30596.59, EBIT 19089.17 → Expenses = 11507.42
(1, 2024, 30596.59, 11507.42),
-- FY2025: Rev 32631.27, EBIT 20024.87 → Expenses = 12606.40
(1, 2025, 32631.27, 12606.40);

-- UNIT 2: FMCG – OTHERS
INSERT INTO financials (unit_id, fiscal_year, revenue, expenses) VALUES
-- FY2020: Rev 12813.73, EBIT 423.05 → Expenses = 12390.68 (margin 3.3% — scale-up phase)
(2, 2020, 12813.73, 12390.68),
-- FY2021: Rev 14708.62, EBIT 832.69 → Expenses = 13875.93
(2, 2021, 14708.62, 13875.93),
-- FY2022: Rev 15964.75, EBIT 923.22 → Expenses = 15041.53
(2, 2022, 15964.75, 15041.53),
-- FY2023: Rev 19081.48, EBIT 1374.18 → Expenses = 17707.30
(2, 2023, 19081.48, 17707.30),
-- FY2024: Rev 20922.47, EBIT 1778.55 → Expenses = 19143.92
(2, 2024, 20922.47, 19143.92),
-- FY2025: Rev 21975.28, EBIT 1579.66 → Expenses = 20395.62 (margin dip due to input cost pressure)
(2, 2025, 21975.28, 20395.62);

-- UNIT 3: HOTELS (FY2020–FY2024 only — demerged in FY2025)
INSERT INTO financials (unit_id, fiscal_year, revenue, expenses) VALUES
-- FY2020: Rev 1823.41, EBIT 157.75 → Expenses = 1665.66
(3, 2020,  1823.41,  1665.66),
-- FY2021: Rev 623.59,  EBIT -534.91 → Expenses = 1158.50 (COVID devastation: -85.8% margin)
(3, 2021,   623.59,  1158.50),
-- FY2022: Rev 1279.33, EBIT -183.09 → Expenses = 1462.42 (partial recovery)
(3, 2022,  1279.33,  1462.42),
-- FY2023: Rev 2573.22, EBIT 541.90 → Expenses = 2031.32 (full recovery, record revenue)
(3, 2023,  2573.22,  2031.32),
-- FY2024: Rev 2973.74, EBIT 753.77 → Expenses = 2219.97 (best EBIT ever, then demerged)
(3, 2024,  2973.74,  2219.97);

-- UNIT 4: AGRI BUSINESS
INSERT INTO financials (unit_id, fiscal_year, revenue, expenses) VALUES
-- FY2020: Rev 5904.39, EBIT 788.92 → Expenses = 5115.47
(4, 2020,  5904.39,  5115.47),
-- FY2021: Rev 7866.06, EBIT 820.74 → Expenses = 7045.32 (+33% revenue, stable EBIT)
(4, 2021,  7866.06,  7045.32),
-- FY2022: Rev 12126.05, EBIT 1031.15 → Expenses = 11094.90 (commodity supercycle +54%)
(4, 2022, 12126.05, 11094.90),
-- FY2023: Rev 12314.86, EBIT 1327.74 → Expenses = 10987.12 (flat revenue, EBIT still grows)
(4, 2023, 12314.86, 10987.12),
-- FY2024: Rev 8417.44, EBIT 1254.43 → Expenses = 7162.01 (revenue -31.6%, margins hold)
(4, 2024,  8417.44,  7163.01),
-- FY2025: Rev 12065.64, EBIT 1478.03 → Expenses = 10587.61 (+43% recovery)
(4, 2025, 12065.64, 10587.61);

-- UNIT 5: PAPERBOARDS, PAPER & PACKAGING
INSERT INTO financials (unit_id, fiscal_year, revenue, expenses) VALUES
-- FY2020: Rev 4580.45, EBIT 1305.33 → Expenses = 3275.12
(5, 2020,  4580.45,  3275.12),
-- FY2021: Rev 4619.85, EBIT 1098.68 → Expenses = 3521.17 (flat revenue, margin compression)
(5, 2021,  4619.85,  3521.17),
-- FY2022: Rev 6279.57, EBIT 1700.00 → Expenses = 4579.57 (+35.9% revenue, strong EBIT)
(5, 2022,  6279.57,  4579.57),
-- FY2023: Rev 7304.50, EBIT 2293.99 → Expenses = 5010.51 (peak year — best margin 31.4%)
(5, 2023,  7304.50,  5010.51),
-- FY2024: Rev 6535.96, EBIT 1377.60 → Expenses = 5158.36 (demand softening, imports pressure)
(5, 2024,  6535.96,  5158.36),
-- FY2025: Rev 6626.23, EBIT 911.49 → Expenses = 5714.74 (crisis: margin 13.8%, EBIT -60% from peak)
(5, 2025,  6626.23,  5714.74);


-- ─── GROUP-LEVEL COSTS ────────────────────────────────────────────────
-- Source: ITC Standalone P&L Notes
-- Note 22/23: "Cost of materials consumed" = raw_material
-- Note 23/24/25/26: "Employee benefits expense" = admin
-- From "Other Expenses" note: Advertising/Sales Promotion = marketing
-- From "Other Expenses" note: Outward freight and handling = logistics
-- NOTE: Company-level totals. NOT allocated by segment.

INSERT INTO group_costs (fiscal_year, raw_material, admin, marketing, logistics) VALUES
-- FY2020: Source — Note 25 & 26, ITC Annual Report 2020
(2020, 13121.76, 2658.21, 1000.68, 1244.08),
-- FY2021: Source — Note 25 & 26, ITC Annual Report 2021 (prior-year column in FY2022 report)
(2021, 13605.07, 2820.95, 1089.64, 1337.98),
-- FY2022: Source — Note 25 & 26, ITC Annual Report 2022
(2022, 16064.50, 3061.99,  995.62, 1652.01),
-- FY2023: Source — Note 25 & 26, ITC Annual Report 2023 (prior-year column in FY2024 report)
(2023, 19809.83, 3569.46, 1173.21, 1680.39),
-- FY2024: Source — Note 26 & 27, ITC Annual Report 2024
(2024, 21309.84, 3732.23, 1439.45, 1617.89),
-- FY2025: Source — Note 27, ITC Annual Report 2025
(2025, 23440.12, 3416.73, 1319.94, 1891.85);

-- ─── VERIFICATION QUERIES ─────────────────────────────────────────────
-- Run these to verify data integrity after insertion

-- 1. Verify row counts
SELECT 'business_units' AS tbl, COUNT(*) FROM business_units
UNION ALL SELECT 'financials',   COUNT(*) FROM financials
UNION ALL SELECT 'group_costs',  COUNT(*) FROM group_costs;

-- 2. Verify profit = revenue - expenses (should show no rows)
SELECT unit_id, fiscal_year, revenue, expenses, profit,
       (revenue - expenses) AS computed_profit,
       ABS(profit - (revenue - expenses)) AS discrepancy
FROM financials
WHERE ABS(profit - (revenue - expenses)) > 0.01;

-- 3. Verify total group revenue FY2024 (should match ~₹69,446 Cr + Hotels)
SELECT fiscal_year, ROUND(SUM(revenue),2) AS total_segment_revenue
FROM financials
WHERE fiscal_year = 2024
GROUP BY fiscal_year;
