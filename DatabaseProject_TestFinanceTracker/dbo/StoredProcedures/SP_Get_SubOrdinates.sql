-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <21-01-2023>
-- Description:	<Get subordinates of an approver>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_SubOrdinates]
	 @Approver_Id VARCHAR(50) = NULL
    ,@Role_Id INT = 0
AS
BEGIN
    /*
    SP_Get_SubOrdinates 'Ashish'
    */
	SET NOCOUNT ON;
    SET @Approver_Id = UPPER(TRIM(@Approver_Id));

	SELECT DISTINCT UPPER(TRIM(UserId)) UserId, LM.[User_Name], Approver, Role_Id FROM SD_UserTaskAssignment U
    INNER JOIN SD_Login_Master LM ON UPPER(TRIM(LM.User_Id)) = UPPER(TRIM(U.UserId))
    WHERE 
    LM.Active = 1
    AND
    U.Active = 1
    AND
    ISNULL(UPPER(TRIM(U.Approver)),'') = IIF(ISNULL(@Approver_Id,'') = '', ISNULL(UPPER(TRIM(U.Approver)),''), @Approver_Id) 
    AND
    Role_Id = IIF(@Role_Id = 0, Role_Id, @Role_Id)
END

GO

