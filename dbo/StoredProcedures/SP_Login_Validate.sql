-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <02-01-2024>
-- Description:	<Get the details of the given user if exists>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Login_Validate]
    @LocationId varchar(20) = NULL,
    @UserId VARCHAR(20),
    @Password VARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @LocationId = UPPER(TRIM(@LocationId));
    SET @UserId = UPPER(TRIM(@UserId));

    SELECT TOP 1 *, IIF(UTA.UserId IS NULL, 0, 1) Is_Approver
    FROM SD_Login_Master LM
    LEFT JOIN SD_UserTaskAssignment UTA
    ON  
    UPPER(TRIM(UTA.Approver)) = @UserId
    WHERE 
    UPPER(TRIM(LM.[User_Id])) = @UserId
    AND [Password] = @Password 
    AND (
        Location_Id IS NULL 
        OR 
        UPPER(TRIM([Location_Id])) = IIF(ISNULL(@LocationId, '') = '', UPPER(TRIM(Location_Id)), @LocationId)
        )

END

GO

