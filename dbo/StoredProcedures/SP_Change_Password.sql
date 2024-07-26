-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <14-02-2024>
-- Description:	<Update Password>
-- =============================================
-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[SP_Change_Password]
   @User_Id VARCHAR(50),
   @OldPswd VARCHAR(MAX), 
   @Password VARCHAR(16),
   @ChangePswdDate date = NULL,
   @Modified_By VARCHAR(250)
AS
BEGIN
    -- body of the stored procedure
    SET NOCOUNT ON;
   SET @User_Id = UPPER(TRIM(@User_Id));
    BEGIN TRY

        BEGIN TRANSACTION;

        IF EXISTS(SELECT * FROM SD_Login_Master WHERE UPPER(TRIM(User_Id)) = @User_Id)
        BEGIN
            IF EXISTS(SELECT * FROM SD_Login_Master WHERE UPPER(TRIM(User_Id)) = @User_Id AND [Password] = @OldPswd )
            BEGIN
                UPDATE SD_Login_Master
                SET [Password] = @Password,
                    Change_Password_Date = IIF(@ChangePswdDate IS NULL, GETDATE(), @ChangePswdDate),
                    Changed_Password = 1,
                    Modified_Date = GETDATE(),
                    Modified_By = @Modified_By
                WHERE UPPER(TRIM(User_Id)) = @User_Id
                COMMIT;
            END
            ELSE
                SELECT 'Old password is incorrect!';
        END
        ELSE 
            SELECT 'User does not exist!';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH
END

GO

