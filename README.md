**📊 E-Commerce Customer Churn Analysis – Project Report**

🔍 **Project Objective**

The goal of this project is to analyze customer churn behavior in an e-commerce platform by cleaning raw customer data, improving data quality, and extracting meaningful business insights that help understand why customers leave and how engagement can be improved.

🧹 **Data Cleaning & Pre-Processing**

* Handled missing values using appropriate statistical methods:

* Numerical fields were filled using mean values

* Categorical and count-based fields were filled using most frequent values (mode)

* Removed outliers related to unrealistic warehouse-to-home distances to maintain data accuracy

* Standardized inconsistent text values (e.g., payment modes, device types) to ensure uniform reporting

* Renamed columns for better readability and business clarity

* Created derived fields such as:

* ComplaintReceived (Yes/No)

* ChurnStatus (Churned / Active)

Removed redundant columns after transformation to keep the dataset optimized

🧠 **Feature Engineering**

* Converted binary indicators into human-readable categories

* Grouped customers based on distance from warehouse to analyze churn impact

* Added business-friendly attributes to support reporting and dashboarding

📈 **Exploratory Data Analysis (EDA)**

* Key insights were derived by analyzing:

* Churned vs Active customer distribution

* Relationship between complaints and churn

* Customer tenure and cashback trends among churned users

* Impact of city tier, order category, and payment mode on churn

* Coupon usage patterns across genders

* Device usage, app engagement, and satisfaction scores

* Order behavior based on marital status and city tiers

🔁 **Customer Returns Analysis**

* Designed a separate Customer Returns table to track refunds

* Linked return data with customer profiles using customer IDs

* Analyzed churned customers who had complaints and product returns

* Evaluated refund amounts and return trends for dissatisfied customers

💡 **Business Insights Generated**

* Customers who raised complaints had a significantly higher chance of churning

* Certain product categories and city tiers showed higher churn concentration

* Payment mode preferences differed between churned and active customers

* High coupon usage and low satisfaction scores were strong churn indicators

* Customers far from warehouses showed higher churn probability

🛠 **Tools & Skills Used**

* MySQL for data cleaning, transformation, and analysis

* SQL Joins & Aggregations for customer behavior analysis

* Data Modeling & Feature Engineering

* Business Analytics & Insight Generation

✅ **Outcome**

This project successfully transformed raw e-commerce data into a clean, analysis-ready dataset and delivered actionable insights that can help businesses reduce churn, improve customer satisfaction, and optimize operational strategies.
