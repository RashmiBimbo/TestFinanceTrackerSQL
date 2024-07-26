
-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <12-01-2024>
-- Description:	<Get the performance>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Performance_Review_Plant]
    @Month CHAR(2) ,
    @Year  CHAR(4)
AS
BEGIN
    /*
        SP_Get_Performance_Review_Plant 01, 2024
    */

    DECLARE @UserIds NVARCHAR(MAX);
    DECLARE @DynamicPivotQuery NVARCHAR(MAX);

    -- Get the distinct User_Id values
    SELECT @UserIds = COALESCE(@UserIds + ', ', '') + QUOTENAME(User_Id)
    FROM (SELECT DISTINCT User_Id
        FROM SD_Login_Master WHERE Role_Id = 3) AS Users;

    -- Build the dynamic PIVOT query
    SET @DynamicPivotQuery = 
    '
    IF OBJECT_ID(''tempdb..#TEMP'') IS NOT NULL
        DROP TABLE #TEMP;
    
     DECLARE @MONTH AS CHAR(2) = '+ @MONTH +';
     DECLARE @YEAR AS CHAR(4) = '+ @YEAR +';

     DECLARE @DFORMAT AS CHAR(15) = ''dd-MMM-yyyy'';
     DECLARE @MFORMAT AS CHAR(15) = ''MMM, yyyy'';

     DECLARE @Prefix as VARCHAR(10) = ''Every '';

     SELECT ROW_NUMBER() OVER (ORDER BY REPORT_NAME ) SNo, *
     INTO #TEMP
     FROM
        (
            SELECT
                CM.[Category_Name] Category_Name,
                FORMAT(DATEFROMPARTS(@YEAR, @MONTH, 1), @MFORMAT) [Month],
                RM.[Report_Name],
                SP.[User_Id],
                SP.[Submit_Date],
                RM.[Priority],
                RM.[Weight],
              
                RM.[Due_Date],
                IIF(Submit_Date < CAST(DDate AS DATE), [Weight], 0) [Calculated_Weight],
                LM.[User_Name] AS [User_Name]  
            FROM
                dbo.SD_Performance AS SP
                RIGHT JOIN  DBO.SD_Login_Master LM ON SP.[User_Id] = LM.[User_Id]
                RIGHT JOIN dbo.SD_Reports_Master AS RM ON RM.Rec_ID = SP.Report_Id
                INNER JOIN dbo.SD_Category_Master AS CM ON CM.Rec_Id = RM.Category_Id
                INNER JOIN dbo.SD_Category_Type_Master AS CTM ON CM.Category_Type_Id = CTM.Rec_Id
                LEFT JOIN SD_Calender_Master CLM ON UPPER(RM.Due_Date) = UPPER(CLM.DaysName)
            UNION 
            SELECT
                CM.[Category_Name] AS Category_Name,
                FORMAT(DATEFROMPARTS(@YEAR, @MONTH, 1), @MFORMAT) AS [Month],
                RM.[Report_Name] AS [Report_Name],
                SP.[User_Id],
                SP.[Submit_Date],
                RM.[Priority],
                RM.[Weight],              
                RM.[Due_Date],
                IIF(Submit_Date < CAST(DDate AS DATE), [Weight], 0) [Calculated_Weight],
                LM.[User_Name] AS [User_Name]  
            FROM
                dbo.SD_Performance AS SP
                RIGHT JOIN dbo.SD_Login_Master AS LM ON SP.[User_Id] = LM.[User_Id]
                RIGHT JOIN dbo.SD_Reports_Master AS RM ON RM.Rec_ID = SP.Report_Id
                INNER JOIN dbo.SD_Category_Master AS CM ON CM.Rec_Id = RM.Category_Id
                INNER JOIN dbo.SD_Category_Type_Master AS CTM ON CM.Category_Type_Id = CTM.Rec_Id
                LEFT JOIN SD_Calender_Master CLM ON RM.Due_Date = CLM.Day
            WHERE 
                (CM.Active = 1)
                AND (RM.Active = 1)
                AND (SP.Active = 1 OR SP.Active IS NULL)
                AND (LM.Active = 1 OR LM.Active IS NULL)
                AND CLM.YYear = @YEAR
                AND CLM.MonthNo = @MONTH
        ) TBL;    

    SELECT * FROM #TEMP;

    SELECT
        P.SNo,
        P.Category_Name,
        P.Month,
        --P.Submission_Due_Date AS [Due Date],
        P.Report_Name,
        P.Priority,
        P.Weight,
        P.[User_Name],
        ' + @UserIds + '
    FROM 
        (
            SELECT SNo, Category_Name, Month, Report_Name, Priority, Weight, [User_Name]
            --, Submission_Due_Date
            FROM #TEMP
        ) P
        INNER JOIN 
        (
            SELECT SNO, ' + @UserIds + '
            FROM #TEMP
            PIVOT 
            (
                MAX(Submit_Date) FOR User_Id IN (' + @UserIds + ')
            ) PivotTable
        ) P1 ON P.SNo = P1.SNO

    UNION

    SELECT
        P1.SNo,
        P1.Category_Name,
        P1.Month,
       -- P1.Submission_Due_Date AS [Due Date],
        P1.Report_Name,
        P1.Priority,
        P1.Weight,
        NULL AS [User_Name], -- Assuming User_Name is not present in P1
        ' + @UserIds + '
    FROM
        (
            SELECT SNO, Category_Name, Month,
       -- P1.Submission_Due_Date AS [Due Date],
         Report_Name,
         Priority,
         Weight,
        NULL AS [User_Name],
        ' + @UserIds + '
            FROM #TEMP
                PIVOT 
                (
                    SUM(Calculated_Weight) FOR User_Id IN (' + @UserIds + ')
                ) PivotTable
        ) P1;';
 
    -- Execute the dynamic query
    EXEC sp_executesql @DynamicPivotQuery;
END;

GO

