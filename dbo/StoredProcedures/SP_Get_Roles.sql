-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <04-01-2023>
-- Description:	<GET ROLES WITH IDS FROM SD_Role_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Roles]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Role_Id, Role_Name FROM [DBO].[SD_Role_Master] WHERE Active = 1
    ORDER BY Role_Name, Role_Id

END

GO

