-- =============================================
-- Author:      <Rashmi Gupta>
-- Create date: <25-01-2024>
-- Description: <Update the task if present already>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Update_Task]
     @User_Id VARCHAR(20)
    ,@Report_Id INT
    ,@Add_Date DATE
    ,@Submit_From_Date DATE
    ,@Submit_To_Date DATE
    ,@Submit_Week_No INT
    ,@Submit_Half_No INT
    ,@Location VARCHAR (MAX)
    ,@Created_By VARCHAR (20)
    ,@Rec_Id INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @User_Id = UPPER(TRIM(@User_Id));
    SET @Created_By = TRIM(@Created_By);

    BEGIN TRY    
    /*
        SP_Update_Task 'Test', 2, '2024-01-15', 'C:\Users\rashmi.gupta\Desktop\Crate_Transaction_09-10-2023 13_00_44.xls', 'Test'

        SP_Update_Task 'Test', 55, '2024-01-29', , , 0, 'C:\Users\rashmi.gupta\Desktop\Crate_Transaction_09-10-2023 13_00_44.xls', 'Test', 55 
    */
        IF EXISTS(SELECT * FROM SD_Performance WHERE REC_ID = @Rec_Id) --Check if record exists          
        BEGIN

            DECLARE @ReportType VARCHAR(50) = (SELECT RM.[Type] FROM SD_Reports_Master RM WHERE RM.Rec_ID = @Report_Id);

            BEGIN TRANSACTION;
            
            UPDATE [dbo].[SD_Performance]
            SET 
                [Active] = 0,
                [Comments] = NULL,
                [Modified_By] = @Created_By,
                [Modified_Date] = GETDATE()                   
            WHERE 
                Rec_ID = @Rec_Id;

            INSERT INTO [dbo].[SD_Performance]
            (
                 [User_Id]
                ,[Report_Id]
                ,[Report_Type]
                ,[Add_Date]
                ,[Month_From_Date]
                ,[Month_To_Date]
                ,[Month_Week_No]
                ,[Year_Half_No]
                ,[Location]
                ,[Created_By]
            )
            VALUES (@User_Id, @Report_Id, @ReportType, @Add_Date, @Submit_From_Date, @Submit_To_Date, @Submit_Week_No, @Submit_Half_No, @Location, @Created_By);
        END
        ELSE
            Select 'Please add the given task first!' [Message]
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

