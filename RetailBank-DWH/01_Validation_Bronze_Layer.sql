-- CREATE DATABASE BankCard;

USE BankCard;
GO

-- ___________________________________________________________

-- View Data
SELECT * FROM Bronze.Customers; 

-- ___________________________________________________________

-- Customers Table --> 1. Nulls
SELECT
	SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS BlankCustomerID,
	SUM(CASE WHEN cc_num IS NULL OR cc_num = '' THEN 1 ELSE 0 END) AS BlankCCNumber,
	SUM(CASE WHEN first_name IS NULL OR first_name = '' THEN 1 ELSE 0 END) AS BlankFirstName,
	SUM(CASE WHEN last_name IS NULL OR last_name = '' THEN 1 ELSE 0 END) AS BlankLastName,
	SUM(CASE WHEN gender IS NULL OR gender = '' THEN 1 ELSE 0 END) AS BlankGender,
	SUM(CASE WHEN state IS NULL OR state = '' THEN 1 ELSE 0 END) AS BlankState,
	SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS BlankCity,
	SUM(CASE WHEN job IS NULL OR job = '' THEN 1 ELSE 0 END) AS BlankJob,
	SUM(CASE WHEN dob IS NULL OR dob = '' THEN 1 ELSE 0 END) AS BlankDOB,
	SUM(CASE WHEN loyalty_tier IS NULL OR loyalty_tier = '' THEN 1 ELSE 0 END) AS BlankLoyaltyTier,
	SUM(CASE WHEN signup_date IS NULL OR signup_date = '' THEN 1 ELSE 0 END) AS BlankSignupDate
FROM Bronze.Customers;

-- ___________________________________________________________

-- 2. Values that fail numrical conversion

SELECT 
    customer_id,
    dob,
    signup_date
FROM Bronze.Customers
WHERE TRY_CAST(customer_id AS INT) IS NULL
   OR TRY_CAST(dob AS DATE) IS NULL
   OR TRY_CAST(signup_date AS DATE) IS NULL;

-- ___________________________________________________________

-- 3. Out of Range --> Date of Birth for Customers

SELECT 
    customer_id,
    dob,
    signup_date
FROM Bronze.Customers
WHERE TRY_CAST(signup_date AS DATE) > CAST(GETDATE() AS DATE) OR
    (
       TRY_CAST(signup_date AS DATE) IS NOT NULL
       AND TRY_CAST(dob AS DATE) IS NOT NULL
       AND TRY_CAST(signup_date AS DATE) < TRY_CAST(dob AS DATE)
   );

-- signup_date is earlier than dob for a few rows


-- ___________________________________________________________

-- 4. Inconsistent categorical values

SELECT -- Gender
    DISTINCT(gender),
    COUNT(*) AS Count_Gender
FROM Bronze.Customers
GROUP BY gender;

-- __________________

SELECT --> loyalty_tier
    loyalty_tier,
    COUNT(*) AS Cnt
FROM Bronze.Customers
GROUP BY loyalty_tier;    --> Issued

-- __________________

SELECT --> state
    state,
    COUNT(*) AS Cnt
FROM Bronze.Customers
GROUP BY state;

-- ___________________________________________________________

-- 5. Duplicates IDs - No Dup

SELECT 
    customer_id,
    COUNT(*) AS CNT
FROM Bronze.Customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- ___________________________________________________________

-- 6. Total rows count

SELECT COUNT(*) AS total_rows_customers
FROM Bronze.Customers;

-- 7. Orphan transactions (Customers)

SELECT COUNT(*) AS orphan_customers
FROM Bronze.Transactions AS t
LEFT JOIN Bronze.Customers AS c
    ON TRY_CAST(c.customer_id AS INT) = TRY_CAST(t.customer_id AS INT)
WHERE c.customer_id IS NULL;


-- __________________________________________________________

-- View Data
SELECT * FROM Bronze.Transactions; 

-- ___________________________________________________________

-- Transactions Table --> 1. Nulls

SELECT
    SUM(CASE WHEN transaction_id IS NULL OR transaction_id = '' THEN 1 ELSE 0 END) AS BlankTransactionID,
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS BlankCustomerID,
    SUM(CASE WHEN merchant_id IS NULL OR merchant_id = '' THEN 1 ELSE 0 END) AS BlankMerchantID,
    SUM(CASE WHEN trans_date_trans_time IS NULL OR trans_date_trans_time = '' THEN 1 ELSE 0 END) AS BlankTransDate,
    SUM(CASE WHEN amt IS NULL OR amt = '' THEN 1 ELSE 0 END) AS BlankAmount,
    SUM(CASE WHEN category IS NULL OR category = '' THEN 1 ELSE 0 END) AS BlankCategory,
    SUM(CASE WHEN transaction_status IS NULL OR transaction_status = '' THEN 1 ELSE 0 END) AS BlankStatus,
    SUM(CASE WHEN is_fraud IS NULL OR is_fraud = '' THEN 1 ELSE 0 END) AS BlankIsFraud
FROM Bronze.Transactions;

-- ___________________________________________________________

-- 2. Values that fail numrical conversion
SELECT 
    transaction_id,
    customer_id,
    merchant_id,
    trans_date_trans_time,
    amt,
    is_fraud
FROM Bronze.Transactions
WHERE TRY_CAST(transaction_id AS INT) IS NULL
   OR TRY_CAST(customer_id AS INT) IS NULL
   OR TRY_CAST(merchant_id AS INT) IS NULL
   OR TRY_CAST(amt AS DECIMAL(18, 2)) IS NULL
   OR TRY_CAST(trans_date_trans_time AS DATETIME2) IS NULL
   OR TRY_CAST(is_fraud AS BIT) IS NULL;

-- ___________________________________________________________

-- 3. Out of Range

SELECT 
    transaction_id,
    customer_id,
    amt,
    trans_date_trans_time
FROM Bronze.Transactions
WHERE TRY_CAST(amt AS DECIMAL(18, 2)) <= 0
   OR TRY_CAST(trans_date_trans_time AS DATETIME2) > GETDATE();

-- ___________________________________________________________

-- 4. Inconsistent categorical values

SELECT --> category
    category,
    COUNT(*) AS Cnt
FROM Bronze.Transactions
GROUP BY category;

-- __________________

SELECT --> transaction_status
    transaction_status,
    COUNT(*) AS Cnt
FROM Bronze.Transactions
GROUP BY transaction_status;

-- __________________

SELECT --> is_fraud
    is_fraud,
    COUNT(*) AS Cnt
FROM Bronze.Transactions
GROUP BY is_fraud;

-- ___________________________________________________________

-- 5. Duplicates IDs --> No Dup

SELECT 
    transaction_id,
    COUNT(*) AS CNT
FROM Bronze.Transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- ___________________________________________________________

-- 6. Total rows count

SELECT COUNT(*) AS total_rows_transactions
FROM Bronze.Transactions;

-- 7. Check if a single merchant_id has multiple distinct transaction categories

SELECT 
    merchant_id,
    COUNT(DISTINCT category) AS distinct_category_count
FROM Bronze.Transactions
GROUP BY merchant_id
HAVING COUNT(DISTINCT category) > 1
ORDER BY distinct_category_count DESC;
-- __________________________________________________________

-- View Data
SELECT * FROM Bronze.Merchants; 

-- ___________________________________________________________

-- Merchants Table --> 1. Nulls

SELECT
    SUM(CASE WHEN merchant_id IS NULL OR merchant_id = '' THEN 1 ELSE 0 END) AS BlankMerchantID,
    SUM(CASE WHEN merchant_name IS NULL OR merchant_name = '' THEN 1 ELSE 0 END) AS BlankMerchantName,
    SUM(CASE WHEN dominant_category IS NULL OR dominant_category = '' THEN 1 ELSE 0 END) AS BlankDominantCategory,
    SUM(CASE WHEN merchant_city IS NULL OR merchant_city = '' THEN 1 ELSE 0 END) AS BlankMerchantCity,
    SUM(CASE WHEN merchant_state IS NULL OR merchant_state = '' THEN 1 ELSE 0 END) AS BlankMerchantState,
    SUM(CASE WHEN merchant_since IS NULL OR merchant_since = '' THEN 1 ELSE 0 END) AS BlankMerchantSince,
    SUM(CASE WHEN is_active IS NULL OR is_active = '' THEN 1 ELSE 0 END) AS BlankIsActive
FROM Bronze.Merchants;

-- ___________________________________________________________

-- 2. Values that fail numrical conversion

SELECT
    merchant_id,
    merchant_since,
    is_active
FROM Bronze.Merchants
WHERE TRY_CAST(merchant_id AS INT) IS NULL
   OR TRY_CAST(merchant_since AS DATE) IS NULL
   OR TRY_CAST(is_active AS BIT) IS NULL;

-- ___________________________________________________________

SELECT 
    MIN(TRY_CAST(merchant_since AS DATE)) AS Earliest_Date,
    MAX(TRY_CAST(merchant_since AS DATE)) AS Latest_Date
FROM Bronze.Merchants;

-- 3. Out of Range

SELECT 
    merchant_id,
    merchant_name,
    merchant_since
FROM Bronze.Merchants
WHERE TRY_CAST(merchant_since AS DATE) > CAST(GETDATE() AS DATE) OR YEAR(TRY_CAST(merchant_since AS DATE)) < 2010;
--> Accordin' to earliest year

-- ___________________________________________________________

-- 4. Inconsistent categorical values

SELECT dominant_category, COUNT(*) AS Cnt -- misc_net? or music
FROM Bronze.Merchants
GROUP BY dominant_category;

-- ________________

SELECT is_active, COUNT(*) AS Cnt
FROM Bronze.Merchants
GROUP BY is_active;

-- ___________________________________________________________

-- 5. Duplicates IDs --> No Dup
SELECT 
    merchant_id,
    COUNT(*) AS CNT
FROM Bronze.Merchants
GROUP BY merchant_id
HAVING COUNT(*) > 1;

-- ___________________________________________________________

-- 6. Total rows count

SELECT COUNT(*) AS total_rows_merchants
FROM Bronze.Merchants;

-- 7. Orphan transactions (Merchants)
SELECT COUNT(*) AS orphan_merchants
FROM Bronze.Transactions AS t
LEFT JOIN Bronze.Merchants AS m
    ON TRY_CAST(m.merchant_id AS INT) = TRY_CAST(t.merchant_id AS INT)
WHERE m.merchant_id IS NULL;