-- Select the database
USE fmban_sql_analysis;

-- Create a CTE to classify foods as 'healthier' or 'healthy' based on low sodium & low fat
WITH FoodClassification AS (
    SELECT 
        ID,
        product,
        subcategory,
        (price / 100) / totalsecondarysize AS unit_price,
        CASE 
            WHEN lowfat = 1 AND lowsodium = 1 THEN 'Healthier'
            ELSE 'Healthy'
        END AS food_category
    FROM fmban_data
)

-- Compare Prices Between Healthier and Healthy Foods
SELECT 
    food_category, 
    COUNT(ID) AS total_products,
    ROUND(AVG(unit_price), 2) AS avg_price,
    ROUND(SUM(unit_price), 2) AS total_price
FROM FoodClassification
GROUP BY food_category;

-- Hypothesis Testing: T-Test Calculation
WITH HealthyFoods AS (
    SELECT 
        (price / 100) / totalsecondarysize AS price
    FROM fmban_data
    WHERE lowfat != 1 AND lowsodium != 1
),
HealthierFoods AS (
    SELECT 
        (price / 100) / totalsecondarysize AS price
    FROM fmban_data
    WHERE lowfat = 1 AND lowsodium = 1
)

-- Compute Mean, Standard Deviation, and Sample Size
SELECT 
    (SELECT AVG(price) FROM HealthierFoods) AS healthier_avg_price,
    (SELECT STDDEV(price) FROM HealthierFoods) AS healthier_stddev,
    (SELECT COUNT(*) FROM HealthierFoods) AS healthier_n,
    (SELECT AVG(price) FROM HealthyFoods) AS healthy_avg_price,
    (SELECT STDDEV(price) FROM HealthyFoods) AS healthy_stddev,
    (SELECT COUNT(*) FROM HealthyFoods) AS healthy_n,
    
    -- T-Test Formula: (M1 - M2) / SQRT((S1^2 / N1) + (S2^2 / N2))
    ((SELECT AVG(price) FROM HealthierFoods) - (SELECT AVG(price) FROM HealthyFoods)) /
    SQRT(
        (POW((SELECT STDDEV(price) FROM HealthierFoods), 2) / (SELECT COUNT(*) FROM HealthierFoods)) + 
        (POW((SELECT STDDEV(price) FROM HealthyFoods), 2) / (SELECT COUNT(*) FROM HealthyFoods))
    ) AS t_test_value;


-- Business Insights: Vegan & Vegetarian Market Trends
-- Count of Vegan and Vegetarian Products
SELECT 
    'Vegan' AS category, COUNT(ID) AS total_products
FROM fmban_data
WHERE vegan = 1
UNION ALL
SELECT 
    'Vegetarian' AS category, COUNT(ID) AS total_products
FROM fmban_data
WHERE vegetarian = 1;

-- Identify Top Selling Vegan & Vegetarian Subcategories
SELECT 
    subcategory, 
    COUNT(ID) AS total_products
FROM fmban_data
WHERE vegan = 1 OR vegetarian = 1
GROUP BY subcategory
ORDER BY total_products DESC
LIMIT 5;


-- Inventory Optimization: Expanding Healthier Food Options
-- Determine Product Availability in the Healthier Category
SELECT 
    food_category, 
    subcategory, 
    COUNT(ID) AS product_count
FROM FoodClassification
GROUP BY food_category, subcategory
ORDER BY food_category, product_count DESC;


