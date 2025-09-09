-- Question 1: Achieving 1NF (First Normal Form)
-- Transform ProductDetail table to 1NF by splitting multi-value Products column

-- First, create the original table structure
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(50),
    Products VARCHAR(255)
);

-- Insert sample data
INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Query to transform to 1NF by splitting products into individual rows
-- Using a recursive CTE or string splitting function (syntax may vary by database)
-- For MySQL 8.0+ with JSON_TABLE support:
SELECT 
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n), ',', -1)) AS Product
FROM ProductDetail
JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) numbers
    ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= n - 1
ORDER BY OrderID, Product;

-- Alternative approach using a temporary numbers table
CREATE TEMPORARY TABLE numbers (n INT);
INSERT INTO numbers VALUES (1), (2), (3), (4), (5);

SELECT 
    p.OrderID,
    p.CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.Products, ',', n.n), ',', -1)) AS Product
FROM ProductDetail p
JOIN numbers n
    ON CHAR_LENGTH(p.Products) - CHAR_LENGTH(REPLACE(p.Products, ',', '')) >= n.n - 1
ORDER BY p.OrderID, Product;

-- Question 2: Achieving 2NF (Second Normal Form)
-- Transform OrderDetails table to 2NF by removing partial dependencies

-- First, create the 1NF table structure
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(50),
    Product VARCHAR(50),
    Quantity INT
);

-- Insert sample data
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Query to transform to 2NF by creating separate tables
-- Step 1: Create Orders table (removes CustomerName partial dependency)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(50)
);

-- Step 2: Create OrderItems table (contains full dependency on composite key)
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(50),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Step 3: Populate Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Step 4: Populate OrderItems table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Verification queries
SELECT * FROM Orders ORDER BY OrderID;
SELECT * FROM OrderItems ORDER BY OrderID, Product;