--QUERY 1: Calc Quantity of items, Sales value & Order quantity by each Subcategory in L12M (find out The lastest date, and then get data in last 12 months)

WITH max_date AS (
      SELECT DATE (MAX(ModifiedDate)) AS latest_date
      FROM `adventureworks2019.Sales.SalesOrderDetail`)
SELECT 
  FORMAT_DATETIME ('%b %Y',a.ModifiedDate ) AS period
  ,c.Name 
  ,SUM(a.OrderQty) as qty_item
  ,SUM (a.LineTotal) as total_sales
  , COUNT (DISTINCT a.SalesOrderID) as order_qty 
FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
LEFT JOIN `adventureworks2019.Sales.Product` as b
    ON a.ProductID= b.ProductID
LEFT JOIN `adventureworks2019.Production.ProductSubcategory` AS c
    ON CAST (b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID 
WHERE DATE(a.ModifiedDate) >= (
  SELECT DATE_SUB(latest_date, INTERVAL 12 MONTH)
  FROM max_date
)
GROUP BY period, c.Name 
ORDER BY period DESC, c.Name;

--Cách query khác 
select format_datetime('%b %Y', a.ModifiedDate) month
      ,c.Name
      ,sum(a.OrderQty) qty_item
      ,sum(a.LineTotal) total_sales
      ,count(distinct a.SalesOrderID) order_cnt
FROM `adventureworks2019.Sales.SalesOrderDetail` a 
left join `adventureworks2019.Production.Product` b
  on a.ProductID = b.ProductID
left join `adventureworks2019.Production.ProductSubcategory` c
  on b.ProductSubcategoryID = cast(c.ProductSubcategoryID as string)

where date(a.ModifiedDate) >=  (select date_sub(date(max(a.ModifiedDate)), INTERVAL 12 month)
                                from `adventureworks2019.Sales.SalesOrderDetail` )--2013-06-30
-- where date(a.ModifiedDate) >= date(2013,06,30)
-- where date(a.ModifiedDate) between   date(2013,06,30) and date(2014,06,30)
group by 1,2
order by 2,1;

--1 số cách khác để filter L12M:
where date(a.ModifiedDate) >=  (select date_sub(date(max(a.ModifiedDate)), INTERVAL 12 month)
                                from `adventureworks2019.Sales.SalesOrderDetail` )--2013-06-30
-- where date(a.ModifiedDate) >= date(2013,06,30)
-- where date(a.ModifiedDate) between   date(2013,06,30) and date(2014,06,30)

--QUERY 2: Ranking Top 3 TeritoryID with biggest Order quantity of every year. If there's TerritoryID with same quantity in a year, do not skip the rank number

WITH data_raw AS (
      SELECT 
        EXTRACT(year FROM a.ModifiedDate) AS year
        ,c.Name
        ,SUM(a.OrderQty) AS Qty_item
      FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
      LEFT JOIN `adventureworks2019.Sales.Product` AS b
        ON a.ProductID = b.ProductID
      LEFT JOIN `adventureworks2019.Production.ProductSubcategory` AS c
        ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID 
      GROUP BY 1, 2)
,
diff_cte AS ( -- Tính YoY growth rate 
      SELECT 
        year
        ,name
        ,Qty_item
        ,LAG(Qty_item) OVER (PARTITION BY Name ORDER BY year) AS prv_qty
        ,ROUND((Qty_item / LAG(Qty_item) OVER (PARTITION BY Name ORDER BY year) - 1), 2) AS qty_diff
      FROM data_raw
)
,
rank_cte  AS ( --Sắp xếp theo thứ tự 
      SELECT 
      name 
      ,Qty_item
      ,prv_qty
      ,qty_diff
      ,DENSE_RANK() OVER (ORDER BY qty_diff DESC) AS rank
    FROM diff_cte
    ORDER BY rank ) 

SELECT 
  name
  , Qty_item
  , prv_qty
  , qty_diff
FROM rank_cte
WHERE rank <=3; 


--QUERY 3: Ranking Top 3 TeritoryID with biggest Order quantity of every year. If there's TerritoryID with same quantity in a year, do not skip the rank number

WITH total_qty as (-- Tính tổng Order theo năm và Territory
      SELECT 
              EXTRACT(year FROM a.ModifiedDate) AS year
            ,b.TerritoryID
            , SUM(a.OrderQty) AS order_cnt
      FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
      LEFT JOIN `adventureworks2019.Sales.SalesOrderHeader` AS b
          ON a.SalesOrderID = b.SalesOrderID
      GROUP BY 1,2) 
, rank_cte as ( --Sắp xếp kết quả theo từng năm 
    SELECT *
      , DENSE_RANK() OVER (PARTITION BY  year   ORDER BY  order_cnt DESC) as rank 
    FROM total_qty
    ORDER BY year DESC)

SELECT 
  *
FROM rank_cte
WHERE  rank <=3; 



--QUERY 4: Calc Total Discount Cost belongs to Seasonal Discount for each SubCategory

WITH data_raw as (
      SELECT 
              EXTRACT(year FROM a.ModifiedDate) AS year
              , c.Name
              , d.DiscountPct*a.UnitPrice*a.OrderQty as discount_cost
      FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
        LEFT JOIN `adventureworks2019.Sales.Product` AS b
          ON a.ProductID = b.ProductID
        LEFT JOIN `adventureworks2019.Production.ProductSubcategory` AS c
          ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID 
        LEFT JOIN `adventureworks2019.Sales.SpecialOffer` as d
          ON a.SpecialOfferID = d.SpecialOfferID 
      WHERE d.type = 'Seasonal Discount' )

SELECT 
  year
  , name 
  , SUM (discount_cost) as Total_cost_discount 
FROM data_raw 
GROUP BY 1,2;



--QUERY 5:Retention rate of Customer in 2014 with status of Successfully Shipped (Cohort Analysis)

WITH info_cte as (
      SELECT 
          EXTRACT(month FROM ModifiedDate) AS month_order 
        , EXTRACT(year FROM ModifiedDate) AS year
        , CustomerID
        , COUNT (DISTINCT SalesOrderID) AS sales_cnt
      FROM  `adventureworks2019.Sales.SalesOrderHeader` 
      WHERE status = 5 and EXTRACT(year FROM ModifiedDate) =2014
      GROUP BY 1,2,3)
, 
rank_month_cte as (
    SELECT 
        *
        , ROW_NUMBER () OVER (PARTITION BY CustomerID ORDER BY month_order) as rank_month
    FROM info_cte )
,
first_month_purchase as (
    SELECT DISTINCT month_order as month_join, year, CustomerID
    FROM 
      rank_month_cte
    WHERE rank_month = 1)
,
all_join_cte as (
    SELECT 
        a.month_order
        , a.year
        , a.CustomerID
        , b.month_join
        , CONCAT ('M','-',a.month_order -b.month_join) as month_diff
    FROM info_cte as a
      LEFT JOIN first_month_purchase as b
      USING (CustomerID)
    ORDER BY  a.CustomerID)

SELECT DISTINCT month_join, month_diff
  , COUNT (DISTINCT CustomerID ) AS customer_cnt
FROM all_join_cte
GROUP BY 1,2
ORDER BY 1; 


--QUERY 6:Trend of Stock level & MoM diff % by all product in 2011. If %gr rate is null then 0. Round to 1 decimal

WITH data_raw AS (
      SELECT 
        a.Name
        ,EXTRACT(month FROM b.ModifiedDate) AS month
        , EXTRACT(year FROM b.ModifiedDate) AS year
        , SUM (b.StockedQty) as Stock_qty
      FROM `adventureworks2019.Production.Product` AS a
        LEFT JOIN `adventureworks2019.Production.WorkOrder` AS b
        ON a.ProductID = b.ProductID
      WHERE EXTRACT(year FROM b.ModifiedDate) = 2011
      GROUP BY 1,2,3
      ORDER BY 1,2 DESC ) 
, prev_qty as (
    SELECT 
    *
    , LEAD (Stock_qty) OVER (PARTITION BY Name ORDER BY Name ASC, month DESC ) AS stock_prev
    FROM data_raw)

SELECT 
* 
, CASE 
    WHEN (Stock_qty/stock_prev -1 )*100.00 IS NULL THEN 0
    WHEN  (Stock_qty/stock_prev -1 )*100.00 <> 0 THEN ROUND ((Stock_qty/stock_prev -1 )*100.00,1) 
    END as diff
FROM prev_qty
ORDER BY Name;



--QUERY 7: Calc Ratio of Stock / Sales in 2011 by product name, by month. Order results by month desc, ratio desc. Round Ratio to 1 decimal
  
with 
sale_info as (
  select 
      extract(month from a.ModifiedDate) as mth 
     , extract(year from a.ModifiedDate) as yr 
     , a.ProductId
     , b.Name
     , sum(a.OrderQty) as sales
  from `adventureworks2019.Sales.SalesOrderDetail` a 
  left join `adventureworks2019.Production.Product` b 
    on a.ProductID = b.ProductID
  where FORMAT_TIMESTAMP("%Y", a.ModifiedDate) = '2011'
  group by 1,2,3,4
), 

stock_info as (
  select
      extract(month from ModifiedDate) as mth 
      , extract(year from ModifiedDate) as yr 
      , ProductId
      , sum(StockedQty) as stock_cnt
  from 'adventureworks2019.Production.WorkOrder'
  where FORMAT_TIMESTAMP("%Y", ModifiedDate) = '2011'
  group by 1,2,3
)

select
      a.*
    , b.stock_cnt as stock  --(*)
    , round(coalesce(b.stock_cnt,0) / sales,2) as ratio
from sale_info a 
full join stock_info b 
  on a.ProductId = b.ProductId
and a.mth = b.mth 
and a.yr = b.yr
order by 1 desc, 7 desc;



--QUERY 8: No of order and value at Pending status in 2014

SELECT  
  EXTRACT(year FROM ModifiedDate) AS year
  , status
  , COUNT (DISTINCT PurchaseOrderID) AS  order_Cnt 
  , sum(TotalDue) as value
FROM `adventureworks2019.Purchasing.PurchaseOrderHeader`
WHERE status= 1 AND EXTRACT(year FROM ModifiedDate) =2014 
GROUP BY 1,2;

