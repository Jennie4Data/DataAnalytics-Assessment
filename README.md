## QUESTION 1- Identifying High-Value Customers with Multiple Products
This query was designed to solve a specific business use case:  
**Identify customers who have both a savings and investment plan**, and **rank them by their total deposits (new balance)** 
### Reiterating Problem Breakdown
> The business wants to focus on high-value users — those who are engaged across **multiple financial products** (cross-sell opportunity), and **have real, funded value** in their accounts.

To do this, I followed a clear and efficient logic flow:
### Step 1: Filter for Qualified Users
I started by joining the `plans_plan` table with `users_customuser`, filtering for only those plans that are either:
- `is_regular_savings = 1` (indicating a savings plan), or  
- `is_fixed_investment = 1` (indicating an investment plan).
I then **grouped by user** and counted the distinct types of plans they had.  
✅ Only users who had **at least one savings and one investment plan** were retained. These are the **qualified, multi-product customers**.

### Step 2: Aggregate Total Deposits
From the savings_savingsaccount table, I collected the new_balance of each savings account linked to qualified users.
Then now summed up all new_balance values across all their accounts.
This approach gives a holistic view of the user's total funds saved within the platform — an indicator of their financial engagement and net worth within the ecosystem.

### Step 3: Combine and Aggregate
I then joined the qualified users with their latest balances. Then, I:
- **Summed the new balances** for users who had multiple accounts.
- **Grouped by user name** for presentation.
- Sorted by `total_new_balance DESC` to prioritize high-value customers at the top.

### Final Outcome
This query gives a **ranked list of users**:
- Who use **both savings and investment products**
- And have **Total deposits** in the system

This is essential for targeting premium users for rewards, cross-sell campaigns, and personalized financial services.

## Optimization Best Practices Applied
This query was written with performance and scalability in mind by following key SQL optimization principles:
- ✅ **Indexed join keys** (`owner_id`, `id`) were used in all JOINs.
- ✅ **Selective filters** were applied early using CTEs to reduce data volume.
- ✅ Only **necessary columns** were selected — no `SELECT *`.
- ✅ **Efficient aggregations** (via `SUM` and `GROUP BY`) were used instead of subqueries.
- ✅ Avoided unnecessary operations like ordering within subqueries or using functions in `WHERE`.


----
## QUESTION 2- Transaction Frequency Analysis Query Logic and Optimization
The query calculates the average number of transactions per customer per month and categorizes customers into High, Medium, or Low frequency segments based on their transaction activity.

**Logic Overview:**
1. First, transactions are grouped by user and month to count monthly transactions.
2. Then, the average monthly transactions per user are calculated.
3. Finally, customers are categorized into frequency groups using a CASE statement.

**Optimization Best Practices Used:**
- Utilized CTEs to break down the query into manageable and optimizable parts.
- Aggregated data early to reduce the dataset size for subsequent steps.
- Selected only necessary columns to minimize processing and data transfer.
- Used indexed columns (`owner_id`, `transaction_date`) in GROUP BY and JOINs for faster data retrieval.
- Avoided correlated subqueries to improve performance on large datasets.
- Applied efficient CASE statements for categorization.
- Grouped by month using `DATE_FORMAT` for straightforward date handling.

---
## QUESTION 3- Account Inactivity Alert Query Logic
### Business Scenario
The operations team needs to identify accounts (either savings or investment plans) that have been inactive, meaning no inflow transactions for over one year (365 days). This helps flag accounts requiring attention or re-engagement.

### Logic Explanation
1. **Identify Last Transaction Dates**  
   From the `savings_savingsaccount` table, we extract the latest inflow transaction date (`transaction_type_id = 1`) for each plan and owner combination.
2. **Filter Active Plans**  
   We join the `plans_plan` table to get plan details and categorize the plan type as either 'Savings' or 'Investment' based on flags `is_regular_savings` and `is_fixed_investment`. We exclude deleted plans (`is_deleted = 0`).
3. **Exclude Accounts with No Transactions**  
   To avoid misleading data (e.g., placeholder dates like '1900-01-01'), we filter out accounts that have never had any inflow transactions, ensuring only accounts with a recorded last transaction date are considered.
4. **Calculate Inactivity Days**  
   For qualifying accounts, we calculate the number of days since the last transaction using the current date and the last transaction date.
5. **Filter for Inactivity Over One Year**  
   Only accounts with their last inflow transaction older than 365 days from today are selected.
6. **Order Results**  
   The results are ordered by inactivity days in descending order to prioritize the most inactive accounts.

### Query Optimization Best Practices Applied
- Used **indexed columns** in joins and WHERE clauses (`plan_id`, `owner_id`, `transaction_type_id`, `is_deleted`) to speed up filtering.
- Filtered data **early** in the CTEs to reduce dataset size for subsequent steps.
- Avoided use of **placeholder dates** to prevent skewing inactivity calculations.
- Used **aggregations and grouping** efficiently to summarize the latest transaction per plan.
- **Calculated inactivity days** outside of joins to keep joins simple.
- Limited complexity by splitting logic into **CTEs** for clarity and maintainability.

---
## QUESTION 4- Customer Lifetime Value (CLV) Estimation Query Logic
### Business Scenario
Marketing wants to estimate the lifetime value of customers using a simplified model based on account tenure and transaction volume.
### Logic Explanation
1. **Calculate Total Transactions and Amount**  
   From `savings_savingsaccount`, I summed all transaction amounts and count transactions per customer.
2. **Calculate Account Tenure**  
   Using the `users_customuser` table, I was able to compute the number of months since each customer's signup date until today.
3. **Estimate CLV**  
   CLV is calculated with the formula:  
**CLV = (Total Transactions / Tenure Months) × 12 × Average Profit per Transaction**

   where the average profit per transaction is assumed as 0.1% (0.001) of the total transaction amount.
4. **Handle Edge Cases**  
   Customers with zero tenure (just signed up) or no transactions get an estimated CLV of zero to avoid division errors.
5. **Sorting**  
   Results are ordered from highest to lowest estimated CLV to identify the most valuable customers.

### Query Optimization Best Practices Applied
- Used **CTEs** to break down logic into manageable parts, improving readability.
- Used **aggregate functions** with grouping to efficiently summarize transaction data.
- Joined only necessary columns using **LEFT JOIN** to include all customers regardless of transaction history.
- Used **COALESCE** to handle NULLs gracefully.
- Calculated tenure and CLV with efficient date functions and expressions.

---



