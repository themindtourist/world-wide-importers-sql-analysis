-- =============================================
-- Query 5: Monthly Billed Revenue vs Cash Collected & Variance
-- =============================================

WITH MonthlyTransactions AS (
    SELECT 
        DATEFROMPARTS(YEAR(ct.TransactionDate), MONTH(ct.TransactionDate), 1) AS ActivityMonth,

        -- Billed Revenue (Invoices)
        SUM(CASE WHEN tt.TransactionTypeName = N'Customer Invoice' 
                 THEN ct.TransactionAmount ELSE 0 END) AS BilledRevenue,

        -- Cash Collected
        ABS(SUM(CASE WHEN tt.TransactionTypeName = N'Customer Receipt' 
                     THEN ct.TransactionAmount ELSE 0 END)) AS CashCollected,

        -- Credit Notes / Adjustments
        ABS(SUM(CASE WHEN tt.TransactionTypeName = N'Customer Credit Note' 
                     THEN ct.TransactionAmount ELSE 0 END)) AS CreditAdjustments

    FROM Sales.CustomerTransactions ct
    INNER JOIN Application.TransactionTypes tt
        ON ct.TransactionTypeID = tt.TransactionTypeID

    GROUP BY 
        DATEFROMPARTS(YEAR(ct.TransactionDate), MONTH(ct.TransactionDate), 1)
)

SELECT 
    ActivityMonth,
    BilledRevenue,
    CreditAdjustments,
    (BilledRevenue - CreditAdjustments) AS NetBilledRevenue,
    CashCollected,

    -- Variance: Positive = collecting more than billed | Negative = billed more than collected
    (CashCollected - (BilledRevenue - CreditAdjustments)) AS CashFlowVariance,

    -- Cash-to-Bill Ratio based on Net Billed
    CAST(
        (CashCollected * 100.0) / NULLIF(BilledRevenue - CreditAdjustments, 0)
        AS DECIMAL(5,2)
    ) AS CashToBillRatioPct

FROM MonthlyTransactions
ORDER BY 
    ActivityMonth;