                    -- View Data [Customers]
SELECT * FROM Silver.Customers; 
-- ___________________________________________________________

SELECT
    TRY_CAST(TRIM(customer_id) AS INT)             AS customer_id,
    TRIM(cc_num)                                   AS cc_num,
    TRIM(first_name)                               AS first_name,
    TRIM(last_name)                                AS last_name,
    UPPER(TRIM(gender))                            AS gender,
    TRIM(street)                                   AS street,
    TRIM(city)                                     AS city,
    UPPER(TRIM(state))                             AS state,
    REPLACE(TRIM(zip), '.0', '')                   AS zip,
    TRY_CAST(TRIM(lat) AS DECIMAL(9, 6))           AS lat,
    TRY_CAST(TRIM(long) AS DECIMAL(9, 6))          AS long,
    TRY_CAST(TRY_CAST(TRIM(city_pop) AS DECIMAL(18, 0)) AS INT) AS city_pop,
    TRIM(job)                                      AS job,
    TRY_CAST(TRIM(dob) AS DATE)                    AS dob,
    NULLIF(TRIM(loyalty_tier), '')                 AS loyalty_tier,
    LOWER(TRIM(email_domain))                      AS email_domain,
    TRY_CAST(TRIM(signup_date) AS DATE)            AS signup_date
INTO Silver.Customers
FROM Bronze.Customers;

-- ___________________________________________________________
                       -- PK

ALTER TABLE Silver.Customers
ALTER COLUMN customer_id INT NOT NULL;

ALTER TABLE Silver.Customers
ADD CONSTRAINT PK_Silver_Customers PRIMARY KEY (customer_id);

-- ___________________________________________________________
                    -- View Data [Transactions]
SELECT * FROM Silver.Transactions; 

-- ___________________________________________________________

SELECT
    TRY_CAST(TRIM(transaction_id) AS BIGINT)              AS transaction_id,
    TRY_CAST(TRIM(trans_date_trans_time) AS DATETIME2)    AS trans_date_trans_time,
    TRY_CAST(TRIM(customer_id) AS INT)                    AS customer_id,
    TRY_CAST(TRIM(merchant_id) AS INT)                    AS merchant_id,
    TRIM(category)                                        AS category,
    TRY_CAST(TRIM(amt) AS DECIMAL(18, 2))                 AS amt,
    TRY_CAST(TRIM(tax_amt) AS DECIMAL(18, 2))             AS tax_amt,
    TRY_CAST(TRIM(discount_amt) AS DECIMAL(18, 2))        AS discount_amt,
    UPPER(TRIM(currency))                                 AS currency,
    TRIM(payment_method)                                  AS payment_method,
    TRIM(channel)                                         AS channel,
    TRIM(entry_mode)                                      AS entry_mode,
    TRIM(device_type)                                     AS device_type,
    TRIM(transaction_status)                              AS transaction_status,
    TRIM(trans_num)                                       AS trans_num,
    NULLIF(TRIM(session_id), '')                          AS session_id,
    TRY_CAST(TRIM(unix_time) AS BIGINT)                   AS unix_time,
    TRY_CAST(TRIM(is_fraud) AS BIT)                       AS is_fraud
INTO Silver.Transactions
FROM Bronze.Transactions;

-- ___________________________________________________________
                       -- PK
ALTER TABLE Silver.Transactions
ALTER COLUMN transaction_id BIGINT NOT NULL;

ALTER TABLE Silver.Transactions
ADD CONSTRAINT PK_Silver_Transactions PRIMARY KEY (transaction_id);

-- ___________________________________________________________
                    -- View Data [Transactions]
SELECT * FROM Silver.Merchants;

-- ___________________________________________________________

SELECT
    TRY_CAST(TRIM(merchant_id) AS INT)             AS merchant_id,
    TRIM(merchant_name)                            AS merchant_name,
    TRIM(dominant_category)                        AS dominant_category,
    TRIM(merchant_city)                            AS merchant_city,
    UPPER(TRIM(merchant_state))                    AS merchant_state,
    TRY_CAST(TRIM(merchant_lat) AS DECIMAL(9, 6))  AS merchant_lat,
    TRY_CAST(TRIM(merchant_long) AS DECIMAL(9, 6)) AS merchant_long,
    TRY_CAST(TRIM(merchant_since) AS DATE)         AS merchant_since,
    TRY_CAST(TRIM(is_active) AS BIT)               AS is_active
INTO Silver.Merchants
FROM Bronze.Merchants;

-- ___________________________________________________________
                       -- PK

ALTER TABLE Silver.Merchants
ALTER COLUMN merchant_id INT NOT NULL;

ALTER TABLE Silver.Merchants
ADD CONSTRAINT PK_Silver_Merchants PRIMARY KEY (merchant_id);

-- =======================================================================

SELECT 
    'Customers' AS table_name,
    (SELECT COUNT(*) FROM Bronze.Customers) AS bronze_count,
    (SELECT COUNT(*) FROM Silver.Customers) AS silver_count,
    (SELECT COUNT(*) FROM Bronze.Customers) - (SELECT COUNT(*) FROM Silver.Customers) AS diff
UNION ALL
SELECT 
    'Merchants',
    (SELECT COUNT(*) FROM Bronze.Merchants),
    (SELECT COUNT(*) FROM Silver.Merchants),
    (SELECT COUNT(*) FROM Bronze.Merchants) - (SELECT COUNT(*) FROM Silver.Merchants)
UNION ALL
SELECT 
    'Transactions',
    (SELECT COUNT(*) FROM Bronze.Transactions),
    (SELECT COUNT(*) FROM Silver.Transactions),
    (SELECT COUNT(*) FROM Bronze.Transactions) - (SELECT COUNT(*) FROM Silver.Transactions);