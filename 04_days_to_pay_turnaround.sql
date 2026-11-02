-- =============================================
-- Query 4: Collection Velocity - Average Days to Settle Invoices
-- =============================================

SELECT 
    c.CustomerID,
    c.CustomerName,
    cc.CustomerCategoryName,

    COUNT(*) AS TotalSettledInvoices,

    SUM(ct.TransactionAmount) AS TotalSettledAmount,

    -- Average days to settle
    CAST(AVG(DATEDIFF(day, ct.TransactionDate, ct.FinalizationDate) * 1.0) AS DECIMAL(8,1)) AS AvgDaysToSettle,

    MIN(DATEDIFF(day, ct.TransactionDate, ct.FinalizationDate)) AS MinDaysToSettle,
    MAX(DATEDIFF(day, ct.TransactionDate, ct.FinalizationDate)) AS MaxDaysToSettle

FROM Sales.CustomerTransactions ct
INNER JOIN Sales.Customers c 
    ON ct.CustomerID = c.CustomerID
INNER JOIN Sales.CustomerCategories cc 
    ON c.CustomerCategoryID = cc.CustomerCategoryID
INNER JOIN Application.TransactionTypes tt
    ON ct.TransactionTypeID = tt.TransactionTypeID

WHERE tt.TransactionTypeName = N'Customer Invoice'
  AND ct.FinalizationDate IS NOT NULL          -- Only settled invoices
  AND ct.OutstandingBalance = 0                -- Fully paid
  AND ct.TransactionAmount > 0                 -- Only real invoices

GROUP BY 
    c.CustomerID,
    c.CustomerName,
    cc.CustomerCategoryName

HAVING 
    COUNT(*) >= 5                              -- Only customers with enough history

ORDER BY 
    AvgDaysToSettle DESC;