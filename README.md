
# 📊 Adventure Work Bicycle Manufacturer Analysis -SQL, BigQuery

![image](https://github.com/user-attachments/assets/f5d850a1-c561-4cb9-889c-acc5f88b54ce)

 
Author: Nguyễn Thị Ánh Minh 

Date:  2025/01/20

Tools Used: SQL

---
# 📑 Table of Contents

- [📌Background & Overview](#background--overview)

- [📂 Dataset Description & Data Structure](#dataset-description--data-structure)

- [🌈 Main Process](#main-process)
  
- [🔎 Final Conclusions & Recommendations](#-final-conclusions--recommendations)

---
# 📌Background & Overview

## Objective:

**📖 What is this project about?**

This project involves analyzing the AdventureWorks sales dataset, focusing on **sales performance, product analysis, customer retention, and stock management**. Using SQL, we will extract insights from various tables, answer **key business questions**, and provide actionable recommendations.

**💡 What Business Questions will it solve?**

This analysis aims to evaluate the sales and operational performance of a bicycle manufacturing business using SQL. It addresses key questions related to: 

- **Sales Effectives:** Identify top-performing product subcategories and fastest-growing categories to guide sales strategy.

- **Market Insights:** Analyse top territories to support resource allocation and regional planning.

- **Promotion Impact:** Measure the cost and effectiveness of seasonal discounts across subcategories.

- **Customer Behavior:** Evaluate customer retention rates to inform loyalty and remarketing efforts.

- **Inventory Management:** Track monthly stock trends, stock-to-sales ratio, and pending orders to improve supply chain efficiency.
  

***👥 Who is this project for?***

  - **Sales Managers:** To understand which products and territories perform best and identify areas for improvement.
  
  
  - **Product Managers:** To monitor stock levels and ensure optimal inventory management.
  
  
  - **Marketing Teams:** To evaluate the impact of seasonal discounts and identify fast-growing categories.
  
  
 -  **Customer Success Teams:** To track customer retention and take proactive measures.
  
  
 -  **Business Analysts and Data Analysts:** To explore and analyze data for actionable insights.

---

# 📁Dataset Description & Data Structure

## 📌 Data Source 

- **Source**: AdventureWorks 2019 Database is provided by Microsoft

- 🏢 **Overview of AdventureWorks 2019**

  - Database Type: **Relational database**

  - Context: Simulates a consumer goods manufacturing company named Adventure Works Cycles, which specializes in selling bicycles and related accessories.

  - Version: The 2019 edition is updated to align with the latest SQL Server standards, supporting features like temporal tables, graph tables, and more.
  
- **Tables Used:** 7 tables included `Sales.SalesOrderDetail`, `Sales.SalesOrderHeader`, `Sales.SpecialOffer`, `Production.Product`,` Production.ProductSubcategory`, `Production.WorkOrder`, `Purchasing.PurchaseOrderHeader`

-  **Data Sources Description:**

The analysis is based on the AdventureWorks 2019 database. Key tables and their purposes are summarized as follows:

|Table Name	|Description|
| :--- | :--- |
|`Sales.SalesOrderDetail`|Contains detailed information about each product in an order, including quantity, unit price, and discounts. Used to analyze product-level sales performance.|
|`Sales.SalesOrderHeader`|Stores general order information such as customer ID, order date, status, and total due. Supports order-level analysis and filtering by time, region, or status.|
|`Sales.SpecialOffer`|Describes promotional offers, such as discount type. Used to analyze the impact of discounts on sales.|
|`Production.Product`|Provides attributes of each product, including name, standard cost, and list price. Helps link product performance with pricing and classification.|
|`Production.ProductSubcategory`|Groups products into subcategories (e.g., Mountain Bikes, Road Bikes). Supports subcategory-level sales performance and growth tracking.|
|`Production.WorkOrder`|Tracks the production of items, including start and end dates, quantities, and product IDs. Used in inventory flow and production timeline analysis.|
|`Purchasing.PurchaseOrderHeader`|Stores purchase order data related to inventory replenishment. Includes order date, status, vendor, and total amount. Supports inventory planning and stock analysis.|

**💡 Notes:** Tables are joined primarily via `ProductID`, `SalesOrderID`, 'SpecialOfferID`, and `ProductSubcategoryID`, depending on the context.

---
# 🌈Main Process: 

## 1️⃣ Data Preparation (Cleaning & Processing) 

## 2️⃣ Exploratory Data Analysis (EDA)

### SQL Analysis Tasks:
---

### TASK 1: Product Performance in the last 12 months

 - 📌 **Requirement:** What are the top-performing subcategories in terms of quantity, sales value, and order quantity in the last 12 months?

 -  🎯 **Analytical Purpose:** To evaluate product performance by subcategory over the past year. This helps identify high-performing product lines and provides direction for marketing, inventory, and sales strategy.

 -  📝**SQL Query:**

```sql
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
LEFT JOIN `adventureworks2019.Production.Product` as b
    ON a.ProductID= b.ProductID
LEFT JOIN `adventureworks2019.Production.ProductSubcategory` AS c
    ON CAST (b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID 
WHERE DATE(a.ModifiedDate) >= (
  SELECT DATE_SUB(latest_date, INTERVAL 12 MONTH)
  FROM max_date)
GROUP BY period, c.Name 
ORDER BY period DESC, c.Name;
```
 -  📋**Query Explanation:**

    - **Step 1 (CTE - max_date):**
    
     **Find the latest date** in the SalesOrderDetail table. This ensures that the “last 12 months” range is dynamic and **based on actual data**.
    
      - **Step 2 (Main Query):**
    
      Joins the `Sales.SalesOrderDetail` table with:
    
      `Production.Product`: to get the `ProductSubcategoryID`
    
      `Production.ProductSubcategory`: to get the readable subcategory Name
    
      Filters records to only include those in the last 12 months, based on `ModifiedDate`.
    
      Aggregates results:
    
        SUM(OrderQty) → total quantity of items sold per subcategory.
    
        SUM(LineTotal) → total revenue generated.
    
        COUNT(DISTINCT SalesOrderID) → number of unique orders.
    
      Formats the ModifiedDate into a readable month-year string (e.g., "Oct 2013").

 -   **Results Snapshot:**
   
![image](https://github.com/user-attachments/assets/01f69794-ddb6-4550-97c3-542e2422c47e)

 -   **📊 Observation:**

---
### TASK 2: Year-over-Year (YoY) growth in Product subcategory 

- 📌 **Requirement:** Calculate the Year-over-Year (YoY) growth rate in terms of quantity of items sold (OrderQty) for each Product SubCategory, and extract the Top 3 subcategories with the highest growth rate. The results should be rounded to 2 decimal places.

 -  🎯 **Analytical Purpose:**

  - Identify product subcategories with the highest YoY growth to:

  - Prioritize investment in high-growth segments.

  - Understand which product lines are gaining momentum over time.

 - Support strategic planning for sales, inventory, and marketing.
   
 -  📝**SQL Query:**

```sql
WITH data_raw AS (
  SELECT 
    EXTRACT(year FROM a.ModifiedDate) AS year,
    c.Name,
    SUM(a.OrderQty) AS Qty_item
  FROM `adventureworks2019.Sales.SalesOrderDetail` AS a
  LEFT JOIN `adventureworks2019.Sales.Product` AS b
    ON a.ProductID = b.ProductID
  LEFT JOIN `adventureworks2019.Production.ProductSubcategory` AS c
    ON CAST(b.ProductSubcategoryID AS INT) = c.ProductSubcategoryID 
  GROUP BY 1, 2
),
diff_cte AS (
  SELECT 
    year,
    name,
    Qty_item,
    LAG(Qty_item) OVER (PARTITION BY Name ORDER BY year) AS prv_qty,
    ROUND((Qty_item / LAG(Qty_item) OVER (PARTITION BY Name ORDER BY year) - 1), 2) AS qty_diff
  FROM data_raw
),
rank_cte AS (
  SELECT 
    name,
    Qty_item,
    prv_qty,
    qty_diff,
    DENSE_RANK() OVER (ORDER BY qty_diff DESC) AS rank
  FROM diff_cte
  ORDER BY rank 
)
SELECT 
  name,
  Qty_item,
  prv_qty,
  qty_diff
FROM rank_cte
WHERE rank <= 3;
```
 -  📋**Query Explanation:**

   `data_raw` CTE: Aggregates yearly sales quantity (OrderQty) for each subcategory.
   
   `diff_cte`: Calculates previous year's quantity using the LAG() function and computes the YoY growth rate (qty_diff).
   
   `rank_cte`: Ranks the subcategories by highest YoY growth using DENSE_RANK().
   
   Final SELECT: Filters and returns only the top 3 subcategories with the highest growth rates.


 -   **Results Snapshot:**
   
<img width="632" alt="image" src="https://github.com/user-attachments/assets/42a29dde-675c-41a3-a540-eb82133d0d84" />


 -   **📊 Observation:**

   - **Mountain Frames achieved the highest YoY growth of 5.21%**, indicating a significant surge in demand.
  
   - **Socks and Road Frames** also showed **strong performance** with growth rates of **4.21% and 3.89% respectively.**
  
   - These products may benefit from increased marketing efforts or inventory planning to sustain growth momentum.
---
### TASK 3: Top Territories

- 📌 **Requirement:** Identify the top 3 `TerritoryIDs` with the highest total order quantity (OrderQty) for each year.

  - Use ranking by year.

  - If multiple TerritoryIDs have the same order_cnt, do not skip rank numbers (use DENSE_RANK()).



 -  🎯 **Analytical Purpose:** This analysis helps the business understand which sales territories are consistently performing well year over year, allowing management to:

    - Identify top-performing regions.
    
    - Allocate resources effectively.
    
    - Benchmark lower-performing regions.

 -  📝**SQL Query:**
   ```sql
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
```

 -  📋**Query Explanation:**

    **Step 1:** total_qty CTE
    
    Extracts yearly total quantity of orders by each TerritoryID.
    
    Uses:
    
    EXTRACT(year FROM ModifiedDate) to pull out the year.
    
    SUM(a.OrderQty) to count the total ordered quantity.
    
    Joins SalesOrderDetail with SalesOrderHeader to get TerritoryID.
    
   **Step 2:** rank_cte
   
    Applies DENSE_RANK() to assign rankings within each year based on order_cnt (total order quantity).
    
    DENSE_RANK() is used to avoid gaps in ranking when multiple TerritoryIDs have the same total quantity.
   
   **Step 3:** Final Output
   
   Filters for top 3 ranked territories per year using WHERE rank <= 3. 
   
 -   **Results Snapshot:**
<img width="559" alt="image" src="https://github.com/user-attachments/assets/4c7b250e-7819-4d71-803c-66474a58f4d1" />

 -   **📊 Observation:**

    Territory 4 was consistently ranked #1 across all years shown, especially in 2013 with 26,682 orders.

    There’s a noticeable decline in order quantity over years: e.g., Territory 4 went from 26,682 (2013) → 11,632 (2014).
    
    Top 3 ranks are correctly retained for each year, and the use of DENSE_RANK() ensures no skipped ranks when values tie.
    
    Useful for tracking regional sales performance trends and shifts over time
---
### TASK 4: Seasonal Discount Analysis:

- 📌 **Requirement:** Calculate **the total discount cost** for **each product subcategory per year**, only considering **"Seasonal Discount"** offers.

 -  🎯 **Analytical Purpose:**

   This analysis is designed to:
   
   - Evaluate the financial impact of seasonal promotions on each subcategory.
   
   - Identify which product types (e.g., Helmets) benefited most from seasonal discounts.
   
   - Support marketing and pricing strategy optimization for future discount campaigns.
     
 -  📝**SQL Query:**
```sql
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
```
 -  📋**Query Explanation:**

  **Step 1:** data_raw CTE
  Filters only records with a SpecialOffer.Type of "Seasonal Discount".
  
  Calculates the monetary value of the discount per order line:
  
  ini
  Sao chép
  Chỉnh sửa
  discount_cost = DiscountPct × UnitPrice × OrderQty
  Extracts:
  
  The year from ModifiedDate to group data annually.
  
  The subcategory Name from the ProductSubcategory table.
  
** Step 2:** Final Aggregation
  Groups the data by year and subcategory name.
  
  Sums the discount_cost to compute total discount cost per subcategory per year.
  
 -   **Results Snapshot:**

   <img width="511" alt="image" src="https://github.com/user-attachments/assets/9a13d510-edad-4889-b515-adde5fd3bb38" />

 -   **📊 Observation:**
    Helmet products received a significant increase in discount value from 2012 (≈ 827.65) to 2013 (≈ 1606.04), nearly doubling.
    
    This may reflect:
    
    - Higher sales volume of helmets under seasonal promotions.
    
    - Larger discount rates applied in 2013.
    
    - Such insights can guide promotion budget planning and target product categories that respond well to seasonal discounts.
---

### TASK 5: Customer Retention

- 📌 **Requirement:** Perform a Cohort Analysis** to calculate the monthly customer retention in the year 2014 for those whose orders had the status of “Successfully Shipped” (Status = 5).

 -  🎯 **Analytical Purpose:**  The goal is to understand customer retention behavior over time:

    - Identify how many customers returned in subsequent months after their first purchase in 2014.
    
    - Provide insights into customer loyalty, lifecycle, and post-purchase behavior.
    
    - Help marketing/sales teams design better retention strategies.



 -  📝**SQL Query:**
```sql
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
```
 -  📋**Query Explanation:**

`info_cte`:

Filters orders with status = 5 (Successfully Shipped) in 2014.

Extracts the month and year of each order.

Counts the number of distinct orders per customer per month.

`rank_month_cte`:

Assigns a row number to each month a customer made a purchase.

Helps us determine their first purchase month.

`first_month_purchase`:

Extracts the first month of purchase (rank_month = 1) for each customer.

This is treated as the cohort join month.

`all_join_cte`:

Joins the original monthly order data with the cohort month data.

Computes the difference in months between order month and first purchase month (e.g., M-0 for join month, M-1 for month after, etc.).

**Final SELECT:**

Groups by cohort month (month_join) and the time difference (month_diff).

Counts how many unique customers were active in each period relative to their first purchase month.

 -   **Results Snapshot:**

<img width="511" alt="image" src="https://github.com/user-attachments/assets/dd7b1747-7bdb-4b8f-b231-71b69f42caa6" />

 -   **📊 Observation:**

   **M-0 has the highest number of customers** (January: 2,076; February: 1,805; March: 1,918).

   Retention rate drops sharply after the first month, most customers only buy once.

   Some months (like M-3) have a slight increase, possibly due to quarterly promotions.

   Need to improve customer retention through loyalty program, reminder emails, periodic promotions.

---
### TASK 6: Stock Management

- 📌 **Requirement:** Analyze the monthly stock quantity trend in 2011 for each product and calculate the Month-over-Month (MoM) percentage change. The goal is to gain insights into stock movement and identify any significant fluctuations in inventory levels.

 -  🎯 **Analytical Purpose:**

Track the monthly stock quantities for each product in the year 2011.

Calculate the percentage change in stock quantity compared to the previous month (MoM %).

Help the business:

Identify trends or seasonal patterns in inventory.

Detect abnormal spikes or drops in stock.

Support production planning and inventory management decisions.


 -  📝**SQL Query:**
   ```sql
with 
raw_data as (
  select
      extract(month from a.ModifiedDate) as mth 
      , extract(year from a.ModifiedDate) as yr 
      , b.Name
      , sum(StockedQty) as stock_qty

  from `adventureworks2019.Production.WorkOrder` a
  left join `adventureworks2019.Production.Product` b on a.ProductID = b.ProductID
  where FORMAT_TIMESTAMP("%Y", a.ModifiedDate) = '2011'
  group by 1,2,3
  order by 1 desc 
)

select  Name
      , mth, yr 
      , stock_qty
      , stock_prv   
      , round(coalesce((stock_qty /stock_prv -1)*100 ,0) ,1) as diff   
from (                                                                 
      select *
      , lead (stock_qty) over (partition by Name order by mth desc) as stock_prv
      from raw_data
      )
order by 1 asc, 2 desc;
```

 -  📋**Query Explanation:**

Step 1: CTE raw_data

Extracts the month and year from ModifiedDate.

Joins the WorkOrder and Product tables.

Aggregates stock quantities (StockedQty) by month and product.

Filters to include only records from 2011.

Step 2: Main Query

Uses LEAD() window function to fetch the stock quantity of the next month (to simulate comparing the current month to the previous one in descending order).

Computes the MoM % change with the formula
COALESCE(..., 0) is used to handle NULL values where no previous month exists.

 -   **Results Snapshot:**
<img width="881" alt="image" src="https://github.com/user-attachments/assets/08e2806e-5214-4f83-993e-64cec1a6325b" />

 -   **📊 Observation:**
Several products show sharp changes in inventory levels month-over-month, signaling the need for improved forecasting, better inventory planning, or investigation into external factors (e.g., seasonality, promotions, supply chain issues).

---
### TASK 7: Stock-to-Sales Ratio

 📌 **Requirement:** Calculate the Stock-to-Sales Ratio by product name and month in 2011, ordered by month (descending) and ratio (descending). Round ratio to 1 decimal.

 -  🎯 **Analytical Purpose:** To evaluate inventory efficiency by identifying products with unusually high stock levels relative to sales. Helps prioritize inventory clearance or adjust future production.

 -  📝**SQL Query:**
   ```sql
With 
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
```

 -  📋**Query Explanation:**
   - `sale_info`: Sums sales per product per month in 2011.

   - `stock_info`: Sums stock quantity per product per month in 2011.

  - Final SELECT calculates the stock/sales ratio and sorts by latest month and highest ratio.

 -   **Results Snapshot:**
![image](https://github.com/user-attachments/assets/df24f2e2-dfba-4a2a-81e5-73bfde752640)

 -   **📊 Observation:**

  In December 2011, several products had very high stock-to-sales ratios — e.g., HL Mountain Frame - Black, 48 had 27 units in stock but only 1 unit sold, resulting in a 27.0 ratio.
  This indicates potential overstock and low demand, suggesting a need to review inventory or pricing strategies for these items.

--- 

### TASK 8: Pending Orders

- 📌 **Requirement:** How many orders and what is their total value for orders in "Pending" status in 2014?

 -  🎯 **Analytical Purpose:** To help the Purchasing department assess the volume and value of unprocessed (pending) orders in 2014. This insight supports better backlog management and improves procurement efficiency.

 -  📝**SQL Query:**
```sql
SELECT  
  EXTRACT(year FROM ModifiedDate) AS year
  , status
  , COUNT (DISTINCT PurchaseOrderID) AS  order_Cnt 
  , sum(TotalDue) as value
FROM `adventureworks2019.Purchasing.PurchaseOrderHeader`
WHERE status= 1 AND EXTRACT(year FROM ModifiedDate) =2014 
GROUP BY 1,2;
```
 -  📋**Query Explanation:**

Filters data for purchase orders with status = 1 (Pending) in 2014.

Groups results by year and status.

Calculates:

`order_Cnt`: Total distinct pending orders.

`value`: Total due amount of those orders.

 -   **Results Snapshot:**
<img width="556" alt="image" src="https://github.com/user-attachments/assets/6e4c4099-be4c-41c7-8d52-14ecbeccb96a" />

 -   **📊 Observation:**

In 2014, there were 224 purchase orders still in Pending status, totaling nearly 3.87 million USD. This significant amount highlights the need for timely order processing to avoid delays or inventory issues.


--- 
# 🔎 Final Conclusions & Recommendations

Top Subcategories & Growth: Subcategories with the highest growth should be prioritized for marketing campaigns. Slow-growing categories may require product improvements or promotions.


Top Territories: Focusing on the top 3 performing territories each year can help identify best practices for expansion.


Seasonal Discount Optimization: Evaluate the impact of seasonal discounts to ensure they generate sufficient sales without excessive costs.


Customer Retention: Enhance customer loyalty programs to maintain a high retention rate.


Stock Management: Ensure sufficient stock for fast-moving products while avoiding overstocking of slow-moving items.


Pending Orders: Regularly monitor pending orders to minimize delays and improve customer satisfaction.
