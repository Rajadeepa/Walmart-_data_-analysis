-- Wlmart Project Quries
-- count total records;
SELECT * FROM Walmart ;

-- Count payment methods and number of transcations by oayment menthod
SELECT payment_method,COUNT(*)
FROM walmart GROUP BY payment_method

-- -- Count distinct branches;
SELECT COUNT(DISTINCT branch) FROM walmart;

-- -- Find the minimum quantity sold;
SELECT MIN(quantity) FROM walmart;

-- Business Problems
-- Question-1 Find difference payment method and number of transactions,number of qty sold

SELECT payment_method, COUNT(*) as no_paymemts,
SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Question -2 
-- Identify the highest-rated category in each branch,displaying the branch,category,Avg Rating
SELECT branch,category,avg_rating FROM (
SELECT 
branch,
category,
AVG(rating) as avg_rating,
RANK()OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank_position
FROM walmart GROUP BY branch , category)
 as ranked
 where rank_position = 1;
 
 
 -- Q3: Identify the busiest day for each branch based on the number of transaction
 SELECT branch, day_name, no_transactions
 FROM ( 
	SELECT 
		branch,
		DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) as day_name,
		COUNT(*) as no_transactions,
        RANK()OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_position
	FROM walmart
    GROUP BY branch, day_name
    ) as ranked
    WHERE rank_position = 1;
  
 -- Q4: Calculate the total quantity of items sold per payment method
 
 
SELECT payment_method,SUM(quantity) AS no_qty_sold
FROM walmart GROUP BY payment_method;
 
-- Q5: Determine the average, minimum, and maximum rating of categories for each city

SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q6: Calculate the total profit for each category


SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch

WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_position
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rank_position = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;


