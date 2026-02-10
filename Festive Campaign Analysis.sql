CREATE DATABASE festive_sales;
USE festive_sales;

      --                  ------------------------------
      --                 CITY & STORE PERFORMANCE ANALYSIS
      --                  ------------------------------
      
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

  -- Bengaluru,Chennai,Hyderabad are the top 1,2,3 cities with 10,8,7 stores repectively


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

                   
             --                   ------------------------
			 --                  PRODUCT & CATEGORY ANALYSIS
             --                   ------------------------
             

#CATEGORY WISE CAMPAIGN EFFECTIVENESS BY IR% AND ISU%
SELECT 
   Category,
   ROUND(SUM(IR) / SUM(Revenue_before) * 100,2) AS IR_pct,
   ROUND(SUM(ISU) / SUM(Quantity_before) * 100,2) AS ISU_pct,
   ROUND(SUM(IR) / SUM(ISU) * 100,2) AS IR_per_unit
FROM fact_events
GROUP BY Category
ORDER BY IR_pct DESC;

   -- While Home Appliances and Home Care performed strongly in both revenue and unit growth, 
   -- Grocery & Staples showed high unit uplift but relatively lower revenue growth, indicating volume-driven sales with thinner margins. 
   -- Personal Care underperformed on both unit and revenue metrics.


#EVAUATION OF PROMOTION IMPACT ACROSS CATEGORIES
SELECT
   Category,
   promo_type,
   ROUND(SUM(IR) / SUM(Revenue_before) * 100 ,2) AS IR_pct
FROM fact_events
GROUP BY Category,promo_type
ORDER BY IR_pct DESC;

   -- BOGOF emerged as the most effective promotion across categories, 
   -- while flat discounts consistently led to negative incremental revenue due to margin dilution.
   -- Cashback promotions are effective for bundled offerings when applied selectively, 
   -- but their effectiveness across other categories cannot be inferred from this campaign.
   
   
#PRODUCT WISE CAMPAIGN EFFECTIVENESS BY IR%
WITH product_ir AS (
    SELECT 
        f.product_code,
        dm.product_name,
        ROUND(SUM(f.IR) / SUM(f.Revenue_before) * 100, 2) AS IR_pct
    FROM fact_events f
    JOIN dim_products dm
        ON f.product_code = dm.product_code
    GROUP BY 
        f.product_code,
        dm.product_name
),
ranked_products AS (
    SELECT *,
           RANK() OVER (ORDER BY IR_pct DESC) AS top_rank,
           RANK() OVER (ORDER BY IR_pct ASC)  AS bottom_rank
    FROM product_ir
)
SELECT *
FROM ranked_products
WHERE top_rank <= 5
   OR bottom_rank <= 3
ORDER BY IR_pct DESC;
     
   -- Future campaigns should prioritize high-value durables and home categories, 
   -- while promotions on low-margin consumables and personal care items should be limited or redesigned to protect profitability.
   
   
				   --                   ---------------------
				   --                  PROMOTION TYPE ANALYSIS
                   --                   ---------------------
                   

#PROMOTION TYPES THAT RESULTED IN HIGH INCREMENTAL REVENUE PERCENTAGE
SELECT 
   promo_type,
   ROUND(SUM(IR) / SUM(Revenue_before) * 100, 2) AS IR_pct
FROM fact_events
GROUP BY promo_type
ORDER BY IR_pct DESC;

   -- BOGOF is the most effective promotion with the highest incremental revenue uplift,
   -- while flat discount offers (25%, 33%, 50%) resulted in negative revenue impact.


SELECT 
   Category,
   promo_type,
   SUM(IR) / SUM(Revenue_before)*100 AS ir_pct,
   SUM(ISU) / SUM(Quantity_before)*100 AS isu_pct,
   SUM(IR) / SUM(ISU)*100 AS IR_per_unit
FROM fact_events   
GROUP BY Category, promo_type 
ORDER BY ir_pct DESC;


#FINDING WHICH PROMOTIONS STRIKE BEST BALANCE BETWEEN ISU & MAINTAINING HEALTHY MARGINS
SELECT
  promo_type,
  SUM(ISU) AS total_ISU,
  ROUND(SUM(ISU) / SUM(Quantity_before) * 100, 2) AS ISU_pct,
  SUM(IR) AS total_IR,
  ROUND(SUM(IR) / SUM(ISU), 2) AS IR_per_unit
FROM fact_events
GROUP BY promo_type;

   -- 1. Cashback promotion delivers the highest incremental revenue and IR per unit,
   --    indicating strong volume uplift with healthy margins.
   -- 2. BOGOF drives massive unit sales (highest ISU%) while maintaining positive revenue,
   --    making it effective for traffic and stock movement.
   -- 3. Deep discount promotions (25%, 33%, 50% OFF) show negative incremental revenue,
   --    indicating margin erosion despite volume gains.
   -- 4. High ISU alone does not guarantee profitability; revenue quality matters.
   


