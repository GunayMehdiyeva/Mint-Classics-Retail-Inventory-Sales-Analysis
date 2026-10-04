-- shape of our tables - # of columns and rows:
SELECT COUNT(*) AS rowsCount FROM mintclassics.customers;
SELECT COUNT(*) AS columnCount FROM information_schema.columns WHERE table_name = 'customers';

  
-- preview of the data-products table:
SELECT * FROM mintclassics.products;

-- Step 1: Count how many products are stored in each warehouse; this will show the number of different products per warehouse:
SELECT warehouseCode, COUNT(productName) AS productCount
FROM mintclassics.products
GROUP BY warehouseCode
ORDER BY productCount DESC;

-- Check total inventory per warehouse; this will reveal which warehouses hold the most/least stock:
SELECT warehouseCode, SUM(quantityInStock) AS total_stock
FROM mintclassics.products
GROUP BY warehouseCode
ORDER BY total_stock DESC;

-- This will summarize stock distribution:
SELECT MIN(quantityInStock) AS min_stock, -- low stock means that those products are in high demand
       MAX(quantityInStock) AS max_stock, -- hight quantity in stocks implies that some products are overstocked, some products may be slow-moving, taking up unnecessary space.
       AVG(quantityInStock) AS avg_stock,
       COUNT(productName) AS total_products -- total number of products
FROM mintclassics.products;

-- Finding mark up percentage-how much the price has increased: 
SELECT productCode, productName, buyPrice, MSRP, 
       ((MSRP - buyPrice) / buyPrice) * 100 AS markup_percentage
FROM mintclassics.products
ORDER BY markup_percentage DESC;

-- Calculating profit margin-how much profit does the company make per product:
SELECT productCode, productName, buyPrice, MSRP, 
       (MSRP - buyPrice) AS profit_margin
FROM mintclassics.products
ORDER BY profit_margin DESC;


-- Finding number of products per order-show the orders with product count 1 or more: 
SELECT orderNumber, COUNT(productCode) AS productCountPerOrder
FROM mintclassics.orderdetails
GROUP BY orderNumber
HAVING productCountPerOrder >= 1
ORDER BY productCountPerOrder DESC;

SELECT orders.orderNumber, orders.orderDate, customers.customerName
FROM mintclassics.orders
INNER JOIN mintclassics.customers ON orders.customerNumber = customers.customerNumber
-- GROUP BY orders.orderDate
ORDER BY customerName;


-- The query below just extract the data of which order placed when by whom; 
-- To find out when the orders were placed by a customer, starting from the latest order date (i.e 2005-05-31):
SELECT orderNumber, orderDate, customerNumber 
FROM mintclassics.orders
-- GROUP BY customerNumber, orderNumber
ORDER BY orderDate DESC;


-- It looks like multiple orders can be placed (most probably by different customers) on each date. 
-- By grouping the  orderDates I can find out the number of orders (total_orders) placed on each date:
SELECT orderDate, COUNT(orderNumber) as total_orders
FROM mintclassics.orders
-- WHERE orderDate = "2005-05-31" -- to check how many orders have placed on the last date
GROUP BY orderDate
ORDER BY total_orders DESC;


-- to show that my claim is true. My claim: by a customer at most 1 order can be placed on the exact same date:
SELECT orderDate, customerNumber, COUNT(orderNumber) as orderCount
FROM mintclassics.orders
GROUP BY orderDate, customerNumber
-- HAVING orderCount > 1
ORDER BY orderCount DESC;


-- how many orders has each customer placed in total? 
SELECT customers.customerName, orders.customerNumber, COUNT(orders.orderNumber) as totalOrders
FROM mintclassics.orders
INNER JOIN mintclassics.customers ON orders.customerNumber = customers.customerNumber
-- WHERE customers.customerName = 'Euro\+ Shopping Channel' ---- to know the # of orders by a specific customer uncomment this line
GROUP BY orders.customerNumber
ORDER BY totalOrders DESC
LIMIT 5;	


-- how many orders has a specific customer placed? 
SELECT orders.customerNumber, COUNT(orders.orderNumber) as total_orders, customers.customerName
FROM mintclassics.orders
INNER JOIN mintclassics.customers ON orders.customerNumber = customers.customerNumber
WHERE customers.customerNumber = 186
ORDER BY total_orders DESC;

-- How many products are included in a specific order?
SELECT orderNumber, COUNT(productCode) AS total_products
FROM mintclassics.orderdetails
WHERE orderNumber = 10424
ORDER BY orderNumber DESC;


-- How many products are bought by a specific customer in each order? --> including the name of the customer who placed the order:
SELECT o.orderNumber, COUNT(od.productCode) AS totalProducts, c.customerName
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
-- WHERE o.orderNumber = 10424
-- WHERE c.customerName LIKE '%Euro%'     
WHERE c.customerName = 'Euro\+ Shopping Channel'
GROUP BY o.orderNumber, c.customerName
ORDER BY totalProducts;


-- Finding the total number of products for each order placed by each customer:	 
SELECT o.orderNumber, COUNT(od.productCode) AS totalProducts, c.customerName
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
GROUP BY o.orderNumber, c.customerName
ORDER BY totalProducts DESC;	-- to check what's the least # of products bought

-- Solving the challenge with the customer name that contains a specific character '+':
SELECT o.orderNumber, COUNT(od.productCode) AS total_products, c.customerName
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
WHERE c.customerName = 'Euro\+ Shopping Channel'   -- apparently backslash works in this case. This might be a better way than using LIKE, since some other names might contain 'Euro'. But here we are safe.
-- WHERE c.customerName LIKE '%Euro%'
GROUP BY o.orderNumber, c.customerName
ORDER BY total_products DESC;




-- Summing products in each order to get the total number of products for each customer:
SELECT COUNT(od.productCode) AS totalProducts, c.customerName, c.customerNumber
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
-- WHERE c.customerName = 'Euro\+ Shopping Channel'
GROUP BY c.customerName, c.customerNumber
ORDER BY totalProducts DESC;


-- Finding total price for each product:
SELECT products.productName AS productName, SUM(orderdetails.priceEach) AS total_price
FROM mintclassics.orderdetails
INNER JOIN mintclassics.products ON products.productCode = orderdetails.productCode
GROUP BY productName
ORDER BY total_price DESC;

-- This query gives price for each product. But why each product has multiple price?
SELECT products.productName AS productName, 
       orderdetails.priceEach
FROM mintclassics.orderdetails
INNER JOIN mintclassics.products ON products.productCode = orderdetails.productCode
ORDER BY productName;


-- This query show the prices for the very product which makes the company the most money:
SELECT products.productName AS productName, 
       orderdetails.priceEach
FROM mintclassics.orderdetails
INNER JOIN mintclassics.products ON products.productCode = orderdetails.productCode
WHERE productName = '1992 Ferrari 360 Spider red';

-- This query computes the average price for 1992 Ferrari 360 Spider red:
SELECT products.productName AS productName, 
       AVG(orderdetails.priceEach) AS average_price
FROM mintclassics.orderdetails
INNER JOIN mintclassics.products ON products.productCode = orderdetails.productCode
WHERE productName = '1992 Ferrari 360 Spider red';

-- see if there is any customer who placed multiple orders on the same day: 
SELECT orderDate, customerNumber, COUNT(orderNumber) AS order_count
FROM mintclassics.orders
GROUP BY orderDate, customerNumber
HAVING COUNT(orderNumber) > 1;

-- The SQL HAVING clause is used to filter the results of a GROUP BY query based on the result of an aggregate function. 
-- It is similar to the WHERE clause but is specifically applied after grouping and aggregation, 
-- allowing you to filter on the results of aggregate functions like COUNT, SUM, AVG, and others.

-- trying to understand what orderQuantity refers to:
SELECT od.productCode, 
       COUNT(od.quantityOrdered) AS totalOrderQuantity, c.customerName, 
       o.customerNumber, o.orderNumber, 
       o.orderDate, p.productName 
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products AS p ON p.productCode = od.productCode
WHERE c.customerName = 'Euro\+ Shopping Channel'
GROUP BY o.orderNumber, od.productCode
ORDER BY o.orderDate DESC;

-- What to do next: a) Check which products were included in these multiple orders. 
-- Are the products different, or are there duplicates?
SELECT od.productCode,  p.productName, od.quantityOrdered AS orderQuantity, 
       c.customerName, o.customerNumber, o.orderNumber, o.orderDate
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products AS p ON p.productCode = od.productCode
WHERE o.customerNumber = 141 AND o.orderDate = '2005-02-10'
ORDER BY o.orderNumber;


-- What to Do Next: b) Compare order amounts (total order value)—are they similar in size, or is one much larger?
-- Now, let’s check the total value/price of each order. If the amounts are similar, it might indicate systematic multiple orders. 
-- If one is much larger, it could be a separate large purchase.
SELECT o.orderNumber, o.orderDate,
       SUM(od.quantityOrdered * od.priceEach) AS totalOrderValue
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
WHERE c.customerName = 'Euro\+ Shopping Channel'
GROUP BY o.orderNumber
ORDER BY totalOrderValue;


-- it turned out product price changes per order (when sorting productCode), if we consider that each order is placed by different customers,
-- then this means, product price varies depending on the customer. This might be because the location/country of the customers.

-- What to Do Next: d) Check the amount of money paid for each product:
-- This query shows price of each product in each order: 
SELECT c.customerName, o.customerNumber,
       o.orderNumber, o.orderDate, p.productCode,
       od.priceEach, od.quantityOrdered,
       (od.quantityOrdered * od.priceEach) AS orderPricePerProduct,
	   c.country, c.city
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products AS p ON p.productCode = od.productCode
GROUP BY o.orderNumber, c.customerNumber, o.orderDate, c.customerName, 
         od.priceEach, od.quantityOrdered, p.productCode
ORDER BY o.orderDate;

-- This query shows the price per product:
SELECT c.customerName, o.customerNumber,
       o.orderNumber, o.orderDate, p.productCode,
       od.priceEach, od.quantityOrdered
      -- (od.quantityOrdered * od.priceEach) AS orderPricePerProduct,
	  -- c.country, c.city
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products AS p ON p.productCode = od.productCode
GROUP BY o.orderNumber, c.customerNumber, o.orderDate, c.customerName, 
         od.priceEach, od.quantityOrdered, p.productCode
ORDER BY o.orderDate;


-- Total Revenue per Customer: This query shows the total order amount/price per order of each customer.
SELECT c.customerName,
       SUM(od.quantityOrdered * od.priceEach) AS totalOrderPrice
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
GROUP BY c.customerName
ORDER BY totalOrderPrice DESC;



-- we can count the number of orders per day for all customers:
SELECT o.customerNumber, c.customerName, o.orderDate, 
       COUNT(o.orderNumber) AS numberOfOrders
FROM mintclassics.orders o
JOIN mintclassics.customers c ON o.customerNumber = c.customerNumber
-- WHERE c.customerName = 'Euro\+ Shopping Channel'
GROUP BY o.customerNumber, o.orderDate
-- HAVING COUNT(o.orderNumber) > 1
ORDER BY numberOfOrders DESC;

-- counting the number of orders over time
SELECT o.customerNumber, c.customerName,
       COUNT(o.orderNumber) AS numberOfOrders
FROM mintclassics.orders o
JOIN mintclassics.customers c ON o.customerNumber = c.customerNumber
-- WHERE c.customerName = 'Euro\+ Shopping Channel'
GROUP BY o.customerNumber
-- HAVING COUNT(o.orderNumber) > 1
ORDER BY numberOfOrders DESC;


-- What To Do Next: e) See if this customer is a wholesaler or retailer (if such information is available):	
SELECT	c.customerNumber, c.customerName, 
		COUNT(DISTINCT o.orderNumber) AS totalOrders, 
		SUM(od.quantityOrdered) AS totalProductsOrdered, 
		SUM(od.quantityOrdered * od.priceEach) AS totalSpent, 
		c.creditLimit
FROM mintclassics.customers c
JOIN mintclassics.orders o ON c.customerNumber = o.customerNumber
JOIN mintclassics.orderdetails od ON o.orderNumber = od.orderNumber
-- WHERE c.customerName = 'Euro\+ Shopping Channel'
GROUP BY c.customerNumber, c.customerName, c.creditLimit
ORDER BY totalOrders DESC;


-- Most ordered products in general, i.e by each customer. To check which products they frequently purchase.
-- This way we can also find out top-selling product: 
SELECT p.productName, 
       SUM(od.quantityOrdered) AS totalQuantitySold
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products AS p ON p.productCode = od.productCode
-- WHERE c.customerName = 'Euro\+ Shopping Channel' 
GROUP BY  p.productName
ORDER BY totalQuantitySold DESC;


-- Most Profitable Products:
SELECT p.productName, 
       SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS totalProfit
FROM mintclassics.products p
JOIN mintclassics.orderdetails od ON p.productCode = od.productCode
GROUP BY p.productName
ORDER BY totalProfit DESC;

-- Warehouse Utilization:
SELECT warehouseName, warehousePctCap
FROM mintclassics.warehouses;



-- How many specific product is ordered by a specific customer over time?
SELECT p.productName, SUM(od.quantityOrdered) AS productQuantity, o.orderDate
FROM mintclassics.orders AS o
JOIN mintclassics.customers AS c ON o.customerNumber = c.customerNumber
JOIN mintclassics.orderdetails AS od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products AS p ON p.productCode = od.productCode
WHERE c.customerName = 'Euro\+ Shopping Channel' AND 
      p.productName LIKE '%Ford%Thunder%'
GROUP BY  p.productName, o.orderDate
ORDER BY productQuantity DESC;

-- Credit limit vs Total orders:
SELECT c.customerName, COUNT(o.orderNumber) AS totalOrders, c.creditLimit
FROM mintclassics.orders AS o 
JOIN mintclassics.customers AS c ON c.customerNumber = o.customerNumber
GROUP BY c.customerName, c.creditLimit
ORDER BY c.creditLimit DESC;



-- one order can contain multiple products --> the corresponding order numbers appear multiple times (in the table) for each product: 
SELECT c.customerName, 
       COUNT(o.orderNumber) AS totalOrder
FROM mintclassics.customers c
JOIN mintclassics.orders o ON c.customerNumber = o.customerNumber
JOIN mintclassics.orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerName
ORDER BY totalOrder DESC;

-- Using DISTINCT help us to count the number of different orders placed by each customer.   
SELECT c.customerName, 
       COUNT(DISTINCT o.orderNumber) AS totalOrder
FROM mintclassics.customers c
JOIN mintclassics.orders o ON c.customerNumber = o.customerNumber
JOIN mintclassics.orderdetails od ON o.orderNumber = od.orderNumber
-- WHERE c.customerName LIKE '%Euro%'
GROUP BY c.customerName
ORDER BY totalOrder DESC;


-- There is multiple/different products under a single order(number): 
SELECT c.customerName, 
       o.orderNumber,
       p.productCode
FROM mintclassics.customers c
JOIN mintclassics.orders o ON c.customerNumber = o.customerNumber
JOIN mintclassics.orderdetails od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products p ON p.productCode = od.productCode
ORDER BY c.customerName DESC;


-- Total Revenue per Product:
SELECT 
    p.productName, 
    SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
FROM mintclassics.products p
JOIN mintclassics.orderdetails od ON p.productCode = od.productCode
GROUP BY p.productName
ORDER BY totalRevenue DESC;


-- Stock levels: this query shows how many stocks each product line have. In total, there is 7 product lines. 	 
-- Classic cars are the one with the highest stock level:
SELECT	w.warehouseName, 
		p.productLine, 
		SUM(p.quantityInStock) AS totalStock
FROM mintclassics.products p
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY w.warehouseName, p.productLine
ORDER BY totalStock DESC;



-- This query shows which product belongs to which product line, 
-- where the products are stored, and how many stocks of each product we have in total:
SELECT	w.warehouseName, 
		w.warehouseCode,
		w.warehousePctCap,
		p.productLine, 
        p.productName,
		SUM(p.quantityInStock) AS totalStock
FROM mintclassics.products p
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
JOIN mintclassics.productlines pl ON p.productLine = pl.productLine
-- WHERE productName LIKE '%red%'
-- WHERE p.productLine = 'Classic Cars'
GROUP BY w.warehouseName, p.productLine, p.productName, w.warehousePctCap, w.warehouseCode 
ORDER BY totalStock DESC;


-- Each product belongs to one product line and is stored in one warehouse.
-- How many product lines does each warehouse have:
SELECT	w.warehouseName,
		p.productLine,
		COUNT(p.productLine) AS productLineCount
FROM mintclassics.products p
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY w.warehouseName, p.productLine
ORDER BY productLineCount DESC;


-- To find high and low stock products:
SELECT	p.productName, 
		pl.productLine, 
		w.warehouseName, 
		p.quantityInStock
FROM mintclassics.products p
JOIN mintclassics.productlines pl ON p.productLine = pl.productLine
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
ORDER BY p.quantityInStock;


-- To find 10 Most/Least Stocked Products:
SELECT	productName, quantityInStock
FROM mintclassics.products
ORDER BY quantityInStock DESC
LIMIT 10;


-- Calculating markup percentage 
-- to see how much a product's price is increased from its cost price (buyPrice) to its selling price (MSRP):
SELECT	productName, warehouseCode, buyPrice, MSRP, 
        (MSRP - buyPrice) AS profitMargin,
	    CEILING(((MSRP - buyPrice)/ buyPrice)*100) +'%' AS markupPercentage
        -- FORMAT(((MSRP - buyPrice)/ buyPrice)*100,'#,##0.0%') AS markupPercentage
		-- CONVERT( nvarchar(20), 50) + ‘%’ as number
FROM mintclassics.products
ORDER BY markupPercentage DESC;


-- Identifying the most expensive products based on their MSRP(Manufacturer's Suggested Retail Price):
SELECT productName, MSRP, buyPrice
FROM mintclassics.products
ORDER BY MSRP DESC
LIMIT 10;

-- To analyze total stock per warehouse:
SELECT	w.warehouseName, 
		SUM(p.quantityInStock) AS totalStockPerWarehouse
FROM mintclassics.products p
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY w.warehouseName
ORDER BY totalStockPerWarehouse DESC;


-- Stock Turnover by Warehouse:
SELECT 
    p.warehouseCode,
    w.warehouseName,
    SUM(od.quantityOrdered) AS totalProductsSold,
    SUM(p.quantityInStock) AS totalStock,
    (SUM(od.quantityOrdered) / NULLIF(SUM(p.quantityInStock), 0)) AS stockTurnoverRatio
FROM mintclassics.products p
JOIN mintclassics.orderdetails od ON p.productCode = od.productCode
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY p.warehouseCode, w.warehouseName
ORDER BY stockTurnoverRatio DESC;

-- Shipping time-Does closing a specific warehouse affect the 24-hour shipping goal?
-- This query calculates shipping time:
SELECT	p.warehouseCode, w.warehouseName,
		ROUND(AVG(DATEDIFF(o.shippedDate, o.orderDate)), 2) AS avgShippingTime -- The DATEDIFF() function returns the difference between two dates, as an integer.
FROM mintclassics.orders o
JOIN mintclassics.orderdetails od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products p ON od.productCode = p.productCode
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
WHERE o.shippedDate IS NOT NULL  -- Ensures we only count shipped orders
GROUP BY p.warehouseCode, w.warehouseName
ORDER BY avgShippingTime;


-- Analyzing order volume by warehouse - How many orders are handled by each warehouse?
SELECT	p.warehouseCode, w.warehouseName, 
		COUNT(DISTINCT o.orderNumber) AS totalOrders
FROM mintclassics.orders o
JOIN mintclassics.orderdetails od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products p ON od.productCode = p.productCode
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY p.warehouseCode, w.warehouseName
ORDER BY totalOrders DESC;

-- Retrieving warehouse capacity
-- this will give us the percentage of warehouse capacity used:
SELECT	w.warehouseCode, 
		w.warehouseName, 
		w.warehousePctCap AS capacityUsage
FROM mintclassics.warehouses w;


-- identifying slow-moving products per warehouse-1 :
SELECT	p.warehouseCode, w.warehouseName, p.productCode, 
		p.productName, p.quantityInStock, 
		COALESCE(SUM(od.quantityOrdered), 0) AS totalSold, -- Ensures that if a product has no sales, it returns 0 instead of NULL.
		ROUND(COALESCE(SUM(od.quantityOrdered) / NULLIF(p.quantityInStock, 0), 0), 4) AS stockTurnoverRatio -- NULLIF(blabla, 0): Avoids division by zero.
FROM mintclassics.products p
LEFT JOIN mintclassics.orderdetails od ON p.productCode = od.productCode
LEFT JOIN mintclassics.orders o ON od.orderNumber = o.orderNumber AND o.status = 'Shipped'
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY p.warehouseCode, w.warehouseName, p.productCode, p.productName, p.quantityInStock
ORDER BY stockTurnoverRatio ASC;

-- identifying slow-moving products per warehouse-2:
SELECT 	w.warehouseCode, w.warehouseName, 
		p.productCode, p.productName, p.quantityInStock, 
		COALESCE(SUM(od.quantityOrdered), 0) AS totalSold,
		ROUND(COALESCE(SUM(od.quantityOrdered), 0) / NULLIF(p.quantityInStock, 0), 4) AS stockTurnoverRatio
FROM mintclassics.products p
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
LEFT JOIN mintclassics.orderdetails od ON p.productCode = od.productCode
GROUP BY w.warehouseCode, w.warehouseName, p.productCode, p.productName, p.quantityInStock
ORDER BY stockTurnoverRatio ASC;


-- 1. Identifying slow-moving inventory (low stock turnover):
SELECT 	p.productCode, p.productName, p.quantityInStock, 
		COALESCE(SUM(od.quantityOrdered), 0) AS totalSold,
		ROUND(COALESCE(SUM(od.quantityOrdered), 0) / NULLIF(p.quantityInStock, 0), 4) AS stockTurnoverRatio
FROM mintclassics.products p
LEFT JOIN mintclassics.orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.quantityInStock
HAVING stockTurnoverRatio < 0.5
ORDER BY stockTurnoverRatio ASC;


-- 2. Ensuring sufficient stock for high-turnover products:
SELECT 	p.productCode, p.productName, p.quantityInStock, 
		COALESCE(SUM(od.quantityOrdered), 0) AS totalSold,
		ROUND(COALESCE(SUM(od.quantityOrdered), 0) / NULLIF(p.quantityInStock, 0), 4) AS stockTurnoverRatio
FROM mintclassics.products p
LEFT JOIN mintclassics.orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName, p.quantityInStock
HAVING stockTurnoverRatio > 2  -- Considered high turnover
ORDER BY stockTurnoverRatio DESC;


-- 3. checking seasonal trends for products:
SELECT 	MONTH(o.orderDate) AS orderMonth,
		p.productCode, p.productName, 
		SUM(od.quantityOrdered) AS totalSold
FROM mintclassics.orders o
JOIN mintclassics.orderdetails od ON o.orderNumber = od.orderNumber
JOIN mintclassics.products p ON od.productCode = p.productCode
WHERE productName LIKE '%Ferrari%red%'
GROUP BY orderMonth, p.productCode, p.productName
ORDER BY orderMonth DESC;


-- 4. Analyzing warehouse efficiency.
-- Comparing turnover across warehouses can reveal inefficiencies: 
SELECT 	w.warehouseCode, w.warehouseName, 
		COUNT(DISTINCT p.productCode) AS totalProducts,
		SUM(p.quantityInStock) AS totalStock, 
		COALESCE(SUM(od.quantityOrdered), 0) AS totalSold,
		ROUND(COALESCE(SUM(od.quantityOrdered), 0) / NULLIF(SUM(p.quantityInStock), 0), 4) AS avgTurnoverRatio
FROM mintclassics.products p
JOIN mintclassics.warehouses w ON p.warehouseCode = w.warehouseCode
LEFT JOIN mintclassics.orderdetails od ON p.productCode = od.productCode
GROUP BY w.warehouseCode, w.warehouseName
ORDER BY avgTurnoverRatio DESC;


















