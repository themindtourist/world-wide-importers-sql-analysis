-- Step 1: Establish benchmark "as-of" date based on the latest transaction in WWI
DECLARE @AsOfDate DATE = (SELECT MAX(TransactionDate) FROM Sales.CustomerTransactions);

WITH CustomerBalances AS (
    SELECT 
        ct.CustomerID,
        c.CustomerName,
        ct.CustomerTransactionID,
        ct.TransactionDate,
        ct.OutstandingBalance,
        DATEDIFF(day, ct.TransactionDate, @AsOfDate) AS DaysPastDue
    FROM Sales.CustomerTransactions ct
    INNER JOIN Sales.Customers c 
        ON ct.CustomerID = c.CustomerID
    WHERE ct.OutstandingBalance > 0
)
SELECT 
    CustomerID,
    CustomerName,
    CustomerTransactionID,
    TransactionDate,
    OutstandingBalance,
    DaysPastDue,
    CASE 
        WHEN DaysPastDue <= 30 THEN '0 - 30 Days (Current)'
        WHEN DaysPastDue BETWEEN 31 AND 60 THEN '31 - 60 Days'
        WHEN DaysPastDue BETWEEN 61 AND 90 THEN '61 - 90 Days'
        ELSE '90+ Days (High Risk)'
    END AS AgingBucket
FROM CustomerBalances
ORDER BY DaysPastDue DESC;
