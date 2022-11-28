USE Example
GO

DECLARE @ClientIdOut INT

EXEC dbo.InsertClient
	@ClientName = 'Cameron',
	@ClientRoleTitle = 'QA Engineer',
	@ClientId = @ClientIdOut OUTPUT

SELECT @ClientIdOut AS ClientIdOut

SELECT * FROM dbo.ClientRoles

SELECT * FROM dbo.Clients



-- Check that stored procedure works in rolling back
DECLARE @ClientIdOut INT

EXEC dbo.InsertClient
	@ClientName = 'Woodford',
	@ClientRoleTitle = 'Shady guy',
	@ClientId = @ClientIdOut OUTPUT

SELECT @ClientIdOut AS ClientIdOut

SELECT * FROM dbo.ClientRoles

SELECT * FROM dbo.Clients