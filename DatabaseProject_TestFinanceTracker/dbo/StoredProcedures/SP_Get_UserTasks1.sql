-- =============================================
-- Author:      <Rashmi Gupta>
-- Create date: <25-01-2024>
-- Description: <Select tasks which are not added in SD_Performance table for a particular user. Its used in Performance.GVAddDS>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_UserTasks1]
    @User_Id VARCHAR(20) = NULL
   ,@From_Date DATE = NULL
   ,@To_Date DATE = null
   ,@WeekNo int = 0
   ,@Report_Type VARCHAR(50) = NULL
   ,@Half_No INT = 0
   ,@Report_Id INT = 0
AS
BEGIN
    /*
        SP_Get_UserTasks1 '', '2024-03-01', '2024-03-31', 0,'W'
        SP_Get_UserTasks1 'ashish', '2024-02-01', '2024-02-29', 0,'W'
        SP_Get_UserTasks1 NULL, NULL, NULL, 0, NULL, 0, 0
    */
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @NxtMnthToDt DATE = DATEADD(MONTH, 1, @To_Date);
    DECLARE @NxtMnthLastDt INT = Day(EOMONTH(@NxtMnthToDt));
     
    SET @User_Id = UPPER(TRIM(@User_Id));
    SET @Report_Type = UPPER(TRIM(@Report_Type));

    BEGIN TRY
    
        SELECT 
            ROW_NUMBER() OVER (ORDER BY Due_Date)  Sno,  *
            FROM 
            (
                SELECT DISTINCT
                 TRIM(UTA.ReportName) Task_Name
                -- ,IIF(RM.[Type] = 'W', 'Weekly', 'Monthly') [Type]
                ,[Type]
                ,RM.Priority
                ,RM.Weight
                ,IIF
                (
                     ISNUMERIC(RM.Due_Date) = 1
                     ,CASE
                        WHEN RM.Due_Date = '41' THEN '01-Jan-'+ CAST(YEAR(GETDATE()) AS VARCHAR(4))  --Report for First Half
                        WHEN RM.Due_Date = '42' THEN '01-Jul-'+ CAST(YEAR(GETDATE()) AS VARCHAR(4))  --Report for 2nd Half
                        ELSE 
                        FORMAT
                         (   -- dd-MMM-yyyy format e.g. 10-Jan-2024
                            DATEFROMPARTS
                            (
                               YEAR(@NxtMnthToDt), MONTH(@NxtMnthToDt),          --take next month' month no. and year
                               IIF( RM.Due_Date > @NxtMnthLastDt, @NxtMnthLastDt, RM.Due_Date) --e.g. if duedt is > 28 and next month is feb, return                                    
                            )
                            ,'dd-MMM-yyyy'                            
                         )
                    END 
                    -- Every Weekday e.g. Every Thusrday
                    ,IIF
                     (
                         ISNULL(TRIM(RM.Due_Date),'') = '', 
                         '',
                         'Every ' + LEFT(UPPER(TRIM(RM.Due_Date)), 1) + SUBSTRING(LOWER(TRIM(RM.Due_Date)), 2, LEN(TRIM(RM.Due_Date)) - 1)
                     )
                ) 
                [Due_Date]
                ,UPPER(TRIM(UTA.UserId)) UserId
                ,UTA.ReportId
                ,UPPER(TRIM(RM.[Type])) Type_Orgnl
                ,TRIM(RM.Due_Date)  Due_Date_OrgnL
                ,UTA.RecId, P.Year_Half_No
                ,UPPER(TRIM(UTA.Approver)) Approver
                FROM 
                    [dbo].[SD_UserTaskAssignment] UTA
                INNER JOIN 
                    SD_Reports_Master RM ON RM.Rec_ID = UTA.ReportId
                INNER JOIN 
                    SD_Login_Master LM ON UPPER(TRIM(LM.User_Id)) = UPPER(TRIM(UTA.UserId))
                LEFT JOIN           --exclude the already added tasks for given date range
                        SD_Performance P ON UPPER(TRIM(P.User_Id)) = UPPER(TRIM(UTA.UserId)) 
                        AND 
                        P.Report_Id = UTA.ReportId
                        AND 
                        P.Active = 1 
                        AND 
                        P.Month_From_Date >=  IIF(ISNULL(@From_Date,'') = '', P.Month_From_Date, @From_Date)--COALESCE(NULLIF(@From_Date,''), P.Month_From_Date)
                        AND 
                        P.Month_To_Date <= IIF(ISNULL(@To_Date,'') = '', P.Month_To_Date, @To_Date)
                        AND 
                        (
                            UPPER(TRIM(RM.[Type])) = 'MONTHLY' OR ISNULL(TRIM(RM.[Type]),'') = '' 
                            OR  
                            (
                               UPPER(TRIM(RM.[Type])) = 'WEEKLY' AND (P.Month_Week_No = IIF(@WeekNo = 0, P.Month_Week_No, @WeekNo)) 
                            )
                            OR  
                            (
                               UPPER(TRIM(RM.[Type])) = 'HALF YEARLY' AND (ISNULL(P.Year_Half_No, 0) = IIF(@Half_No = 0, ISNULL(P.Year_Half_No, 0), @Half_No)) 
                            )
                        )
                WHERE
                P.User_Id IS NULL
                AND
                UPPER(TRIM(RM.[Type])) =  IIF(ISNULL(@Report_Type,'')='', UPPER(TRIM(RM.[Type])), @Report_Type)
                AND
                UTA.Approver IS NOT NULL
                AND 
                UPPER(TRIM(UTA.UserId)) = IIF(ISNULL(@User_Id,'')='', UPPER(TRIM(UTA.UserId)), @User_Id)
                AND 
                UTA.Active = 1
                AND 
                RM.Active = 1
                AND 
                LM.Active = 1
                AND 
                (
                    @Half_No = 0
                    OR
                    @Half_No = 1 AND RM.Due_Date = '41'
                    OR  
                    @Half_No = 2 AND RM.Due_Date = '42'
                )
                AND 
                UTA.ReportId = COALESCE(NULLIF(@Report_Id, 0), UTA.ReportId)  
            ) TBL         
            ORDER BY 
                Due_Date, Task_Name, UserId ASC
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE();
    END CATCH;
END;
GO

