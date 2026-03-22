# ITC Limited — Financial Analytics Project (FY2020–FY2025)

> **Board-Level SQL Analytics | Real Data | 5 Segments | 6 Years**

---

## Overview

This project presents a complete SQL-driven financial analytics study of **ITC Limited** (NSE: ITC), one of India's largest diversified FMCG conglomerates. All financial data is sourced directly from ITC's published Standalone Annual Reports (FY2020–FY2025).

**Scope:** Segment-level revenue and EBIT analysis across ITC's 5 business segments over 6 fiscal years.

---

## Business Segments Covered

| Unit ID | Segment | Description |
|---|---|---|
| 1 | FMCG – Cigarettes | India's largest cigarette manufacturer. 60%+ EBIT margins |
| 2 | FMCG – Others | Foods, Personal Care, Stationery (Aashirvaad, Sunfeast, Fiama) |
| 3 | Hotels | Luxury/upscale hotels. **Demerged as ITC Hotels Ltd in FY2025** |
| 4 | Agri Business | Agri-commodities trading, leaf tobacco, spices, wheat |
| 5 | Paperboards, Paper & Packaging | Specialty paper, paperboards, packaging boards |

---

## Data Sources

All figures sourced from **ITC Limited Standalone Annual Reports** (Notes to Financial Statements — Segment Reporting):

| Report | Source | Key Note |
|---|---|---|
| FY2020 | ITC Report and Accounts 2020 | Note 28: Segment Reporting |
| FY2021 | ITC Report and Accounts 2021 | Note 28: Segment Reporting |
| FY2022 | ITC Report and Accounts 2022 | Note 28: Segment Reporting |
| FY2023 | ITC Report and Accounts 2023 | Note 28: Segment Reporting |
| FY2024 | ITC Report and Accounts 2024 | Note 29: Segment Reporting |
| FY2025 | ITC Report and Accounts 2025 | Note 30: Segment Reporting |

**Official Source:** https://www.itcportal.com/investor/annual-reports.aspx

---

## Project Structure

```
itc-analytics/
│
├── README.md                        ← This file
├── sql/
│   ├── 01_schema.sql                ← DDL: Table creation
│   ├── 02_seed_data.sql             ← DML: Real ITC data (FY2020–FY2025)
│   └── 03_queries.sql               ← All 6 analytical SQL queries
│
└── report/
    └── ITC_Financial_Analytics.html ← Executive HTML report (open in browser)
```

---

## SQL Queries Included

| # | Query | Technique |
|---|---|---|
| Q1 | Profit (EBIT) Margin — Unit × Year | LAG() Window Function |
| Q2 | Revenue Growth — Year-on-Year % | LAG() + CTE |
| Q3 | Cost CAGR — Fastest Growing Component | CTE + POWER() |
| Q4 | Profitability Ranking — 3-Year Cumulative | RANK() Window |
| Q5 | Risk Detection — Revenue ↑ but EBIT ↓ | Conditional Flags |
| Q6 | Rolling 3-Year Margin + Annual Ranking | Multi-CTE + DENSE_RANK() + AVG() OVER |

---

## Key Findings

1. **Cigarettes contributes ~78% of group EBIT** despite being one of five segments
2. **FMCG-Others EBIT grew 30.1% CAGR** (FY2020–FY2024) — fastest scaling segment
3. **Hotels EBIT swung from -₹534.91 Cr (FY2021) to +₹753.77 Cr (FY2024)** — demerged FY2025
4. **PPP EBIT collapsed 60.3%** from ₹2,293.99 Cr (FY2023) to ₹911.49 Cr (FY2025)
5. **Agri revenue is volatile**: -31.6% (FY2024), then +43.3% (FY2025)
6. **Raw material costs grew at 12.3% CAGR** (FY2020–FY2025) — primary cost pressure

---

## Assumptions & Methodology

- All values are in **₹ Crores** (1 Crore = 10 Million INR)
- Fiscal year = April 1 to March 31 (India standard)
- `profit` = Segment Results (EBIT) as reported. **Not PAT.** Tax and finance costs are group-level and unallocated.
- `expenses` = Segment Revenue (External) − Segment EBIT (derived)
- `group_costs` table uses company-level standalone cost data (Materials, Employee, Advertising, Logistics)
- Hotels FY2025 row is excluded — the segment was demerged effective FY2025
- FY2025 data reflects continuing operations only (Hotels treated as discontinued)

---

## How to Run

```bash
# PostgreSQL 15+
psql -U postgres -c "CREATE DATABASE itc_analytics;"
psql -U postgres -d itc_analytics -f sql/01_schema.sql
psql -U postgres -d itc_analytics -f sql/02_seed_data.sql
psql -U postgres -d itc_analytics -f sql/03_queries.sql
```

---

## Tools Used

- **PostgreSQL 15** — Schema design, DDL, DML, Window Functions, CTEs
- **Python (Pandas/SQLAlchemy)** — Data validation and export
- **Power BI** — Dashboard visualisation
- **HTML/CSS** — Executive report

---

## Author

Prepared as a board-level financial analytics project using real published data from ITC Limited Annual Reports.
Data extracted from official ITC Annual Reports, verified against BSE filings.

---

*This project is for educational and analytical purposes only. All data is publicly available from ITC Limited's official investor relations portal.*
