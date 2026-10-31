-- Improved Query: Top 10 Customers with Largest Outstanding Exposure
DECLARE @AsOfDate DATE = (SELECT MAX(TransactionDate) FROM Sales.CustomerTransactions);

SELECT TOP 10
    c.CustomerID,
    c.CustomerName,
    cc.CustomerCategoryName,
    
    -- Handle NULL Credit Limit (NULL = Unlimited)
    CASE 
        WHEN c.CreditLimit IS NULL THEN 'Unlimited'
        ELSE CAST(c.CreditLimit AS VARCHAR(20))
    END AS CreditLimit,

    SUM(ct.OutstandingBalance) AS TotalOutstandingBalance,
    
    -- Credit Utilization %
    CASE 
        WHEN c.CreditLimit IS NULL THEN NULL
        WHEN c.CreditLimit = 0 THEN NULL
        ELSE CAST(ROUND(SUM(ct.OutstandingBalance) * 100.0 / c.CreditLimit, 1) AS DECIMAL(5,1))
    END AS CreditUtilizationPercent,

    COUNT(ct.CustomerTransactionID) AS OpenTransactionCount,
    
    MAX(DATEDIFF(day, ct.TransactionDate, @AsOfDate)) AS MaxDaysPastDue,

    -- Flag if over credit limit
    CASE 
        WHEN c.CreditLimit IS NOT NULL AND SUM(ct.OutstandingBalance) > c.CreditLimit 
        THEN 'OVER LIMIT'
        ELSE 'OK'
    END AS CreditStatus

FROM Sales.CustomerTransactions ct
INNER JOIN Sales.Customers c 
    ON ct.CustomerID = c.CustomerID
INNER JOIN Sales.CustomerCategories cc 
    ON c.CustomerCategoryID = cc.CustomerCategoryID
WHERE ct.OutstandingBalance > 0
GROUP BY 
    c.CustomerID,
    c.CustomerName,
    cc.CustomerCategoryName,
    c.CreditLimit
ORDER BY 
    TotalOutstandingBalance DESC;