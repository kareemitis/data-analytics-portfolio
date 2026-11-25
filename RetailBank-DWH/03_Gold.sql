SELECT 
    MIN(TRY_CAST(merchant_since AS DATE)) AS Earliest_Date,
    MAX(TRY_CAST(merchant_since AS DATE)) AS Latest_Date
FROM Bronze.Merchants;

-- =================  DimDate  =================

CREATE TABLE Gold.DimDate (
    datekey     INT         NOT NULL PRIMARY KEY,
    full_date   DATE        NOT NULL,
    [year]      INT         NOT NULL,
    [quarter]   INT         NOT NULL,
    [month]     INT         NOT NULL,
    month_name  VARCHAR(20) NOT NULL,
    [day]       INT         NOT NULL,
    day_name    VARCHAR(20) NOT NULL,
    is_weekend  BIT         NOT NULL
);
GO

-- =================  Earliest and latest Transaction  =================

SELECT 
    MIN(CAST(trans_date_trans_time AS DATE)) AS Min_date,
    MAX(CAST(trans_date_trans_time AS DATE)) AS Max_date
FROM Silver.Transactions;

-- =================  Fillin' DimDate  =================

DECLARE @start_date DATE, @end_date DATE, @current_date DATE;

SELECT 
    @start_date = MIN(CAST(trans_date_trans_time AS DATE)),
    @end_date   = MAX(CAST(trans_date_trans_time AS DATE))
FROM Silver.Transactions;

SET @current_date = @start_date;

SELECT @start_date AS start_date, @end_date AS end_date, @current_date AS [current_date];

WHILE @current_date <= @end_date
BEGIN
    INSERT INTO Gold.DimDate (
        datekey,
        full_date,
        [year],
        [quarter],
        [month],
        month_name,
        [day],
        day_name,
        is_weekend
    )
    VALUES (
        CAST(FORMAT(@current_date, 'yyyyMMdd') AS INT),
        @current_date,
        YEAR(@current_date),
        DATEPART(QUARTER, @current_date),
        MONTH(@current_date),
        DATENAME(MONTH, @current_date),
        DAY(@current_date),
        DATENAME(WEEKDAY, @current_date),
        CASE 
            WHEN DATEPART(WEEKDAY, @current_date) IN (1, 7) THEN 1 
            ELSE 0 
        END
    );

    SET @current_date = DATEADD(DAY, 1, @current_date);
END;

-- =================  Checking DimDate' values  =================

SELECT * FROM Gold.DimDate;

--           ===============================

-- =================  DimCustomer  =================

SELECT *
INTO Gold.DimCustomer
FROM Silver.Customers;

ALTER TABLE Gold.DimCustomer
ALTER COLUMN customer_id INT NOT NULL;

ALTER TABLE Gold.DimCustomer
ADD CONSTRAINT PK_DimCustomer PRIMARY KEY (customer_id);

--           ===============================

-- =================  DimMerchant  =================

SELECT *
INTO Gold.DimMerchant
FROM Silver.Merchants;

ALTER TABLE Gold.DimMerchant
ALTER COLUMN merchant_id INT NOT NULL;

ALTER TABLE Gold.DimMerchant
ADD CONSTRAINT PK_DimMerchant PRIMARY KEY (merchant_id);

--           ===============================

-- =================  FactTransactions  =================

SELECT
    t.transaction_id,
    CAST(CONVERT(CHAR(8), CAST(t.trans_date_trans_time AS DATE), 112) AS INT) AS datekey,
    t.trans_date_trans_time,
    t.customer_id,
    t.merchant_id,
    t.category,
    t.amt,
    t.tax_amt,
    t.discount_amt,
    t.currency,
    t.payment_method,
    t.channel,
    t.entry_mode,
    t.device_type,
    t.transaction_status,
    t.trans_num,
    t.session_id,
    t.unix_time,
    t.is_fraud
INTO Gold.FactTransactions
FROM Silver.Transactions AS t;

ALTER TABLE Gold.FactTransactions
ALTER COLUMN transaction_id BIGINT NOT NULL;

ALTER TABLE Gold.FactTransactions
ADD CONSTRAINT PK_FactTransactions PRIMARY KEY (transaction_id);

--           ===============================

-- =================  1. FK --> DimDate  =================

ALTER TABLE Gold.FactTransactions
ADD CONSTRAINT FK_FactTransactions_DimDate
    FOREIGN KEY (datekey) REFERENCES Gold.DimDate (datekey);

-- =================  2. FK --> DimCustomer  =================

ALTER TABLE Gold.FactTransactions
ADD CONSTRAINT FK_FactTransactions_DimCustomer
    FOREIGN KEY (customer_id) REFERENCES Gold.DimCustomer (customer_id);

-- =================  3. FK --> FactTransactions  =================

ALTER TABLE Gold.FactTransactions
ADD CONSTRAINT FK_FactTransactions_DimMerchant
    FOREIGN KEY (merchant_id) REFERENCES Gold.DimMerchant (merchant_id);

--           ===============================

-- =================  Indexes  =================

CREATE INDEX IX_FactTransactions_DateKey
    ON Gold.FactTransactions (datekey);

CREATE INDEX IX_FactTransactions_CustomerId
    ON Gold.FactTransactions (customer_id);

CREATE INDEX IX_FactTransactions_MerchantId
    ON Gold.FactTransactions (merchant_id);