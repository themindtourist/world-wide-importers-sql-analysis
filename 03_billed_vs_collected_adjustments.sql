-- =============================================
-- Query 3: Monthly Gross Invoiced vs Cash Collected vs Credit Adjustments
-- =============================================

SELECT 
    YEAR(ct.TransactionDate) AS TransactionYear,
    MONTH(ct.TransactionDate) AS TransactionMonth,

    -- Gross Invoiced
    SUM(CASE WHEN tt.TransactionTypeName = N'Customer Invoice' 
             THEN ct.TransactionAmount ELSE 0 END) AS GrossInvoicedAmount,

    -- Cash Collected (payments are usually negative, so we take absolute value)
    ABS(SUM(CASE WHEN tt.TransactionTypeName = N'Customer Receipt' 
                 THEN ct.TransactionAmount ELSE 0 END)) AS CashCollectedAmount,

    -- Credit Notes / Adjustments
    ABS(SUM(CASE WHEN tt.TransactionTypeName = N'Customer Credit Note' 
                 THEN ct.TransactionAmount ELSE 0 END)) AS CreditAdjustments,

    -- Net Amount (Invoiced - Credits)
    SUM(CASE WHEN tt.TransactionTypeName = N'Customer Invoice' 
             THEN ct.TransactionAmount ELSE 0 END)
    - ABS(SUM(CASE WHEN tt.TransactionTypeName = N'Customer Credit Note' 
                   THEN ct.TransactionAmount ELSE 0 END)) AS NetInvoicedAmount,

    -- Collection Rate %
    CAST(
        ABS(SUM(CASE WHEN tt.TransactionTypeName = N'Customer Receipt' 
                     THEN ct.TransactionAmount ELSE 0 END)) * 100.0
        /
        NULLIF(
            SUM(CASE WHEN tt.TransactionTypeName = N'Customer Invoice' 
                     THEN ct.TransactionAmount ELSE 0 END)
            - ABS(SUM(CASE WHEN tt.TransactionTypeName = N'Customer Credit Note' 
                           THEN ct.TransactionAmount ELSE 0 END))
        , 0)
    AS DECIMAL(5,2)) AS NetCollectionRatePct

FROM Sales.CustomerTransactions ct
INNER JOIN Application.TransactionTypes tt
    ON ct.TransactionTypeID = tt.TransactionTypeID

GROUP BY 
    YEAR(ct.TransactionDate),
    MONTH(ct.TransactionDate)

ORDER BY 
    TransactionYear,
    TransactionMonth;
