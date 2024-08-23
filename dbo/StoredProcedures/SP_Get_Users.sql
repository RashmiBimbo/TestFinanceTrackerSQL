-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <21-01-2023>
-- Description:	<GET USERS FROM SD_LOGIN_MASTER.>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Users]
	 @Role_Id int = 0
   , @Location_Id VARCHAR(20) = NULL
   , @User_Id VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    /*
        SP_Get_Users 2, 'CORP' 
    */
    
    SET @Location_Id = dbo.CapsStr(@Location_Id);
    SET @User_Id = dbo.CapsStr(@User_Id);

    -- Insert statements for procedure here
	SELECT Row_Number() OVER (ORDER BY User_Name) Sno, dbo.CapsStr([User_Id]) User_Id, TRIM([User_Name]) User_Name, dbo.CapsStr(Location_Id) Location_Id, LM.Role_Id, LocM.Loc_Name, RM.Role_Name, LM.Rec_Id,
    lm.Address, LM.Email, LM.Company_Id, LM.Login_Type, LM.[Password], LM.Sub_Company_Id 
    FROM [DBO].[SD_Login_Master] LM
    INNER JOIN SD_Role_Master RM ON RM.Role_Id = LM.Role_Id
    INNER JOIN SD_Location_Master LocM ON LocM.Loc_Id = LM.Location_Id
        WHERE LM.Active = 1 
        AND LocM.Active = 1 
        AND RM.Active = 1 
        AND
        RM.Role_Id = IIF(@Role_Id = 0, RM.Role_Id, @Role_Id)
        AND
        dbo.CapsStr(LM.Location_Id) = dbo.CheckStr(@Location_Id, LM.Location_Id)
        AND
        dbo.CapsStr(LM.User_Id) = dbo.CheckStr(@User_Id, LM.User_Id)
    ORDER BY User_Name
END

GO

