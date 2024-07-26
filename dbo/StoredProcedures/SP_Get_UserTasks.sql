-- =============================================
-- Author:      <Rashmi Gupta>
-- Create date: <25-01-2024>
-- Description: <Select tasks which are not added in SD_Performance table for a particular user. Its used in Performance.GVAddDS>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_UserTasks]
    @User_Id VARCHAR(20) = NULL
   ,@From_Date DATE = NULL
   ,@To_Date DATE = null
   ,@ReportTypeId INT = 0
   ,@WeekNo int = 0
   ,@Quarter_No INT = 0
   ,@Half_No INT = 0
   ,@Report_Id INT = 0
AS
BEGIN
    /*
        SP_Get_UserTasks 'ASHISH', '2024-05-01', '2024-05-31', 3,0, 1, 0 
        SP_Get_UserTasks 'ASHISH', '2024-03-01', '2024-03-31', 4, 0, 0, 0, 0 
        SP_Get_UserTasks 'ashish', '2024-04-01', '2024-04-30', 1,'W'
        SP_Get_UserTasks NULL, NULL, NULL, 0, NULL, 0, 0
    */
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
     
    SET @User_Id = UPPER(TRIM(@User_Id));
    -- SET @Report_Type = UPPER(TRIM(@Report_Type));

    BEGIN TRY    
        SELECT 
            ROW_NUMBER() OVER (ORDER BY Due_Date) Sno, *
            FROM 
            (
                SELECT DISTINCT
                 TRIM(RM.Report_Name) Task_Name
                ,RTM.[TypeName] [Type]
                ,RM.Priority
                ,RM.Weight
                ,UTM.[DueDate] Due_Date
                ,UPPER(TRIM(LM.User_Id)) UserId
                ,UTM.ReportId
                ,UPPER(TRIM(RTM.[TypeName])) Type_Orgnl
                ,TRIM(RM.Due_Date) Due_Date_OrgnL
                ,UTM.RecId, P.Year_Half_No
                ,UPPER(TRIM(UTA.Approver)) Approver
                FROM 
                    [dbo].[SD_UsersTasksMonthly] UTM
                INNER JOIN 
                    SD_UserTaskAssignment UTA ON UTA.UserId = UTM.UserId AND UTA.ReportId = UTM.ReportId
                INNER JOIN 
                    SD_Reports_Master RM ON RM.Rec_ID = UTM.ReportId
                INNER JOIN 
                    SD_Login_Master LM ON UPPER(TRIM(LM.User_Id)) = UPPER(TRIM(UTM.UserId))
                INNER JOIN
                    SD_ReportType_Master RTM ON RM.TypeId = RTM.RecId

                LEFT JOIN           --exclude the already added tasks for given date range
                    SD_Performance P ON UPPER(TRIM(P.User_Id)) = UPPER(TRIM(UTM.UserId)) 
                    AND 
                    P.Report_Id = UTM.ReportId
                    AND 
                    P.Active = 1 
                    AND 
                    P.Month_From_Date >=  IIF(ISNULL(@From_Date,'') = '', P.Month_From_Date, @From_Date)
                    AND 
                    P.Month_To_Date <= IIF(ISNULL(@To_Date,'') = '', P.Month_To_Date, @To_Date)
                    AND 
                    (
                        (RTM.RecId > 1)
                        OR
                        (RTM.RecId = 1  AND (P.Month_Week_No = IIF(@WeekNo = 0, P.Month_Week_No, @WeekNo)))  --Added task is weekly
                        -- OR  
                        -- ( RTM.RecId = 3  AND (P.Year_Quarter_No = IIF(@Quarter_No = 0, P.Year_Quarter_No, @Quarter_No)))  --Added task is weekly
                        -- OR  
                        -- ( RTM.RecId = 4  AND (ISNULL(P.Year_Half_No, 0) = IIF(@Half_No = 0, ISNULL(P.Year_Half_No, 0), @Half_No)))  --Added task is halfyearly
                    )
                WHERE
                P.User_Id IS NULL
                AND
                RTM.RecId = COALESCE(NULLIF(@ReportTypeId, 0), RTM.RecId)
                AND
                UTA.Approver IS NOT NULL
                AND 
                UPPER(TRIM(UTM.UserId)) = IIF(ISNULL(@User_Id,'')='', UPPER(TRIM(UTM.UserId)), @User_Id)
                AND 
                UTM.Active = 1 AND UTA.Active = 1 AND RM.Active = 1 AND LM.Active = 1 AND RTM.Active = 1 
                -- AND 
                -- (
                --     @Half_No = 0 OR (@Half_No = 1 AND RM.Due_Date = '41') OR (@Half_No = 2 AND RM.Due_Date = '42')
                -- )
                -- AND 
                -- (
                --     @Quarter_No = 0 OR (@Quarter_No = 1 AND RM.Due_Date = '51') OR (@Quarter_No = 2 AND RM.Due_Date = '52') 
                --     OR (@Quarter_No = 3 AND RM.Due_Date = '53') OR (@Quarter_No = 4 AND RM.Due_Date = '54')
                -- )
                AND 
                UTM.MONTH = MONTH(@From_Date)-1
                AND 
                UTM.ReportId = COALESCE(NULLIF(@Report_Id, 0), UTM.ReportId)  
            ) TBL         
            ORDER BY 
                [Due_Date], Task_Name, UserId ASC
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE();
    END CATCH;
END;
GO

