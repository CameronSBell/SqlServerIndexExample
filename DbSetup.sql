-- Create database
USE master

DROP DATABASE IF EXISTS Example
GO

CREATE DATABASE Example
GO

USE Example

-- Create client role table
DROP TABLE IF EXISTS dbo.ClientRoles
GO

CREATE TABLE dbo.ClientRoles
(
	ClientRoleId	INT IDENTITY(1,1)
		CONSTRAINT PK_ClientRole_ClientRoleId PRIMARY KEY CLUSTERED,
	ClientRoleTitle	VARCHAR(40) NOT NULL
		CONSTRAINT UQ_ClientRoles_ClientRoleTitle UNIQUE
)
GO

-- Create clients table
DROP TABLE IF EXISTS dbo.Clients
GO

CREATE TABLE dbo.Clients
(
	ClientId		INT IDENTITY(1,1)
		CONSTRAINT PK_Clients_ClientId PRIMARY KEY CLUSTERED,
	ClientRoleId	INT NOT NULL
		CONSTRAINT FK_Clients_ClientRoles FOREIGN KEY REFERENCES dbo.ClientRoles(ClientRoleId),
	ClientName		VARCHAR(40) NOT NULL
		CONSTRAINT CHK_Clients_ClientName_Not_Woodford CHECK
			(ClientName NOT LIKE '%Woodford%')
)
GO


-- Create transactions table
DROP TABLE IF EXISTS dbo.Transactions
GO

CREATE TABLE dbo.Transactions
(
	TransactionId		INT IDENTITY(1,1)
		CONSTRAINT PK_Transactions_TransactionId PRIMARY KEY CLUSTERED,
	ClientId			INT NOT NULL
		CONSTRAINT FK_Transactions_Clients FOREIGN KEY REFERENCES dbo.Clients(ClientId),
	TransactionType		CHAR(1) NOT NULL, 
	TransactionAmount	DECIMAL(19,2) NOT NULL,
	TransactionDate		DATETIME2(2) NOT NULL
)
GO

-- POPULATE TABLES

-- Populate client roles table
INSERT INTO dbo.ClientRoles (ClientRoleTitle)
VALUES
	('Fund Manager'),
	('Distributor'),
	('Transfer Agent')
GO

-- Populate clients table
INSERT INTO dbo.Clients (ClientName, ClientRoleId)
VALUES 
	('FNZ', 1),
	('Hargreaves Lansdown', 2),
	('BNP', 3),
	('Vanguard', 1)

GO

-- Populate transactions table
INSERT INTO dbo.Transactions (ClientId, TransactionType, TransactionAmount, TransactionDate)
VALUES (RAND()*3+1, UPPER(CHAR(CAST(RAND()*26 AS int)+97)), RAND()*1000, GETDATE())

GO 100

INSERT INTO dbo.Transactions (ClientId, TransactionType, TransactionAmount, TransactionDate)
VALUES (4, 'A', RAND()*1000, GETDATE())

GO 5
