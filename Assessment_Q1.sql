/* -----------------------------------------------------------
   ❶  Count each user’s plans
   ❷  Keep only users with ≥1 regular‑savings AND ≥1 fixed‑investment
   ❹  Sum those balances per user, along with the two plan counts
   ----------------------------------------------------------- */
   
WITH user_plan_counts AS 
    ( SELECT 
        owner_id,
        SUM(is_regular_savings = 1) AS regular_savings_count,
        SUM(is_fixed_investment = 1) AS fixed_investment_count
    FROM plans_plan
    GROUP BY owner_id), -- Per-user plan counts, let us know users that fall within this category

qualified_users AS 
	( SELECT *
		FROM user_plan_counts
		WHERE regular_savings_count >= 1
		AND fixed_investment_count >= 1)   -- Users who have both Savings and Investment plans

SELECT
    u.id AS "Owner_ID",
    CONCAT(u.first_name, ' ', u.last_name)AS "Name" , -- Combine first and last name as name only contains NULLS
    qu.regular_savings_count AS "Saving Count",
    qu.fixed_investment_count AS "Investment Count",
    FORMAT(SUM(sa.new_balance), 2) AS "Total Deposits" -- The format for presentation
FROM qualified_users AS qu
JOIN users_customuser AS u ON u.id = qu.owner_id
JOIN savings_savingsaccount AS sa ON sa.owner_id = qu.owner_id -- Combining the 3 tables using inner join because we want to see only qualified customers.
GROUP BY
    u.id, u.name,
    qu.regular_savings_count,
    qu.fixed_investment_count
ORDER BY
      SUM(sa.new_balance) DESC; -- richest customers first 




