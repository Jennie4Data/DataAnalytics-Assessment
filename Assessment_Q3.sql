-- Step 1: CTE to get last transaction date per plan (from savings_savingsaccounts table)
WITH last_txn_per_plan AS
 (SELECT 
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    WHERE transaction_type_id = 1  -- inflow transactions
    GROUP BY plan_id, owner_id),

-- Step 2: Select active plans with their last transaction date
active_plans AS 
(SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_fixed_investment = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        l.last_transaction_date
    FROM plans_plan p
    LEFT JOIN last_txn_per_plan l ON p.id = l.plan_id AND p.owner_id = l.owner_id
    WHERE p.is_deleted = 0),

-- Step 3: Filter plans with no inflow transaction in last 365 days
inactive_accounts AS 
(SELECT
        plan_id,
        owner_id,
        type,
        last_transaction_date,
        DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
    FROM active_plans
    WHERE last_transaction_date IS NOT NULL -- eliminate rows with no transaction_date 
      AND last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 365 DAY))

SELECT * FROM inactive_accounts
ORDER BY inactivity_days DESC;

