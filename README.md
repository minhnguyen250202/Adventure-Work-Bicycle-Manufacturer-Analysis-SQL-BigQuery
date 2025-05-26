
# 📊 Adventure Work Bicycle Manufacturer Analysis -SQL, BigQuery

![image](https://github.com/user-attachments/assets/f5d850a1-c561-4cb9-889c-acc5f88b54ce)

 
Author: Nguyễn Thị Ánh Minh 

Date:  2025/01/20

Tools Used: SQL

---
# 📑 Table of Contents

📌 Background & Overview

📂 Dataset Description & Data Structure

🔎 Final Conclusion & Recommendations

---
# 📌 Background & Overview

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

Sales Managers: To understand which products and territories perform best and identify areas for improvement.


Product Managers: To monitor stock levels and ensure optimal inventory management.


Marketing Teams: To evaluate the impact of seasonal discounts and identify fast-growing categories.


Customer Success Teams: To track customer retention and take proactive measures.


Business Analysts and Data Analysts: To explore and analyze data for actionable insights.

---

# 📁 Dataset Description & Data Structure

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

#### TASK 1: Product Performance 
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
    
      Find the latest date in the SalesOrderDetail table. This ensures that the “last 12 months” range is dynamic and based on actual data.
    
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
# 📊 Final Conclusion & Recommendations

Top Subcategories & Growth: Subcategories with the highest growth should be prioritized for marketing campaigns. Slow-growing categories may require product improvements or promotions.


Top Territories: Focusing on the top 3 performing territories each year can help identify best practices for expansion.


Seasonal Discount Optimization: Evaluate the impact of seasonal discounts to ensure they generate sufficient sales without excessive costs.


Customer Retention: Enhance customer loyalty programs to maintain a high retention rate.


Stock Management: Ensure sufficient stock for fast-moving products while avoiding overstocking of slow-moving items.


Pending Orders: Regularly monitor pending orders to minimize delays and improve customer satisfaction.
