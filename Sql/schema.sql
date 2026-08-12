-- ============================================================
-- UK Political & Economic Decline Dashboard - MySQL Star Schema
-- ============================================================

-- ---------- DIMENSION TABLES ----------

CREATE TABLE IF NOT EXISTS dim_date (
    date_key      INT PRIMARY KEY,        -- YYYYMMDD
    full_date     DATE NOT NULL,
    year          INT NOT NULL,
    quarter       INT NOT NULL,
    month         INT NOT NULL,
    month_name    VARCHAR(10),
    day           INT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_pm (
    pm_id         INT AUTO_INCREMENT PRIMARY KEY,
    pm_name       VARCHAR(100) NOT NULL,
    start_date    DATE NOT NULL,
    end_date      DATE,
    party         VARCHAR(50),
    exit_reason   TEXT
);

CREATE TABLE IF NOT EXISTS dim_event (
    event_id      INT AUTO_INCREMENT PRIMARY KEY,
    event_date    DATE NOT NULL,
    event_name    VARCHAR(200) NOT NULL,
    event_type    VARCHAR(100),
    description   TEXT
);

-- ---------- FACT TABLES ----------

-- Daily market data
CREATE TABLE IF NOT EXISTS fact_markets_daily (
    date_key       INT PRIMARY KEY,
    ftse_open      DECIMAL(10,2),
    ftse_high      DECIMAL(10,2),
    ftse_low       DECIMAL(10,2),
    ftse_close     DECIMAL(10,2),
    sp500_open     DECIMAL(10,2),
    sp500_high     DECIMAL(10,2),
    sp500_low      DECIMAL(10,2),
    sp500_close    DECIMAL(10,2),
    gbpusd_close   DECIMAL(10,6),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- Monthly CPI
CREATE TABLE IF NOT EXISTS fact_cpi_monthly (
    date_key       INT PRIMARY KEY,      -- 1st of each month
    cpi_annual_rate_pct DECIMAL(5,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- Quarterly GDP growth
CREATE TABLE IF NOT EXISTS fact_gdp_quarterly (
    date_key         INT PRIMARY KEY,    -- 1st of quarter
    gdp_qoq_growth_pct DECIMAL(5,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- Quarterly-ish energy price cap (irregular periods, store as text label + date)
CREATE TABLE IF NOT EXISTS fact_energy_price_cap (
    date_key        INT PRIMARY KEY,     -- approx start-of-period date
    period_label    VARCHAR(20),
    annual_bill_gbp INT,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- Annual composite indicators (one row per year - the "hub" fact table)
CREATE TABLE IF NOT EXISTS fact_annual_indicators (
    year                    INT PRIMARY KEY,
    debt_to_gdp_pct         DECIMAL(5,2),
    unemployment_rate_pct   DECIMAL(5,2),
    real_awe_gbp_per_week   DECIMAL(8,2),
    gilt_10y_yield_pct      DECIMAL(6,4),
    tax_to_gdp_pct          DECIMAL(5,2),
    total_revenue_gbpm      BIGINT,
    gdp_current_price_gbpm  BIGINT,
    eu_exports_gbpm         BIGINT,
    eu_imports_gbpm         BIGINT,
    eu_trade_balance_gbpm   BIGINT
);

-- Wealth flight (non-dom counts by tax year - kept separate, different grain label)
CREATE TABLE IF NOT EXISTS fact_wealth_nondom (
    tax_year                VARCHAR(15) PRIMARY KEY,
    non_dom_only_count      INT,
    combined_count          INT
);

-- HNWI migration (annual)
CREATE TABLE IF NOT EXISTS fact_wealth_migration (
    year                    INT PRIMARY KEY,
    net_hnwi_migration      INT
);
