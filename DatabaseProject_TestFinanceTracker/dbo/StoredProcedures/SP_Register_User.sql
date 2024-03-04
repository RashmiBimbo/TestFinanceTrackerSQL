-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <04-01-2023>
-- Description:	<Register User in SD_Login_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Register_User]
    @User_Id VARCHAR(20),
    @Password VARCHAR(MAX),
    @User_Name VARCHAR(250),
    @Company_Id VARCHAR(10) = NULL,
    @Sub_Company_Id VARCHAR(10) = NULL,
    @Role_Id INT,
    @EMail NVARCHAR(320),
    @Login_Type CHAR(1) = NULL,
    @Active BIT = 1,
    @Flag BIT = 1,
    @Change_Password_Date DATE = NULL,
    @Address VARCHAR(MAX) = NULL,
    @IP_Address VARCHAR(30) = NULL,
    @Location_Id VARCHAR(20) = NULL,
    @Created_Date DATETIME = getdate,
    @Created_By VARCHAR(250) = 'ADMIN'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SET @User_Id = UPPER(TRIM(@User_Id));
    SET @User_Name = TRIM(@User_Name);
    SET @Company_Id = TRIM(@Company_Id);
    SET @Sub_Company_Id = TRIM(@Sub_Company_Id);
    SET @EMail = TRIM(@EMail);
    SET @Login_Type = TRIM(@Login_Type);
    SET @Address = TRIM(@Address);
    SET @IP_Address = TRIM(@IP_Address);
    SET @Location_Id = TRIM(@Location_Id);
    SET @Created_By = TRIM(@Created_By);

    IF NOT EXISTS
    (
        SELECT *
        FROM [dbo].[SD_Login_Master]
        WHERE UPPER([User_Id]) = UPPER(@User_Id)
    )
    BEGIN TRY
        -- Start the transaction
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[SD_Login_Master]
        (
            [User_Id],
            [Password],
            [User_Name],
            [Company_Id],
            [Sub_Company_Id],
            [Role_Id],
            [EMail],
            [Login_Type],
            [Active],
            [Flag],
            [Change_Password_Date],
            [Address],
            [IP_Address],
            [Location_Id],
            [Created_Date],
            [Created_By]
        )
        VALUES
        (@User_Id, @Password, @User_Name, IIF(ISNULL(@Company_Id,'') = '', 'BBI', @Company_Id), @Sub_Company_Id, @Role_Id, @EMail, @Login_Type, @Active, @Flag, @Change_Password_Date, @Address, @IP_Address, UPPER(@Location_Id), @Created_Date, UPPER(@Created_By))

        -- Commit the transaction if everything is successful
        COMMIT;
    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back the transaction
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH;
    ELSE
        SELECT 'User already exists!'
END;

GO

