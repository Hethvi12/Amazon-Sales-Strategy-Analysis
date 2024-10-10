use amazonsales;

-- Data Wrangling  
SELECT * from amazon where `Invoice ID` is NULL 
 or Branch is null
 or City is null
 or `Customer type` is null
 or Gender is null
 or `Product line` is null
 or `Unit price` is null
 or `Quantity` is null
 or `Tax 5%` is null
 or Total is null
 or Date is null
 or Time is null 
 or Payment is null
 or cogs is null
or `gross margin percentage` is null
or `gross income` is null
or Rating is null;

-- Feature Engineering  
ALTER TABLE amazon 
ADD COLUMN timeofday VARCHAR(10),
ADD COLUMN dayname VARCHAR(10),
ADD COLUMN monthname VARCHAR(10);
UPDATE amazon


SET timeofday = CASE
    WHEN HOUR(`time`) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(`time`) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
END;

UPDATE amazon
SET dayname = DAYNAME(`date`);
UPDATE amazon
SET dayname = DATE_FORMAT(`date`, '%a');
UPDATE amazon
SET monthname = MONTHNAME(`date`);
UPDATE amazon
SET monthname = DATE_FORMAT(`date`, '%b');
SELECT time, timeofday, date, dayname, monthname
FROM amazon
LIMIT 10;

-- EDA and Reasearch Questions 
-- 1. What is the count of distinct cities in the dataset?

select count(distinct City) from amazon;

-- 2.	For each branch, what is the corresponding city?

select Branch, City from amazon
Group by branch, city;

-- 3.	What is the count of distinct product lines in the dataset?

select distinct `Product line` from amazon ;
select  count(distinct `Product line`) AS distinct_product_lines_count from amazon ;

-- 4.	Which payment method occurs most frequently?

SELECT Payment, COUNT(*) AS frequency
FROM amazon
GROUP BY Payment
ORDER BY frequency DESC
limit 1;

-- 5.	Which product line has the highest sales?

SELECT `Product line`, SUM(total) AS total_sales
FROM amazon
GROUP BY `Product line`
ORDER BY total_sales DESC
LIMIT 1;

-- 6.	How much revenue is generated each month?

SELECT monthname AS month,  SUM(`Unit price` * quantity) AS monthly_revenue
FROM amazon
GROUP BY month
ORDER BY month;

-- 7.	In which month did the cost of goods sold reach its peak?

SELECT monthname AS month, SUM(cogs) AS total_cogs
FROM amazon
GROUP BY month
ORDER BY total_cogs DESC
LIMIT 1;

-- 8.	Which product line generated the highest revenue?

SELECT `Product line`, SUM(`unit price` * quantity) AS total_revenue
FROM amazon
GROUP BY `Product line`
ORDER BY total_revenue DESC
LIMIT 1;

-- 9.	In which city was the highest revenue recorded?

SELECT City, SUM(`unit price` * quantity) AS total_revenue
FROM amazon
GROUP BY City
ORDER BY total_revenue DESC
LIMIT 1;

-- 10.	Which product line incurred the highest Value Added Tax?

SELECT `Product line`, SUM(`Tax 5%`) AS total_vat
FROM amazon
GROUP BY `Product line`
ORDER BY total_vat DESC
LIMIT 1;

-- 11.	For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

WITH ProductSales AS (
    SELECT 
        `Product line`, 
        SUM(`unit price` * quantity) AS total_sales
    FROM amazon
    GROUP BY `Product line`
),
AverageSales AS (
    SELECT AVG(total_sales) AS avg_sales
    FROM ProductSales
)
SELECT 
    ps.`Product line`,
    ps.total_sales,
    a.avg_sales,
    CASE
        WHEN ps.total_sales > a.avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS sales_performance
FROM ProductSales ps, AverageSales a;

-- 12.	Identify the branch that exceeded the average number of products sold.

WITH BranchSales AS (
    SELECT branch, SUM(quantity) AS total_products_sold
    FROM amazon
    GROUP BY branch
)
SELECT 
    branch, 
    total_products_sold,
    (SELECT AVG(total_products_sold) FROM BranchSales) AS avg_products_sold
FROM BranchSales
HAVING total_products_sold > avg_products_sold;

-- 13.	Which product line is most frequently associated with each gender?	

SELECT gender, `Product line`, COUNT(*) AS frequency
FROM amazon
GROUP BY gender, `Product line`
ORDER BY gender, frequency DESC;
SELECT gender, `Product line`

FROM (
    SELECT gender, `Product line`, COUNT(*) AS frequency,
           RANK() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rnk
    FROM amazon
    GROUP BY gender, `Product line`
) AS ranked
WHERE rnk = 1;

-- 14.	Calculate the average rating for each product line.

SELECT `Product line`, AVG(rating) AS average_rating
FROM amazon
GROUP BY `Product line`;

15.	Count the sales occurrences for each time of day on every weekday.
SELECT
    dayname AS weekday,
    timeofday,
    COUNT(*) AS sales_count
FROM amazon
GROUP BY weekday, timeofday
ORDER BY weekday, FIELD(timeofday, 'Morning', 'Afternoon', 'Evening');

-- 16.	Identify the customer type contributing the highest revenue.

SELECT `customer type`, SUM(`unit price` * quantity) AS total_revenue
FROM amazon
GROUP BY `customer type`
ORDER BY total_revenue DESC
LIMIT 1;

-- 17.	Determine the city with the highest VAT percentage.

SELECT City, MAX(`Tax 5%`) AS highest_vat_percentage
FROM amazon
GROUP BY City
ORDER BY highest_vat_percentage DESC
LIMIT 1;

-- 18.	Identify the customer type with the highest VAT payments.

SELECT `customer type`, SUM(`Tax 5%`) AS total_vat
FROM amazon
GROUP BY `customer type`
ORDER BY total_vat DESC
LIMIT 1;

-- 19.	What is the count of distinct customer types in the dataset?

SELECT COUNT(DISTINCT `customer type`) AS distinct_customer_types_count
FROM amazon;

-- 20.	What is the count of distinct payment methods in the dataset?

SELECT COUNT(DISTINCT Payment) AS distinct_payment_methods
FROM amazon;

-- 21.	Which customer type occurs most frequently?

SELECT `customer type`, COUNT(*) AS occurrence_count
FROM amazon
GROUP BY `customer type`
ORDER BY occurrence_count DESC
LIMIT 1;

-- 22.	Identify the customer type with the highest purchase frequency.

SELECT `customer type`, COUNT(*) AS purchase_frequency
FROM amazon
GROUP BY `customer type`
ORDER BY purchase_frequency DESC
LIMIT 1;

-- 23.	Determine the predominant gender among customers.

SELECT gender, COUNT(*) AS gender_count
FROM amazon
GROUP BY gender
ORDER BY gender_count DESC
LIMIT 1;

-- 24.	Examine the distribution of genders within each branch.

SELECT branch, gender, COUNT(*) AS gender_count
FROM amazon
GROUP BY branch, gender
ORDER BY branch, gender_count DESC;

-- 25.	Identify the time of day when customers provide the most ratings.
SELECT 
    timeofday,
    COUNT(rating) AS rating_count
FROM amazon
WHERE rating IS NOT NULL
GROUP BY timeofday
ORDER BY rating_count DESC
LIMIT 1;

-- 26.	Determine the time of day with the highest customer ratings for each branch.

SELECT branch, timeofday, average_rating AS highest_average_rating
FROM (
    SELECT 
        branch,
        timeofday,
        AVG(rating) AS average_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM amazon
    WHERE rating IS NOT NULL
    GROUP BY branch, timeofday
) AS TimeRatings
WHERE rnk = 1
ORDER BY branch;

-- 27.	Identify the day of the week with the highest average ratings.

SELECT dayname AS weekday, AVG(rating) AS average_rating
FROM amazon
WHERE rating IS NOT NULL
GROUP BY weekday
ORDER BY average_rating DESC
LIMIT 1;

-- 28.	Determine the day of the week with the highest average ratings for each branch.

SELECT 
    d.branch,
    d.weekday AS day_of_week,
    d.average_rating AS highest_average_rating
FROM (
    SELECT 
        branch,
        DAYNAME(date) AS weekday,
        AVG(rating) AS average_rating
    FROM amazon
    WHERE rating IS NOT NULL
    GROUP BY branch, weekday
) AS d
INNER JOIN (
    SELECT
        branch,
        MAX(average_rating) AS max_average_rating
    FROM (
        SELECT 
            branch,
            DAYNAME(date) AS weekday,
            AVG(rating) AS average_rating
        FROM amazon
        WHERE rating IS NOT NULL
        GROUP BY branch, weekday
    ) AS sub
    GROUP BY branch
) AS m
ON d.branch = m.branch AND d.average_rating = m.max_average_rating
ORDER BY d.branch;



