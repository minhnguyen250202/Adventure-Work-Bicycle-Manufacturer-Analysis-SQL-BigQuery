# Bicycle-Manufacturer---SQL-BigQuery
This project demonstrated my SQL skills. I utilized BigQuery to perform advanced data analysis on e-commerce transactions, including sales growth tracking, customer retention (Cohort Analysis), seasonal discount impact, stock trends, and employee performance ranking.

---
# 📊 Project Title: Bicycle Manufacturer -SQL,BigQuery

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

**Objective:**

***📖 What is this project about?***

This project involves analyzing the AdventureWorks sales dataset, focusing on sales performance, product analysis, customer retention, and stock management. Using SQL, we will extract insights from various tables, answer key business questions, and provide actionable recommendations.

***💡 What Business Questions will it solve?***

Product Performance: What are the top-performing subcategories in terms of quantity, sales value, and order quantity in the last 12 months?


Category Growth: Which subcategories have experienced the highest Year-over-Year (YoY) growth in item quantity?


Top Territories: What are the top 3 territories with the highest order quantities each year?


Seasonal Discount Analysis: What is the total discount cost applied under seasonal discounts for each subcategory?


Customer Retention: What is the retention rate of customers with "Successfully Shipped" orders in 2014?


Stock Management: What is the monthly trend of stock levels and their Month-over-Month (MoM) percentage change in 2011?


Stock-to-Sales Ratio: What is the Stock/Sales ratio by product and by month in 2011?


Pending Orders: How many orders and what is their total value for orders in "Pending" status in 2014?



***👥 Who is this project for?***

Sales Managers: To understand which products and territories perform best and identify areas for improvement.


Product Managers: To monitor stock levels and ensure optimal inventory management.


Marketing Teams: To evaluate the impact of seasonal discounts and identify fast-growing categories.


Customer Success Teams: To track customer retention and take proactive measures.


Business Analysts and Data Analysts: To explore and analyze data for actionable insights.

---

# 📁 Dataset Description & Data Structure

Source: AdventureWorks Database - Microsoft


Format: SQL- BigQuery

Tables Used: 

- Sales.SalesOrderDetail
- Sales.Product
- Sales.SalesOrderHeader
- Sales.SpecialOffer
- Production.ProductSubcategory
- Production.ProductSubcategory
- Production.WorkOrder
- Production.Product
- Purchasing.PurchaseOrderHeader

Table Schema & Data Snapshot

![image](https://github.com/user-attachments/assets/b5ad09c4-cc2e-4ccc-830c-095c95e1cc38)

![image](https://github.com/user-attachments/assets/aeb6a7d6-ba3b-4f39-9f84-b12aa5f62417)


![image](https://github.com/user-attachments/assets/c3671894-68a9-466c-8c33-7352b7683300)

--- 
# 📊 Final Conclusion & Recommendations

Top Subcategories & Growth: Subcategories with the highest growth should be prioritized for marketing campaigns. Slow-growing categories may require product improvements or promotions.


Top Territories: Focusing on the top 3 performing territories each year can help identify best practices for expansion.


Seasonal Discount Optimization: Evaluate the impact of seasonal discounts to ensure they generate sufficient sales without excessive costs.


Customer Retention: Enhance customer loyalty programs to maintain a high retention rate.


Stock Management: Ensure sufficient stock for fast-moving products while avoiding overstocking of slow-moving items.


Pending Orders: Regularly monitor pending orders to minimize delays and improve customer satisfaction.
