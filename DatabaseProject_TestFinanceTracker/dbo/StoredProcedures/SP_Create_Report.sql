-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <08-01-2024>
-- Description:	<Get the Reports Type from SD_Reports_Type_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Create_Report]
    @Report_Name VARCHAR(150),
    @Category_Id INT,    
    @Priority INT,    
    @Weight INT,    
    @Type INT,
    @Due_Date date,
    @Created_By VARCHAR(20)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SET @Report_Name = UPPER(@Report_Name);
    SET @Created_By = UPPER(@Created_By);

    IF NOT EXISTS
    (
        SELECT *
        FROM [dbo].[SD_Reports_Master] CM
        WHERE UPPER(CM.[Report_Name]) = @Report_Name AND Category_Id= @Category_Id
    )
    BEGIN TRY
        -- Start the transaction
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[SD_Reports_Master]
        (
            [Report_Name],
            [Category_Id],
            [Priority],
            [Weight],
            [Type],
            [Due_Date],
            [Created_By]
        )
        VALUES
        (@Report_Name, @Category_Id, @Priority, @Weight, @Type, @Due_Date, @Created_By)

        -- Commit the transaction if everything is successful
        COMMIT;
    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back the transaction
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH;
    ELSE
        SELECT 'Report already exists!'
END;

GO

