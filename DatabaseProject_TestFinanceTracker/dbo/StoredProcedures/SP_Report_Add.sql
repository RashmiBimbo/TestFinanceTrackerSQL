-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <05-01-2024>
-- Description:	<Get the Category Type from SD_Category_Type_Master>
-- =============================================
ALTER PROCEDURE [dbo].[SP_Report_Add]
     @Name        VARCHAR(150) 
    ,@Category_Id INT     
    ,@Priority    INT 
    ,@Weight      INT 
    ,@Type_Id     INT
    ,@Due_Date    VARCHAR(10) 
    ,@Created_By  VARCHAR(20)     
    ,@TypeName    VARCHAR(50) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    BEGIN TRY

        SET @Created_By = UPPER(TRIM(@Created_By));
        SET @Due_Date = UPPER(TRIM(@Due_Date));
        SET @Name = TRIM(@Name);

        IF NOT EXISTS
        (
            SELECT *
            FROM [dbo].[SD_Reports_Master] RM
            WHERE UPPER(TRIM(RM.[Report_Name])) = UPPER(@Name) AND Category_Id = @Category_Id AND ACTIVE = 1
        )
        BEGIN
            -- Start the transaction
            BEGIN TRANSACTION;

            INSERT INTO [dbo].[SD_Reports_Master]
            (
                [Report_Name], [Category_Id], [Priority], [Weight], [TypeId], [Due_Date], [Created_By], [Type]
            )
            VALUES
            ( @Name ,@Category_Id ,@Priority ,@Weight, @Type_Id  ,@Due_Date ,@Created_By, @TypeName)

            COMMIT;        
        END
        ELSE
            SELECT 'Report already exists in selected category!'
    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back the transaction
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH;
END;
GO

