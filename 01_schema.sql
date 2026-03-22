-- ══════════════════════════════════════════════════════════════════════
-- ITC LIMITED | Financial Analytics Database
-- Engine   : PostgreSQL 15
-- Schema   : itc_analytics
-- Author   : Strategy & Data Intelligence
-- Source   : ITC Standalone Annual Reports FY2020–FY2025
-- Note     : profit = Segment EBIT (not PAT). Tax is group-level unallocated.
-- ══════════════════════════════════════════════════════════════════════

CREATE SCHEMA IF NOT EXISTS itc_analytics;
SET search_path TO itc_analytics;

-- ─── TABLE 1: BUSINESS UNITS ──────────────────────────────────────────
CREATE TABLE business_units (
    unit_id     SERIAL PRIMARY KEY,
    unit_name   VARCHAR(100) NOT NULL,
    segment     VARCHAR(100),
    status      VARCHAR(50)  DEFAULT 'Active',  -- e.g. 'Demerged FY2025' for Hotels
    notes       TEXT
);

-- ─── TABLE 2: FINANCIALS (Segment Revenue + EBIT) ─────────────────────
-- SOURCE: Note 28/29/30 "Segment Reporting" in each Annual Report
-- revenue  = Segment Revenue (External sales only, excl. inter-segment)
-- profit   = Segment Results (EBIT) as reported
-- expenses = revenue - profit  (computed/stored)
CREATE TABLE financials (
    fin_id      SERIAL PRIMARY KEY,
    unit_id     INT         NOT NULL REFERENCES business_units(unit_id),
    fiscal_year SMALLINT    NOT NULL CHECK (fiscal_year BETWEEN 2015 AND 2035),
    revenue     NUMERIC(12,2) NOT NULL CHECK (revenue >= 0),
    expenses    NUMERIC(12,2) NOT NULL,
    profit      NUMERIC(12,2) GENERATED ALWAYS AS (revenue - expenses) STORED,
    UNIQUE (unit_id, fiscal_year)
);

-- ─── TABLE 3: GROUP-LEVEL COST BREAKDOWN ──────────────────────────────
-- SOURCE: Notes to Standalone P&L — Expenses Schedule
-- raw_material = "Cost of materials consumed" (Note 22/23)
-- admin        = "Employee benefits expense" (Note 23/24/25)
-- marketing    = "Advertising / Sales promotion" (within Other expenses)
-- logistics    = "Outward freight and handling charges" (within Other expenses)
-- NOTE: These are COMPANY-LEVEL costs, not segment-allocated.
CREATE TABLE group_costs (
    cost_id      SERIAL PRIMARY KEY,
    fiscal_year  SMALLINT    NOT NULL UNIQUE CHECK (fiscal_year BETWEEN 2015 AND 2035),
    raw_material NUMERIC(12,2),   -- Cost of materials consumed
    admin        NUMERIC(12,2),   -- Employee benefits expense
    marketing    NUMERIC(12,2),   -- Advertising & Sales Promotion
    logistics    NUMERIC(12,2)    -- Outward freight and handling
);

-- ─── INDEXES ──────────────────────────────────────────────────────────
CREATE INDEX idx_financials_year   ON financials(fiscal_year);
CREATE INDEX idx_financials_unit   ON financials(unit_id);
CREATE INDEX idx_group_costs_year  ON group_costs(fiscal_year);

-- ─── COMMENTS ─────────────────────────────────────────────────────────
COMMENT ON TABLE business_units IS 'ITC Limited business segments as reported in Segment Reporting notes';
COMMENT ON TABLE financials      IS 'Segment-level revenue and EBIT from ITC standalone annual reports FY2020-FY2025';
COMMENT ON TABLE group_costs     IS 'Company-level cost components from ITC standalone P&L FY2020-FY2025';
COMMENT ON COLUMN financials.profit IS 'Segment EBIT (Segment Results). NOT PAT. Tax and finance costs are group-unallocated.';
