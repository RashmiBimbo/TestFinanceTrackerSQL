-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <21-01-2023>
-- Description:	<GET USERS FROM SD_LOGIN_MASTER.>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Users_ApprAdmin]
    @Approver_Id  VARCHAR(MAX) = NULL
   ,@Location_Id VARCHAR(20) = NULL
   ,@User_Id VARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    /*
        SP_Get_Users_ApprAdmin ASHISH, 'CORP' 
    */
    SET @Approver_Id = UPPER(TRIM(@Approver_Id));
    SET @User_Id = UPPER(TRIM(@User_Id));
    SET @Location_Id = UPPER(TRIM(@Location_Id));

    SELECT DISTINCT 
    LM.User_Id UserId                
    ,LM.[User_Name] User_Name
    ,LocM.Loc_Id
    ,UTA.Approver
    ,LocM.Loc_Id
    FROM
        SD_Login_Master LM
        LEFT JOIN
        SD_Location_Master LocM ON UPPER(TRIM(LM.Location_Id)) = UPPER(TRIM(LocM.Loc_Id))
        LEFT JOIN
        SD_UserTaskAssignment UTA ON UPPER(TRIM(LM.User_Id)) = UPPER(TRIM(UTA.UserId)) AND UTA.Active = 1
    WHERE
        LM.Active = 1
        AND
        LocM.Active = 1
        AND
        UTA.Active = 1
        AND
        UPPER(TRIM(LM.User_Id)) = IIF(ISNULL(@User_Id,'')='', UPPER(TRIM(LM.User_Id)), @User_Id)
        AND
        ( UPPER(TRIM(UTA.Approver)) = IIF(ISNULL(@Approver_Id,'')='', UPPER(TRIM(UTA.Approver)), @Approver_Id)
        OR
        UPPER(TRIM(LocM.Loc_Id)) = IIF(ISNULL(@Location_Id,'')='', UPPER(TRIM(LocM.Loc_Id)), @Location_Id))
    ORDER BY User_Name

END
GO

