create database ecomm;
USE ecomm;
CREATE TABLE customer_churn(
    CustomerID                  INT  PRIMARY KEY,
    Churn                       BIT,
    Tenure                      INT,
    PreferredLoginDevice        VARCHAR(20),
    CityTier                    INT,
    WarehouseToHome             INT,
    PreferredPaymentMode        VARCHAR(20),
    Gender                      ENUM('Male','Female'),
    HourSpendOnApp              INT,
    NumberOfDeviceRegistered    INT,
    PreferedOrderCat            VARCHAR(20),
    SatisfactionScore           INT,
    MaritalStatus               VARCHAR(10),
    NumberOfAddress             INT,
    Complain                    BIT,
    OrderAmountHikeFromlastYear INT,
    CouponUsed                  INT,
    OrderCount                  INT,
    DaySinceLastOrder           INT,
    CashbackAmount              INT
    );
-- 1) compute mean (rounded)
SELECT ROUND(AVG(WarehouseToHome))
INTO @mean_wth
FROM customer_churn
WHERE WarehouseToHome IS NOT NULL;

-- 2) capture target rows (only the NULLs) into a temp table
CREATE TEMPORARY TABLE tmp_wth_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID
FROM customer_churn
WHERE WarehouseToHome IS NULL;

-- 3) update using the key in WHERE (passes safe update)
UPDATE customer_churn
SET WarehouseToHome = @mean_wth
WHERE CustomerID IN (SELECT CustomerID FROM tmp_wth_ids);

-- 4) clean up
DROP TEMPORARY TABLE tmp_wth_ids;

SELECT ROUND(AVG(HourSpendOnApp))
INTO @mean_hrs
FROM customer_churn
WHERE HourSpendOnApp IS NOT NULL;

CREATE TEMPORARY TABLE tmp_hrs_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID
FROM customer_churn
WHERE HourSpendOnApp IS NULL;

UPDATE customer_churn
SET HourSpendOnApp = @mean_hrs
WHERE CustomerID IN (SELECT CustomerID FROM tmp_hrs_ids);

DROP TEMPORARY TABLE tmp_hrs_ids;

SELECT ROUND(AVG(OrderAmountHikeFromlastYear))
INTO @mean_hike
FROM customer_churn
WHERE OrderAmountHikeFromlastYear IS NOT NULL;

CREATE TEMPORARY TABLE tmp_hike_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID
FROM customer_churn
WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE customer_churn
SET OrderAmountHikeFromlastYear = @mean_hike
WHERE CustomerID IN (SELECT CustomerID FROM tmp_hike_ids);

DROP TEMPORARY TABLE tmp_hike_ids;

SELECT ROUND(AVG(DaySinceLastOrder))
INTO @mean_last
FROM customer_churn
WHERE DaySinceLastOrder IS NOT NULL;

CREATE TEMPORARY TABLE tmp_last_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID
FROM customer_churn
WHERE DaySinceLastOrder IS NULL;

UPDATE customer_churn
SET DaySinceLastOrder = @mean_last
WHERE CustomerID IN (SELECT CustomerID FROM tmp_last_ids);

DROP TEMPORARY TABLE tmp_last_ids;

SELECT Tenure
INTO @mode_tenure
FROM customer_churn
WHERE Tenure IS NOT NULL
GROUP BY Tenure
ORDER BY COUNT(*) DESC
LIMIT 1;

CREATE TEMPORARY TABLE tmp_tenure_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID FROM customer_churn WHERE Tenure IS NULL;

UPDATE customer_churn
SET Tenure = @mode_tenure
WHERE CustomerID IN (SELECT CustomerID FROM tmp_tenure_ids);

DROP TEMPORARY TABLE tmp_tenure_ids;

SELECT CouponUsed
INTO @mode_coupon
FROM customer_churn
WHERE CouponUsed IS NOT NULL
GROUP BY CouponUsed
ORDER BY COUNT(*) DESC
LIMIT 1;

CREATE TEMPORARY TABLE tmp_coupon_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID FROM customer_churn WHERE CouponUsed IS NULL;

UPDATE customer_churn
SET CouponUsed = @mode_coupon
WHERE CustomerID IN (SELECT CustomerID FROM tmp_coupon_ids);

DROP TEMPORARY TABLE tmp_coupon_ids;

SELECT OrderCount
INTO @mode_ordercount
FROM customer_churn
WHERE OrderCount IS NOT NULL
GROUP BY OrderCount
ORDER BY COUNT(*) DESC
LIMIT 1;

CREATE TEMPORARY TABLE tmp_order_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID FROM customer_churn WHERE OrderCount IS NULL;

UPDATE customer_churn
SET OrderCount = @mode_ordercount
WHERE CustomerID IN (SELECT CustomerID FROM tmp_order_ids);

DROP TEMPORARY TABLE tmp_order_ids;

SELECT 
  SUM(WarehouseToHome IS NULL) AS Missing_WarehouseToHome,
  SUM(HourSpendOnApp IS NULL) AS Missing_HourSpendOnApp,
  SUM(OrderAmountHikeFromlastYear IS NULL) AS Missing_OrderAmountHike,
  SUM(DaySinceLastOrder IS NULL) AS Missing_DaySinceLastOrder,
  SUM(Tenure IS NULL) AS Missing_Tenure,
  SUM(CouponUsed IS NULL) AS Missing_CouponUsed,
  SUM(OrderCount IS NULL) AS Missing_OrderCount,
  MAX(WarehouseToHome) AS Max_WarehouseToHome
FROM customer_churn;

DELETE FROM customer_churn
WHERE CustomerID IN (
    SELECT CustomerID
    FROM (
        SELECT CustomerID
        FROM customer_churn
        WHERE WarehouseToHome > 100
    ) AS sub
);

SELECT MAX(WarehouseToHome) AS Max_WarehouseToHome
FROM customer_churn;

-- Replace "Phone" → "Mobile Phone"
UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone'
  AND CustomerID > 0;

-- Replace "Mobile" → "Mobile Phone"
UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone'
  AND CustomerID > 0;

-- Replace "COD" → "Cash on Delivery"
UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD'
  AND CustomerID > 0;

-- Replace "CC" → "Credit Card"
UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC'
  AND CustomerID > 0;
  
-- Column Renaming
ALTER TABLE customer_churn
CHANGE COLUMN PreferedOrderCat PreferredOrderCat VARCHAR(100);
ALTER TABLE customer_churn
CHANGE COLUMN HourSpendOnApp HoursSpentOnApp INT;

-- Add new column
ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(10);


-- Add new column 
ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(10);

-- Capture IDs
CREATE TEMPORARY TABLE tmp_complain_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID FROM customer_churn;

-- Update with CASE
UPDATE customer_churn
SET ComplaintReceived = CASE 
    WHEN Complain = 1 THEN 'Yes'
    ELSE 'No'
END
WHERE CustomerID IN (SELECT CustomerID FROM tmp_complain_ids);

-- Clean up
DROP TEMPORARY TABLE tmp_complain_ids;

-- Add new column 
ALTER TABLE customer_churn
ADD COLUMN ChurnStatus VARCHAR(10);

-- Capture IDs
CREATE TEMPORARY TABLE tmp_churn_ids (CustomerID INT PRIMARY KEY)
AS
SELECT CustomerID FROM customer_churn;

-- Update with CASE
UPDATE customer_churn
SET ChurnStatus = CASE 
    WHEN Churn = 1 THEN 'Churned'
    ELSE 'Active'
END
WHERE CustomerID IN (SELECT CustomerID FROM tmp_churn_ids);

-- Clean up
DROP TEMPORARY TABLE tmp_churn_ids;

SELECT DISTINCT ComplaintReceived FROM customer_churn;
SELECT DISTINCT ChurnStatus FROM customer_churn;

ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

DESCRIBE customer_churn;

-- Data Exploration and Analysis:

-- 1. Count of Churned vs Active Customers
SELECT 
    ChurnStatus, COUNT(*) AS CustomerCount
FROM
    customer_churn
GROUP BY ChurnStatus;
-- 2. Average Tenure & Total Cashback of Churned Customers
SELECT 
	AVG(Tenure) AS AvgTenure,
    SUM(CashbackAmount) AS TotalCashback
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- 3. Percentage of Churned Customers Who Complained
SELECT 
    ROUND(
        (SUM(CASE WHEN ComplaintReceived = 'Yes' THEN 1 ELSE 0 END) 
         / COUNT(*)) * 100, 2
    ) AS PctChurnedWithComplaint
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- 4. City Tier with Highest Number of Churned Customers (Laptop & Accessory Orders)
SELECT CityTier, COUNT(*) AS ChurnedCount
FROM customer_churn
WHERE ChurnStatus = 'Churned'
  AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY ChurnedCount DESC
LIMIT 1;

-- 5. Most Preferred Payment Mode Among Active Customers
SELECT PreferredPaymentMode, COUNT(*) AS ModeCount
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY ModeCount DESC
LIMIT 1;

-- 6.Total Order Amount Hike (Last Year) for Single Customers Who Prefer Mobile Phones
SELECT SUM(OrderAmountHikeFromlastYear) AS TotalHike
FROM customer_churn
WHERE MaritalStatus = 'Single'
  AND PreferredOrderCat = 'Mobile Phone';

-- 7.Average Number of Devices Registered (UPI Users)
SELECT AVG(NumberOfDeviceRegistered) AS AvgDevices
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

-- 8.City Tier with the Highest Number of Customers
SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;

-- 9.Gender That Utilized the Highest Number of Coupons
SELECT Gender, SUM(CouponUsed) AS TotalCoupons
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCoupons DESC
LIMIT 1;

-- 10. Customers Count & Max Hours Spent by Order Category
SELECT PreferredOrderCat, 
       COUNT(*) AS CustomerCount,
       MAX(HoursSpentOnApp) AS MaxHours
FROM customer_churn
GROUP BY PreferredOrderCat;

-- 11.Total Order Count for Customers Using Credit Cards with Max Satisfaction Score
SELECT SUM(OrderCount) AS TotalOrders
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);

-- 12. Average Satisfaction Score of Customers Who Complained
SELECT AVG(SatisfactionScore) AS AvgSatisfactionWithComplaints
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- 13. Preferred Order Category of Customers Who Used More Than 5 Coupons
SELECT PreferredOrderCat, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat
ORDER BY CustomerCount DESC;

-- 14. Top 3 Order Categories with Highest Avg Cashback
SELECT PreferredOrderCat, AVG(CashbackAmount) AS AvgCashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY AvgCashback DESC
LIMIT 3;

-- 15.Preferred Payment Modes of Customers with Avg Tenure = 10 and Orders > 500
SELECT PreferredPaymentMode, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE Tenure = 10
  AND OrderCount > 500
GROUP BY PreferredPaymentMode;

-- 16.Churn Status by Distance Category
SELECT 
    CASE 
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory, ChurnStatus;


-- 17.Married, City Tier-1 Customers With Above-Average Orders
SELECT *
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn);
  
-- a)Create customer_returns Table and Insert Data
CREATE TABLE ecomm.customer_returns (
    ReturnID INT PRIMARY KEY,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES customer_churn(CustomerID)
);

-- Insert sample return records
INSERT INTO ecomm.customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);

-- b) Display Return + Customer Details (Churned + Complained)
SELECT c.CustomerID, c.ChurnStatus, c.ComplaintReceived,
       c.PreferredOrderCat, c.PreferredPaymentMode, c.Tenure,
       r.ReturnID, r.ReturnDate, r.RefundAmount
FROM customer_churn c
JOIN customer_returns r
  ON c.CustomerID = r.CustomerID
WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes';