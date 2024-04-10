SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <12-02-2024>
-- Description:	<Get the tasks submitted by the SubOrdinates of a particular approver in a date range>
-- =============================================
-- Create the stored procedure in the specified schema
ALTER PROCEDURE [dbo].[SP_Get_Submit_Tasks_SubOrdinates]
	@From_Date DATE = NULL
   ,@To_Date DATE = NULL
   ,@Type char(50) = NULL
   ,@Approver_Id varchar(20) = NULL
   ,@IsApproved bit = 0
   ,@User_Id varchar(20) = NULL
   ,@Report_Id int = 0
   ,@Role_Id int = 0
   ,@Location_Id varchar(20) = NULL
AS
BEGIN

/*
    SP_Get_Submit_Tasks_SubOrdinates '2023-12-01', '2024-01-31', 'MONTHLY', 'ASHISH', 1'BLR',99
    SP_Get_Submit_Tasks_SubOrdinates NULL, NULL, '', 'ASHISH', 1'BLR',99
    SP_Get_Submit_Tasks_SubOrdinates NULL, NULL, '', '', 0, '', 0, 0, 'che'
    SP_Get_Submit_Tasks_SubOrdinates NULL, NULL, '', '', 1 
    SP_Get_Submit_Tasks_SubOrdinates NULL, NULL, '', 'Half Yearly', 1, '', 0, 3, 'che'
*/
    DECLARE @FebLstDay INT = IIF((YEAR(GETDATE()) % 4 = 0) AND (YEAR(GETDATE()) % 100 != 0) OR (YEAR(GETDATE()) % 400 = 0), 29, 28);
    DECLARE @DateFormat VARCHAR(10) = 'dd-MMM-yyyy';
	SET @Approver_Id = UPPER(TRIM(@Approver_Id)); 
	SET @User_Id = UPPER(TRIM(@User_Id)); 
	SET @Type = UPPER(TRIM(@Type)); 
	SET @Location_Id = UPPER(TRIM(@Location_Id)); 

    SELECT 
        ROW_NUMBER() OVER (ORDER BY Due_Date, [User_Name], Report_Name, Submit_Date DESC) [Sno], *
    FROM
    (
        SELECT 
         LM.[User_Name], CTM.Category_Type_Name, CM.Category_Name, RM.Report_Name, P.[Location], P.Rec_ID Task_Id, RM.Due_Date [Due_Date_Orgnl], U.[UserId]
        ,P.Month_From_Date, P.Month_To_Date, U.Approver, U.ReportId , RM.[Type] Type_Orgnl, P.Approve_Date Appr_Date_Orgnl, LM.Role_Id, LM.Location_Id
        ,RM.[Type] [Type]
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
                           WHEN MONTH(P.Month_To_Date) = 2 THEN                                      
                                FORMAT
                                (   -- dd-MMM-yyyy format e.g. 10-Jan-2024
                                   DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(P.Month_To_Date), MONTH(P.Month_To_Date), @FebLstDay)), @DateFormat
                                ) -- Non-leap year February
                            ELSE
                                CASE -- when given Due date is 31 but mnth has only 30 days
                                    WHEN ISDATE(CONVERT(varchar, DATEFROMPARTS(YEAR(P.Month_To_Date), MONTH(P.Month_To_Date), RM.Due_Date))) = 0 THEN 
                                     FORMAT
                                     (  
                                        DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(P.Month_To_Date), MONTH(P.Month_To_Date), 30)), @DateFormat
                                     )
                                    ELSE
                                     FORMAT
                                     (   
                                        DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(P.Month_To_Date), MONTH(P.Month_To_Date), RM.Due_Date)), @DateFormat
                                     )
                                END
                       END
                    ELSE
                    FORMAT
                    (  
                       DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(P.Month_To_Date), MONTH(P.Month_To_Date), RM.Due_Date)), @DateFormat
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
        , FORMAT(P.Submit_Date, 'dd-MMM-yyyy') Submit_Date
        , FORMAT(P.Approve_Date, 'dd-MMM-yyyy') Approve_Date
        , LM.Email
	    FROM SD_UserTaskAssignment U 
        INNER JOIN SD_Performance P ON UPPER(TRIM(U.UserId)) = UPPER(TRIM(P.[User_Id])) AND P.Report_Id = U.ReportId
        INNER JOIN SD_Login_Master LM ON UPPER(TRIM(LM.User_Id)) = UPPER(TRIM(U.UserId))
        INNER JOIN SD_Reports_Master RM ON RM.Rec_ID = U.ReportId
        INNER JOIN SD_Category_Master CM ON CM.Rec_Id = RM.Category_Id
        INNER JOIN SD_Category_Type_Master CTM ON CTM.Rec_Id  = CM.Category_Type_Id
        WHERE 
            (
                (@IsApproved = 1 AND P.Approve_Date IS NOT NULL)
                OR
                (@IsApproved = 0 AND P.Approve_Date IS NULL)
            )
            AND 
            P.Month_From_Date >= IIF(@From_Date IS NULL, P.Month_From_Date, @From_Date) 
            AND 
            P.Month_To_Date <= IIF(@To_Date IS NULL, Month_To_Date, @To_Date)  
        	AND
        	ISNULL(UPPER(TRIM(U.Approver)),'') = IIF(ISNULL(@Approver_Id,'') = '', ISNULL(UPPER(TRIM(U.Approver)),''), @Approver_Id) 
            AND
            P.Submit_Date IS NOT NULL
        	AND
        	UPPER(TRIM(U.UserId)) = IIF(ISNULL(@User_Id,'') = '', UPPER(TRIM(U.UserId)), @User_Id)
            AND 
            UPPER(TRIM(LM.Location_Id)) = IIF(ISNULL(@Location_Id,'')='', UPPER(TRIM(LM.Location_Id)), @Location_Id)
        	AND
        	UPPER(TRIM(RM.[Type])) = IIF(ISNULL(@Type,'') = '', UPPER(TRIM(RM.[Type])), @Type)        
            AND 
            U.ReportId = IIF(@Report_Id = 0, U.ReportId, @Report_Id)
            AND
            LM.Role_Id = IIF(@Role_Id = 0 , LM.Role_Id, @Role_Id)
            AND
            RM.Active = 1
            AND
            LM.Active = 1
            AND
            U.Active = 1
            AND
            P.Active = 1
            AND 
            CTM.Active = 1
            AND
            CM.Active = 1
        ) TBL
        ORDER BY Due_Date, [User_Name], Report_Name, Submit_Date DESC
END
GO
