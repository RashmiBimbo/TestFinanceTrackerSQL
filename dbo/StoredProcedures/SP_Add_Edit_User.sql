-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <04-01-2023>
-- Description:	<Add/Edit User in SD_Login_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Add_Edit_User]
    @User_Name VARCHAR(250),
    @Role_Id INT,
    @EMail NVARCHAR(320),
    @Login_Type CHAR(1) = NULL,
    @Location_Id VARCHAR(20) = NULL,
    @Address VARCHAR(MAX) = NULL,
    @Created_By VARCHAR(250) = 'ADMIN',
    @Rec_Id BIGINT = 0,
    @User_Id VARCHAR(20),
    @Password VARCHAR(MAX),
    @IP_Address VARCHAR(30) = NULL,
    @Company_Id VARCHAR(10) = NULL,
    @Sub_Company_Id VARCHAR(10) = NULL,
    @Active BIT = 1,
    @Flag BIT = 1,
    @Change_Password_Date DATE = NULL,
    @Created_Date DATETIME = NULL
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

    BEGIN TRY
        -- Start the transaction
        BEGIN TRANSACTION;
    
        IF @Rec_Id = 0 AND NOT EXISTS
        (
            SELECT * FROM [dbo].[SD_Login_Master] WHERE DBO.[CapsStr]([User_Id]) =  DBO.[CapsStr](@User_Id)
        )
        BEGIN
            INSERT INTO [dbo].[SD_Login_Master]
            (
                [User_Id], [Password], [User_Name], [Company_Id], [Sub_Company_Id], [Role_Id], [EMail], [Login_Type], [Active], [Flag], [Change_Password_Date], [Address], [IP_Address], [Location_Id], [Created_Date], [Created_By]
            )
            VALUES
            (@User_Id, @Password, @User_Name, IIF(ISNULL(@Company_Id,'') = '', 'BBI', @Company_Id), @Sub_Company_Id, @Role_Id, @EMail, @Login_Type, @Active, @Flag, @Change_Password_Date, @Address, @IP_Address, UPPER(@Location_Id), IIF(@Created_Date is null, GETDATE(), @Created_Date), UPPER(@Created_By))
        END
        ELSE IF EXISTS
        (
            SELECT * FROM [dbo].[SD_Login_Master] WHERE UPPER([User_Id]) = UPPER(@User_Id) AND Rec_Id = @Rec_Id
        )
        BEGIN
            UPDATE [dbo].[SD_Login_Master]
            SET
                [User_Name] = @User_Name,
                [Role_Id] = @Role_Id,
                [EMail] = @EMail,
                [Login_Type] = @Login_Type,
                [Location_Id] = @Location_Id,
                [Address] = @Address,
                [Modified_Date] = IIF(@Created_Date IS NULL, GETDATE(), @Created_Date),
                [Modified_By] = @Created_By
            WHERE Rec_Id = @Rec_Id
        END
        ELSE
        SELECT 'User already exists!'

        -- Commit the transaction if everything is successful
        COMMIT;
    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back the transaction
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH;
END;
GO

