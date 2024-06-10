-- =============================================
-- Author:      <Rashmi Gupta>
-- Create date: <25-01-2024>
-- Description: <Add the task if not present already>
-- =============================================
ALTER PROCEDURE [dbo].[SP_Add_Task]
    @User_Id VARCHAR(20),
    @Report_Id INT,
    @Add_Date DATE,
    @Submit_From_Date DATE,
    @Submit_To_Date DATE,
    @Submit_Week_No INT,
    @Submit_Half_No INT,
    @Location VARCHAR(MAX),
    @Created_By VARCHAR(20)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @User_Id = UPPER(@User_Id);
    SET @Created_By = UPPER(@Created_By);


    BEGIN TRY
     BEGIN TRANSACTION;
    
    /*
        SP_Add_Task 'Test', 95, '2024-01-30', '2024-01-01', '2024-01-31',1,  'C:\Users\rashmi.gupta\source\repos\Finance_Tracker\Finance_Tracker\Upload\Test_Weekly Cost review Week 1_30-Jan-2024.xls', 'Test'
    */
        DECLARE @ReportType VARCHAR(50) = (SELECT RM.[Type]
                                        FROM SD_Reports_Master RM
                                        WHERE RM.Rec_ID = @Report_Id);

        DECLARE @RecIdExist AS int = 0;
        SET @RecIdExist = (SELECT Rec_ID
                           FROM SD_Performance P
                           WHERE 
                              UPPER([User_Id]) = @User_Id 
                              AND [Report_Id] = @Report_Id 
                              AND [ACTIVE] = 1 
                              AND Month_From_Date = @Submit_From_Date 
                              AND Month_To_Date = @Submit_To_Date 
                              AND ((UPPER(@ReportType) = 'MONTHLY') OR (UPPER(@ReportType) ='WEEKLY' AND Month_Week_No = @Submit_Week_No) OR(UPPER(@ReportType) ='HALF YEARLY' AND Year_Half_No = @Submit_Half_No))
                           );
        IF (@RecIdExist != 0) --TASK EXISTS
        BEGIN
            SELECT 'Task is added already!' AS [Message];
        END
        ELSE
            BEGIN
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
                VALUES
                    (@User_Id, @Report_Id, @ReportType, @Add_Date, @Submit_From_Date, @Submit_To_Date, @Submit_Week_No, @Submit_Half_No, @Location, @Created_By);
            END
    
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH;
END
GO

