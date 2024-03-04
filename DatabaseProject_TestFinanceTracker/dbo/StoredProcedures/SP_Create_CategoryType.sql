-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <05-01-2024>
-- Description:	<Get the Category Type from SD_Category_Type_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Create_CategoryType]
    @Name VARCHAR(50),
    @Created_By VARCHAR(20)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SET @Name = UPPER(@Name);
    SET @Created_By = UPPER(@Created_By);
    IF NOT EXISTS
    (
        SELECT *
        FROM [dbo].[SD_Category_Type_Master] CM
        WHERE UPPER(CM.[Type_Name]) = @Name
    )
    BEGIN TRY
        -- Start the transaction
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[SD_Category_Type_Master]
        (
            [Type_Name],
            [Created_By]
        )
        VALUES
        (@Name, @Created_By)

        -- Commit the transaction if everything is successful
        COMMIT;
    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back the transaction
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH;
    ELSE
        SELECT 'Category Type already exists!'
END;

GO

