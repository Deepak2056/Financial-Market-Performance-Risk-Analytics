=================================================/* Building Core Analytical Views */============================
--------create reusable aggregations like avg daily return, total return, volatility and trading days

alter view prodfin.vw_performance_summary as
select
	vdm.company_id,
	avg(vdm.daily_return) as average_daily_return,
	EXP(SUM(LOG(1 + vdm.daily_return))) - 1 as total_return,
	stdev(vdm.daily_return) as volatility,
	count(*) as trading_days
	
from prodfin.vw_daily_metrics vdm
where vdm.daily_return is not null
group by vdm.company_id;

==================================/*validating*/====================
select * from prodfin.vw_performance_summary;


===================================/*Time based performance*/==================
--------create reusable aggregations like YTD performance, quarterly returns, best/worst quarter, rolling performance (1w,3m,12m)
alter view prodfin.vw_time_based_performance as
select
	vdm.trade_year,
	vdm.company_id,
	sum(vdm.daily_return) as ytd_returns,
	sum(vdm.daily_return) as quarterly_returns

from prodfin.vw_daily_metrics vdm
where vdm.daily_return is not null
group by 
vdm.company_id,
vdm.trade_year,
vdm.trade_quarter;

==================================/*validating*/====================
select * from prodfin.vw_time_based_performance;

============================================================/*Quarterly performance*/==================


ALTER VIEW prodfin.vw_quarterly_performance AS
SELECT
    vdm.company_id,
    vdm.trade_year,
    vdm.trade_quarter,

    -- compounded quarterly return
    EXP(SUM(LOG(NULLIF(1 + vdm.daily_return,0)))) - 1
        AS quarterly_return,

    COUNT(*) AS trading_days_in_quarter,
    AVG(vdm.daily_return) AS avg_daily_return

FROM prodfin.vw_daily_metrics vdm
WHERE vdm.daily_return IS NOT NULL
GROUP BY
    vdm.company_id,
    vdm.trade_year,
    vdm.trade_quarter;


SELECT TOP 50 *
FROM prodfin.vw_quarterly_performance
ORDER BY company_id, trade_year, trade_quarter;


=================================================================/*Yearly performance*/==================


alter view prodfin.vw_yearly_performance as
select
	vdm.company_id,
	sum(vdm.daily_return) as annual_returns,
	count(*) as trading_days_per_year,
	stdev(vdm.daily_return) as annual_volatility
from prodfin.vw_daily_metrics vdm
where vdm.daily_return is not NULL
group by
	vdm.company_id,
	vdm.trade_year;

-----validation---
select * from prodfin.vw_yearly_performance
