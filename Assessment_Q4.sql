 -- Step 1: Calculate total transactions and total transaction amount per customer
WITH transaction_summary AS 
(SELECT
        sa.owner_id AS Customer_id,
        COUNT(*) AS total_transactions,
        SUM(sa.amount) AS total_transaction_amount
    FROM savings_savingsaccount sa
    GROUP BY sa.owner_id),
    
 -- Step 2: Calculate account tenure in months since signup for each customer   
customer_tenure AS 
    (SELECT
        u.id AS customer_id,
         CONCAT(u.first_name, ' ', u.last_name)AS "Name",
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months
    FROM users_customuser u)
   
   -- Step 3: Calculate estimated CLV based on given formula
   SELECT
    ct.customer_id,
    ct.Name,
    ct.tenure_months,
    COALESCE(ts.total_transactions, 0) AS total_transactions,
    CASE
        WHEN ct.tenure_months > 0 THEN
           (COALESCE(ts.total_transactions, 0) / ct.tenure_months) * 12 * (COALESCE(ts.total_transaction_amount, 0) * 0.001) -- The CLV formula
        ELSE
            0
    END AS estimated_clv
FROM customer_tenure ct
LEFT JOIN transaction_summary ts ON ct.customer_id = ts.customer_id
ORDER BY estimated_clv DESC;
