========/*Creating metrics view*/==========

CREATE VIEW prodfin.vw_daily_metrics AS
SELECT
    ft.company_id,
    ft.trade_date,
    ft.close_price,
    ft.volume,

   											 -- Previous day's close
    LAG(ft.close_price) OVER (
        PARTITION BY ft.company_id
        ORDER BY ft.trade_date
    ) AS previous_close,

   											 -- Daily return
    (
        ft.close_price -
        LAG(ft.close_price) OVER (
            PARTITION BY ft.company_id
            ORDER BY ft.trade_date
        )
    )
    /
    NULLIF(
        LAG(ft.close_price) OVER (
            PARTITION BY ft.company_id
            ORDER BY ft.trade_date
        ), 0
    ) AS daily_return,

    												-- Time attributes
    YEAR(ft.trade_date) AS trade_year,
    DATEPART(QUARTER, ft.trade_date) AS trade_quarter,
    MONTH(ft.trade_date) AS trade_month

FROM prodfin.fact_trading ft;

=======/*Checking metrics view*/===============
select top 50 * from prodfin.vw_daily_metrics order by company_id, trade_date ;

								=========/*Average daily return*/=============

select
	trade_date,
	avg(daily_return) as market_daily_return
from prodfin.vw_daily_metrics
where daily_return is not NULL
group by trade_date
order by trade_date;

								=========/*Average Daily Return per Company*/==========

select
	company_id,
	avg(daily_return) as average_daily_return
from prodfin.vw_daily_metrics
where daily_return is not NULL 
group by company_id 
order by company_id;

								========/*Quarterly performance*/=============

select
	company_id,
	trade_year,
	sum(daily_return) as quarterly_return
from prodfin.vw_daily_metrics
where daily_return is not null
group by
	company_id,
	trade_year,
	trade_quarter;

									========/*YTD Performance*/=============

SELECT
    company_id,
    trade_year,
    SUM(daily_return) AS ytd_return
FROM prodfin.vw_daily_metrics
WHERE daily_return IS NOT NULL
GROUP BY company_id, trade_year;

									===========/*Volatility*/=============
SELECT
    company_id,
    STDEV(daily_return) AS volatility
FROM prodfin.vw_daily_metrics
WHERE daily_return IS NOT NULL
GROUP BY company_id;



SELECT COUNT(*)
FROM prodfin.vw_daily_metrics
WHERE previous_close IS NULL;

									===========/*number of trading days*/===========

SELECT
    dc.company_name,
    COUNT(*) AS trading_days
FROM prodfin.vw_daily_metrics vm
JOIN prodfin.dim_company dc
    ON vm.company_id = dc.company_id
WHERE vm.daily_return IS NOT NULL
GROUP BY dc.company_name
ORDER BY trading_days DESC;
