-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <21-01-2023>
-- Description:	<GET USERS FROM SD_LOGIN_MASTER.>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Users]
	 @Role_Id int = 0
   , @Location_Id VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    /*
        SP_Get_Users 1, 'BLR' 
    */
    
    SET @Location_Id = UPPER(TRIM(@Location_Id))

    -- Insert statements for procedure here
	SELECT TRIM([User_Id]) User_Id, TRIM([User_Name]) User_Name, Location_Id
    FROM [DBO].[SD_Login_Master] LM
        WHERE Active = 1 
        AND
        Role_Id = IIF(@Role_Id = 0, Role_Id, @Role_Id)
        AND
        ISNULL(UPPER(TRIM(LM.Location_Id)),'') = IIF( ISNULL(@Location_Id, '') = '', ISNULL(UPPER(TRIM(LM.Location_Id)),''), @Location_Id) 
    ORDER BY User_Name

END

GO

