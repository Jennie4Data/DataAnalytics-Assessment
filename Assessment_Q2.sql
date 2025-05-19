-- Step 1: Count transactions per user per month
WITH monthly_transactions AS
 (SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month, -- extract year-month from transaction date
        COUNT(*) AS monthly_txn_count 
    FROM savings_savingsaccount
    GROUP BY owner_id, txn_month),

-- Step 2: Calculate average transactions per month per user
avg_transactions AS
 (SELECT
        owner_id,
        AVG(monthly_txn_count) AS avg_txn_per_month  -- average monthly transaction count per user
    FROM monthly_transactions
    GROUP BY owner_id),

-- Step 3: Categorize users based on average transaction frequency
categorized_users AS
 (SELECT
        owner_id,
        avg_txn_per_month,
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency' -- 10+ transactions/month
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency' -- 3-9 transactions/month
            ELSE 'Low Frequency' -- 0-2 transactions/month
        END AS Frequency_Category
    FROM avg_transactions)

-- Step 4: Aggregate results by frequency category
SELECT
    Frequency_Category,
    COUNT(*) AS 'Customer Count', -- number of customers in each category
    ROUND(AVG(avg_txn_per_month), 1) AS 'Avg Transactions per Month' -- count of transactions per month per user
FROM categorized_users
GROUP BY frequency_category;

