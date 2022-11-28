USE Example
GO

DROP PROCEDURE IF EXISTS dbo.InsertClient
GO

CREATE PROCEDURE dbo.InsertClient
(
	@ClientName			VARCHAR(40),
	@ClientRoleTitle	VARCHAR(40),
	@ClientId			INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT OFF

	BEGIN TRY

		DECLARE @ClientRoleId INT

		BEGIN TRANSACTION

			-- Ensure we don't violate unique constraint on ClientRoleTitle
			IF NOT EXISTS(SELECT 1 FROM dbo.ClientRoles WHERE ClientRoleTitle = @ClientRoleTitle)
				BEGIN
					INSERT INTO dbo.ClientRoles (ClientRoleTitle)
					VALUES (@ClientRoleTitle)
				END

			SELECT @ClientRoleId = ClientRoleId FROM dbo.ClientRoles WHERE ClientRoleTitle = @ClientRoleTitle

			INSERT INTO dbo.Clients (ClientRoleId, ClientName)
			VALUES (@ClientRoleId, @ClientName)

			SELECT @ClientId = SCOPE_IDENTITY()

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW
	END CATCH

	SET NOCOUNT ON
END