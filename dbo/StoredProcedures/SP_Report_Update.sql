-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <05-01-2024>
-- Description:	<Get the Category Type from SD_Category_Type_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Report_Update]
     @Name        VARCHAR(150) 
    ,@Category_Id INT     
    ,@Priority    INT 
    ,@Weight      INT 
    ,@Type_Id     INT 
    ,@Due_Date    VARCHAR(10) 
    ,@Modified_By VARCHAR(20) 
    ,@TypeName    VARCHAR(50)     
    ,@RecId       INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    BEGIN TRY

        SET @Due_Date = UPPER(TRIM(@Due_Date));
        SET @Name = TRIM(@Name);
        SET @Modified_By = UPPER(TRIM(@Modified_By));

        IF EXISTS
        (
            SELECT *
            FROM [dbo].[SD_Reports_Master] RM
            WHERE RM.Rec_ID = @RecId
        )
        BEGIN
            IF EXISTS 
            (
                --Check if the same report name exists with given category
                SELECT *
                FROM [dbo].[SD_Reports_Master] RM
                WHERE TRIM(RM.Report_Name) = @Name AND Category_Id = @Category_Id AND Active = 1 AND RM.Rec_ID != @RecId
            ) 
            BEGIN
                Select Error = 'Report name already exists in selected category!'
                RETURN;
            END
            ELSE
            BEGIN            
                BEGIN TRANSACTION;

                UPDATE SD_Reports_Master
                SET
                    [Report_Name] = @Name
                   ,[Category_Id] = @Category_Id
                   ,[Priority] = @Priority
                   ,[Weight] = @Weight
                   ,[TypeId] = @Type_Id
                   ,[Due_Date] = @Due_Date
                   ,[Type] = @TypeName
                   ,[Modified_By] = @Modified_By 
                   ,[Modified_Date] = GETDATE()
                WHERE Rec_ID = @RecId            
                COMMIT;                    
            END
        END
        ELSE
            SELECT 'Report does not exist!'
    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back the transaction
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH;
END;
GO

