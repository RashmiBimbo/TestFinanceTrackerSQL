SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <12-01-2024>
-- Description:	<Get the added/submitted/approved tasks from sd_performance>
-- =============================================
ALTER PROCEDURE [dbo].[SP_Get_Tasks]
    @Start_Date DATE = NULL,
    @End_Date DATE = NULL,
    @User_Id VARCHAR(20) = null,
    @Role_Id INT = 0,
    @Category_Type_Id INT = 0,
    @Category_Id INT = 0,
    @Report_Id INT = 0,
    @Type VARCHAR(50) = '',
    @IsApproved bit = 0,
    @ApprYearNo int = 0,
    @ApprMonthNo int = 0,
    @ApprWeekNo int = 0,
    @Location_Id varchar(20) = NULL 
AS
BEGIN
    /*
    SP_Get_Tasks  '2024-02-01', '2024-02-29', 'ASHISH', 2, 16
    SP_Get_Tasks  '2024-03-01', '2024-03-31', 'ASHISH', 2, 16
    SP_Get_Tasks  NULL, NULL, NULL, 0, 0, 0, 0, '', 1, 0, 0, 0 
    SP_Get_Tasks  NULL, NULL, NULL, 0, 0, 0, 0, '', 0, 0, 0, 0, '' 
    SP_Get_Tasks  NULL, NULL, '', 0, 0, 0, 0, '', 1, 3, 1, 2024 
    */
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @NxtMnthToDt DATE = DATEADD(MONTH, 1, @End_Date);
    DECLARE @NxtMnthLastDt INT = DAY(EOMONTH(@NxtMnthToDt));
    DECLARE @FebLstDay INT = IIF((YEAR(GETDATE()) % 4 = 0) AND (YEAR(GETDATE()) % 100 != 0) OR (YEAR(GETDATE()) % 400 = 0), 29, 28);
    DECLARE @DateFormat VARCHAR(10) = 'dd-MMM-yyyy';
    DECLARE @CrntMnth AS int = MONTH(GETDATE());
    DECLARE @PreMnth AS int = MONTH(DATEADD(MONTH, -1, GETDATE())) ;

    SET @User_Id = UPPER(TRIM(@User_Id));
    SET @Location_Id = UPPER(TRIM(@Location_Id));
    SET @Type = UPPER(TRIM(@Type));

    IF (@ApprWeekNo != 0)
    BEGIN
        IF OBJECT_ID('tempDB..#TEMP', 'U') IS NOT NULL
            DROP TABLE #TEMP;

        SELECT ROW_NUMBER() OVER (ORDER BY WeekNo) RowNum, WeekNo INTO #TEMP
            FROM (
                SELECT DISTINCT T.WeekDaysCount WeekNo
                FROM [dbo].[SD_Calender_Master] t
                WHERE yyear = IIF(@ApprYearNo = 0, yyear, @ApprYearNo) AND t.MonthNo = IIF(@ApprMonthNo = 0, MonthNo, @ApprMonthNo)
            ) TBL;
        SET @ApprWeekNo = (SELECT WeekNo FROM #TEMP WHERE RowNum = @ApprWeekNo);
        --SELECT @ApprWeekNo;
    END

    SELECT
        Row_Number() OVER (ORDER BY Submit_Date, Add_Date DESC, Due_Date DESC, [User_Name], Category_Name, Report_Name, [Type]) [Sno], *
        FROM
        (
            SELECT
                 LM.[User_Name] [User_Name]
                ,CM.[Category_Name] [Category_Name]
                ,CTM.[Category_Type_Name] [Category_Type]
                ,RM.[Report_Name] [Report_Name]
                ,RM.Due_Date [Due_Date_Orgnl]
                ,IIF
                (
                    ISNUMERIC(RM.Due_Date) = 1
                    ,CASE
                        WHEN RM.Due_Date = '41' THEN '01-Jan-'+ CAST(YEAR(GETDATE()) AS VARCHAR(4))  --Report for First Half
                        WHEN RM.Due_Date = '42' THEN '01-Jul-'+ CAST(YEAR(GETDATE()) AS VARCHAR(4))  --Report for 2nd Half
                        ELSE 
                        CASE
                            WHEN RM.Due_Date > 28 THEN
                               CASE --when mnth is FEB and Due date is more than 28
                                   WHEN MONTH(SP.Month_To_Date) = 2 THEN                                      
                                        FORMAT
                                        (   -- dd-MMM-yyyy format e.g. 10-Jan-2024
                                           DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(SP.Month_To_Date), MONTH(SP.Month_To_Date), @FebLstDay)), @DateFormat
                                        ) -- Non-leap year February
                                    ELSE
                                        CASE -- when given Due date is 31 but mnth has only 30 days
                                            WHEN ISDATE(CONVERT(varchar, DATEFROMPARTS(YEAR(SP.Month_To_Date), MONTH(SP.Month_To_Date), RM.Due_Date))) = 0 THEN 
                                             FORMAT
                                             (  
                                                DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(SP.Month_To_Date), MONTH(SP.Month_To_Date), 30)), @DateFormat
                                             )
                                            ELSE
                                             FORMAT
                                             (   
                                                DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(SP.Month_To_Date), MONTH(SP.Month_To_Date), RM.Due_Date)), @DateFormat
                                             )
                                        END
                               END
                            ELSE
                            FORMAT
                            (  
                               DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(SP.Month_To_Date), MONTH(SP.Month_To_Date), RM.Due_Date)), @DateFormat
                            )
                        END
                    END
                    ,IIF
                     (
                    -- Every Weekday e.g. Every Thusrday
                        ISNULL(TRIM(RM.Due_Date),'') = '', 
                        '',
                        'Every ' + LEFT(UPPER(TRIM(RM.Due_Date)), 1) + SUBSTRING(LOWER(TRIM(RM.Due_Date)), 2, LEN(TRIM(RM.Due_Date)) - 1)
                     )
                ) 
                [Due_Date]
                ,SP.Month_From_Date [From_Date]
                ,SP.Month_To_Date [To_Date]
                ,SP.Month_Week_No [Week_No]            
                ,SP.Year_Half_No [Half_No]            
                ,FORMAT( SP.[Add_Date], @DateFormat ) [Add_Date]
                ,FORMAT( SP.[Submit_Date], @DateFormat ) [Submit_Date]
                ,IIF
                ( 
                    SP.[Submit_Date] IS NULL,
                    IIF(ISNULL(TRIM(SP.Comments), '') = '', 'Pending Submission', 'Rejected'),
                    IIF(Approve_Date IS NULL, 'Pending Approval', 'Approved')
                )
                [Status]
                ,[Type]
                ,FORMAT( SP.[Approve_Date], @DateFormat ) [Approve_Date]
                ,SP.[Location]
                ,CASE 
                    WHEN MONTH(Month_To_Date) BETWEEN @PreMnth AND @CrntMnth THEN 'Edit'
                    ELSE 'View'
                 END
                BtnText
                ,SP.Comments 
                ,SP.Rec_ID [Task_Id]
                ,RM.Rec_ID [Report_Id]
                ,UPPER(TRIM(LM.Location_Id)) Location_Id
                ,CTM.Rec_ID CatTypeId
                ,CM.Rec_Id CatId
            FROM dbo.SD_Performance SP
                INNER JOIN dbo.SD_Reports_Master RM ON RM.Rec_ID = SP.Report_Id 
                INNER JOIN dbo.SD_Login_Master LM ON UPPER(TRIM(SP.[User_Id])) = UPPER(TRIM(LM.[User_Id]))
                INNER JOIN dbo.SD_Category_Master CM ON CM.Rec_Id = RM.Category_Id
                INNER JOIN dbo.SD_Category_Type_Master CTM ON CM.Category_Type_Id = CTM.Rec_Id
            WHERE 
                Month_From_Date >= IIF(@Start_Date IS NULL, Month_From_Date, @Start_Date) 
                AND Month_To_Date <= IIF(@End_Date IS NULL, Month_To_Date, @End_Date)
                AND UPPER(TRIM(LM.User_Id)) = IIF(ISNULL(@User_Id,'') = '', UPPER(TRIM(LM.User_Id)), @User_Id)
                AND LM.Role_Id = IIF(@Role_Id < 1, LM.Role_Id, @Role_Id)
                AND CTM.Rec_ID = IIF(ISNULL(@Category_Type_Id,'') = '', CTM.Rec_Id, @Category_Type_Id)
                AND CM.Rec_ID = IIF(ISNULL(@Category_Id,'') = '', CM.Rec_Id, @Category_Id)
                AND RM.Rec_ID = IIF(ISNULL(@Report_Id,'') = '', RM.Rec_Id, @Report_Id)
                AND UPPER(TRIM(RM.[Type])) = IIF(ISNULL(@Type,'') = '', UPPER(TRIM(RM.[Type])), @Type)
                AND (CM.Active = 1)
                AND (RM.Active = 1)
                AND (SP.Active = 1)
                AND (LM.Active = 1)
                AND UPPER(TRIM(LM.Location_Id)) = IIF(ISNULL(@Location_Id,'') = '', UPPER(TRIM(LM.Location_Id)), @Location_Id)
                AND 
                (
                    (
                        @IsApproved = 0 AND SP.Approve_Date IS NULL
                    -- AND Submit_Date IS NULL
                    )
                    OR
                    (
                        @IsApproved = 1 
                        AND 
                        -- SP.Submit_Date IS NOT NULL
                        SP.Approve_Date IS NOT NULL
                        AND YEAR(Submit_Date)= IIF(@ApprYearNo = 0, YEAR(Submit_Date), @ApprYearNo)
                        AND MONTH(Submit_Date) = IIF(@ApprMonthNo = 0, MONTH(Submit_Date), @ApprMonthNo)
                        --AND DATEPART(WEEK, Submit_Date) = IIF(@ApprWeekNo = 0, DATEPART(WEEK, Submit_Date), @ApprWeekNo)
                    )
                )                
        ) SQ
        -- ORDER BY Submit_Date, Add_Date DESC, Due_Date DESC, [User_Name], Category_Name, Report_Name, [Type];        
--                 ,IIF
--                 (
--                     ISNUMERIC(Due_Date) = 1 
--                     ,FORMAT
--                      (   -- dd-MMM-yyyy format e.g. 10-Jan-2024
--                         DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(SP.Month_To_Date), MONTH(SP.Month_To_Date), RM.Due_Date)), @DateFormat
--                      )
--                     -- Every Weekday e.g. Every Thusrday
--                     -- ,'Every ' + LEFT(RM.Due_Date,1) + SUBSTRING(LOWER(RM.Due_Date), 2, LEN(RM.Due_Date) - 1)
--                         -- Every Weekday e.g. Every Thusrday
--                     ,IIF
--                      (
--                          TRIM(ISNULL(RM.Due_Date,'')) = '', 
--                          '',
--                          'Every ' + LEFT(UPPER(TRIM(RM.Due_Date)), 1) + SUBSTRING(LOWER(TRIM(RM.Due_Date)), 2, LEN(TRIM(RM.Due_Date)) - 1)
--                      )
--                 ) 
--                 [Due_Date]
END;

GO
