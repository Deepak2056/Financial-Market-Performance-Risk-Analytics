=============/*created tables in prodfin*/========================

create table prodfin.dim_company (
	company_id INT IDENTITY(1,1) PRIMARY KEY,
	company_name VARCHAR(100) NOT NULL);

create table prodfin.fact_trading (
    company_id INT NOT NULL,
    trade_date DATE NOT NULL,

    open_price  DECIMAL(18,4),
    high_price  DECIMAL(18,4),
    low_price   DECIMAL(18,4),
    close_price DECIMAL(18,4),
    volume      BIGINT,

    CONSTRAINT PK_fact_trading
        PRIMARY KEY (company_id, trade_date),

    CONSTRAINT FK_fact_trading_company
        FOREIGN KEY (company_id)
        REFERENCES prodfin.dim_company(company_id)
);

create table prodfin.fact_corporate_actions (
    company_id INT NOT NULL,
    action_date DATE NOT NULL,

    dividend_amount DECIMAL(18,4),
    stock_split_ratio DECIMAL(10,4),

    CONSTRAINT PK_fact_corporate_actions
        PRIMARY KEY (company_id, action_date),

    CONSTRAINT FK_fact_actions_company
        FOREIGN KEY (company_id)
        REFERENCES prodfin.dim_company(company_id)
);


============/*moving data into prodfin*/================

insert into prodfin.dim_company(company_name)
select distinct
	sd.Company
from rawfin.fact_stock_data sd
where sd.Company is not null;

INSERT INTO prodfin.fact_trading (
    company_id,
    trade_date,
    open_price,
    high_price,
    low_price,
    close_price,
    volume
)
SELECT
    dc.company_id,
    CAST(sd.[Date] AS DATE),
    CAST(sd.[Open] AS DECIMAL(18,4)),
    CAST(sd.High AS DECIMAL(18,4)),
    CAST(sd.Low AS DECIMAL(18,4)),
    CAST(sd.[Close] AS DECIMAL(18,4)),
    CAST(sd.Volume AS BIGINT)
FROM rawfin.fact_stock_data sd
JOIN prodfin.dim_company dc
    ON sd.Company = dc.company_name
WHERE sd.[Date] IS NOT NULL;

INSERT INTO prodfin.fact_corporate_actions (
    company_id,
    action_date,
    dividend_amount,
    stock_split_ratio
)
SELECT
    dc.company_id,
    CAST(sd.[Date] AS DATE),
    TRY_CAST(sd.Dividends AS DECIMAL(18,4)),
    TRY_CAST(sd.[Stock Splits] AS DECIMAL(18,4))
FROM rawfin.fact_stock_data sd
JOIN prodfin.dim_company dc
    ON sd.Company = dc.company_name
WHERE
    sd.[Date] IS NOT NULL
    AND (
        TRY_CAST(sd.Dividends AS DECIMAL(18,4)) <> 0
        OR TRY_CAST(sd.[Stock Splits] AS DECIMAL(18,4)) <> 0
    );


=======/*validating*/============
select TOP 5 * from rawfin.fact_stock_data;
select TOP 5 * from prodfin.fact_trading; /*Has trading information for all companies for everyday*/
select TOP 5 * from prodfin.dim_company;   /*Only has listed companies*/
select TOP 5 * from prodfin.fact_corporate_actions; /*Only has dividend and stock split data for all companies*/
