USE Example
GO

-- Constraints
-- Will always query with an equality predicate using ClientId
-- There are a high volume of transactions

SELECT * FROM dbo.Clients
SELECT * FROM dbo.Transactions

-- Assumption: This query returns a lot of rows
SELECT ClientId, TransactionDate, TransactionAmount
	FROM dbo.Transactions
	WHERE TransactionDate > '2021-08-13'

-- Query 1.1: query table with predicate which is a left-based subset of nonclustered index key below
SELECT TransactionId
	FROM dbo.Transactions
	WHERE ClientId = 4

-- Query 1.2: query table using non-clustered index on client ID
SELECT TransactionId, ClientId, TransactionType
	FROM dbo.Transactions
	WHERE ClientId = 4 AND TransactionType = 'A'


-- Index 1: Create non-clustered index to support the above queries
DROP INDEX IF EXISTS idx_Transactions_ClientIdTransactionType
	ON dbo.Transactions
GO

CREATE NONCLUSTERED INDEX idx_Transactions_ClientIdTransactionType
	ON dbo.Transactions (ClientId, TransactionType)
GO
 

-- Query 2.1: Query table with an inequality predicate
-- Assumption: This query returns a lot of rows
SELECT ClientId, TransactionDate, TransactionAmount
	FROM dbo.Transactions
	WHERE ClientId = 4 AND TransactionDate > '2021-08-13'

-- Query 2.2: Query table with an inequality predicate
SELECT SUM(TransactionAmount) AS TotalTransactionsInLastThirtyDaysForClient1
		FROM dbo.Transactions
		WHERE ClientId = 1
			AND TransactionDate < GETDATE() 
			AND TransactionDate > DATEADD(day, -30, GETDATE())

-- Query 2.3: Query table with an inequality predicate
-- Doesn't seek against index 2 but instead does a scan against index 2 
-- due to predicates not being left based subset
SELECT ClientId, SUM(TransactionAmount) AS TransactionsSum		
	FROM dbo.Transactions
	WHERE TransactionDate < GETDATE() 
		AND TransactionDate > DATEADD(day, -30, GETDATE())
	GROUP BY ClientId


-- Index 2: A non-clustered index to support query with inequality predicate
-- include columns to avoid key lookup on every row which query optimiser might turn into index scan
DROP INDEX IF EXISTS idx_Transactions_ClientIdTransactionDate
	ON dbo.Transactions
GO

CREATE NONCLUSTERED INDEX idx_Transactions_ClientIdTransactionDate
	ON dbo.Transactions (ClientId, TransactionDate)
	INCLUDE (TransactionAmount)
GO


-- The below give the same results set as Query 2.3 above but demonstrate use of CTE and UDF


-- Use CTE 
-- Doesn't seek against index 2 but instead does a scan against index 2 
-- due to predicates not being left based subset

WITH example_cte (ClientId, TransactionAmount)
AS
(
	SELECT ClientId, TransactionAmount
		FROM dbo.Transactions
		WHERE TransactionDate < GETDATE() 
			AND TransactionDate > DATEADD(day, -30, GETDATE())
)

SELECT ClientId, SUM(TransactionAmount) AS TransactionsSum
	FROM example_cte
	GROUP BY ClientId



-- Use UDF 
-- Doesn't seek against index 2 but instead makes a scan
DROP FUNCTION IF EXISTS dbo.udfGetTransactionTotalLast30Days
GO 

CREATE FUNCTION dbo.udfGetTransactionTotalLast30Days(@ClientId int)
RETURNS decimal(19,2)
AS
BEGIN
	DECLARE @return decimal(19,2);
	SELECT @return = SUM(TransactionAmount)
		FROM dbo.Transactions
		WHERE ClientId = @ClientId
			AND TransactionDate < GETDATE() 
			AND TransactionDate > DATEADD(day, -30, GETDATE())
	RETURN @return;
END;

GO

SELECT ClientId, dbo.udfGetTransactionTotalLast30Days(ClientId) AS TransactionSum
	FROM dbo.Transactions
	GROUP BY ClientId
