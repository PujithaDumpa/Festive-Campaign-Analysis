CREATE DATABASE festive_sales;
USE festive_sales;

#REPORT THAT DISPLAYS EACH CAMPAIGN ALONG WITH THE TOTAL REVENUE GENERATED BEFORE AND AFTER THE CAMPAIGN
SELECT 
  f.campaign_id,
  dm.campaign_name,
  SUM(f.Revenue_before) AS Revenue_before,
  SUM(f.Revenue_after) AS Revenue_after,
  ROUND(SUM(IR) / SUM(Revenue_before) * 100,2) AS IR_pct
FROM fact_events f
JOIN dim_campaigns dm 
  ON f.campaign_id = dm.campaign_id
GROUP BY f.campaign_id, dm.campaign_name
ORDER BY IR_pct DESC;

    -- While both campaigns delivered exceptional revenue growth, the Sankranti campaign achieved a higher
    -- incremental revenue percentage (113.58%) compared to Diwali (107.64%), suggesting more efficient 
	-- conversion of promotional efforts into revenue


# NUMBER OF STORES IN EACH CITY
SELECT 
city,
COUNT(*) AS no_of_stores FROM dim_stores
GROUP BY city
ORDER BY no_of_stores DESC;

 -- Bengaluru,Chennai,Hyderabad are the top 1,2,3 places with 10,8,7 stores repectively


#RANKING CITIES BASED ON REVENUE CHANGE PERCENTAGE
SELECT *,
  RANK() OVER(ORDER BY revenue_change_percentage DESC) AS city_rank FROM(
   SELECT 
     dm.city,
	 ROUND(SUM(f.IR) / SUM(f.Revenue_before) * 100, 2) AS revenue_change_percentage
   FROM fact_events f
   JOIN dim_stores dm 
     ON f.store_id = dm.store_id
   GROUP BY dm.city
)AS city_revenue;

   -- Madurai,Chennai,Bengaluru are the top 3 cities with highest revenue_change_percentages


#ANALYZING STORE PERFORMANCE
#TOP 3 STORES
SELECT 
  dm.city,
  f.store_id,
  ROUND(SUM(f.IR) / SUM(f.Revenue_before) * 100, 2) AS IR_pct
FROM fact_events f
JOIN dim_stores dm 
  ON f.store_id = dm.store_id
GROUP BY dm.city, f.store_id
ORDER BY IR_pct desc
LIMIT 3;

  -- Top 3 stores are STCHE-7 (142.66 ), STBLR-7 (140.6), STCBE-2 (140.13)

#BOTTOM 3 STORES
select 
  dm.city,
  f.store_id,
  round(sum(f.IR) / sum(f.Revenue_before) * 100, 2) as IR_pct,
  dense_rank() over(order by round(sum(f.IR) / sum(f.Revenue_before) * 100, 2) asc) as rnk
from fact_events f
join dim_stores dm 
  on f.store_id = dm.store_id
group by dm.city, f.store_id
limit 3;

   -- Bottom 3 stores are STMYS-0 (IR-pct 67.35), STVSK-3 (69.5), STCHE-1(71.96)
