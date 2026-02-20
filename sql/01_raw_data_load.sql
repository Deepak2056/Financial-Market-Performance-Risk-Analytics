=============/*created table and validated */================

CREATE TABLE rawfin.fact_stock_data (
    Company        VARCHAR(100),
    [Date]         VARCHAR(50),
    [Open]          VARCHAR(50),
    High           VARCHAR(50),
    Low            VARCHAR(50),
    [Close]        VARCHAR(50),
    Volume         VARCHAR(50),
    Dividends      VARCHAR(50),
    [Stock Splits] VARCHAR(50)
);

=============/*Imported data into stock_data and validated the import */================

select top 2 * from rawfin.fact_stock_data;

