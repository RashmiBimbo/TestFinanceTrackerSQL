
CREATE PROCEDURE [dbo].[SP_Add_Update_UsersTasksMonthly] 
AS
/* 
    TRUNCATE TABLE SD_UsersTasksMonthly;
    EXEC SP_Add_Update_UsersTasksMonthly;
    SELECT * FROM SD_UsersTasksMonthly;

    select distinct * froM SD_UsersTasksMonthly u inner join SD_Reports_Master rm on rm.rec_id = u.ReportId
*/
BEGIN

    SET NOCOUNT ON;

    DECLARE @RptTypId INT ;
    DECLARE @CrntMnth INT = DATEPART(MONTH, GETDATE());
    DECLARE @DueMnth  INT = MONTH(DATEADD(MONTH, 2, GETDATE()));
    DECLARE @DueYr    INT = DATEPART(YEAR, DATEADD(MONTH, 2, GETDATE())); 

    DECLARE @HalfYearlyTaskAddMonth INT ;
    SELECT @HalfYearlyTaskAddMonth = HalfYearlyTaskAddMonth FROM SD_Calender_Master WHERE HalfYearlyTaskAddMonth = @CrntMnth;

    DECLARE @QuarterlyTaskAddMonth INT ;
    SELECT @QuarterlyTaskAddMonth = QuarterlyTaskAddMonth FROM SD_Calender_Master WHERE QuarterlyTaskAddMonth = @CrntMnth;
    
    IF OBJECT_ID('tempdb..#AUTM') IS NOT NULL
        DROP TABLE #AUTM;

    SELECT *
    INTO #AUTM FROM
    (
        SELECT ROW_NUMBER() OVER (partition by ReportId, UserId order by ReportId, UserId) RN, RM.Rec_ID ReportId, LM.User_Id UserId, RM.TypeId RptTypId, RM.[Type], RM.Due_Date, UTA.Approver
        FROM SD_Reports_Master RM
            INNER JOIN SD_UserTaskAssignment UTA ON RM.Rec_ID = UTA.ReportId
            INNER JOIN SD_Login_Master LM ON LM.User_Id = UTA.UserId
        WHERE ISNULL(TRIM(UTA.UserId),'') != '' AND ISNULL(TRIM(UTA.Approver),'') !='' AND LM.Active = 1 AND RM.Active = 1 AND UTA.Active = 1
    ) TBL WHERE RN = 1;

    -- SELECT COUNT(*) FROM #AUTM;
    
    BEGIN TRY

        BEGIN TRANSACTION;

        MERGE INTO SD_UsersTasksMonthly AS Dest
        USING #AUTM AS Src
            ON Src.ReportId = Dest.ReportId AND Src.USERID = Dest.USERID AND Dest.[MONTH] = @CrntMnth 
            --if given report & userID already exists in crnt mnth, update the row OTHERWISE INSERT IT
        WHEN MATCHED THEN
           UPDATE SET
                DueDate = [DBO].[GetDueDate](Src.Due_Date, Src.RptTypId, @DueMnth, @DueYr)
               ,Modified_By = 'JOB'
               ,Modified_Date = GETDATE()
        WHEN NOT MATCHED 
            AND
            (
               Src.RptTypId < 3 
               OR 
               (Src.RptTypId = 3 AND ISNULL(@QuarterlyTaskAddMonth, 0) != 0)  --crnt mnth is Quarterly reports' add month
               OR
               (Src.RptTypId = 4 AND ISNULL(@HalfYearlyTaskAddMonth, 0) != 0)  --crnt mnth is Half yearly reports' add month
            )  
        THEN        
            INSERT (UserId, ReportId, [Month], ReportTypeId, Created_By, DueDate)
            -- OUTPUT inserted.RecId
            VALUES
            ( 
                Src.UserId, Src.ReportId, @CrntMnth, Src.RptTypId, 'JOB', [DBO].[GetDueDate](Src.Due_Date, Src.RptTypId, @DueMnth, @DueYr)
            )
        -- OUTPUT $action, inserted.*,  deleted.*
        ;
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_MESSAGE() AS ErrorMessage  -- The error message
        --     ,ERROR_NUMBER() AS ErrorNumber     -- The error number
        --     ,ERROR_SEVERITY() AS ErrorSeverity -- The error severity
        --     ,ERROR_STATE() AS ErrorState       -- The error state
        --     ,ERROR_PROCEDURE() AS ErrorProcedure -- The name of the stored procedure or trigger where the error occurred
        --     ,ERROR_LINE() AS ErrorLine         -- The line number where the error occurred
        ;
    END CATCH
END
GO

