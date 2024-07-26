
CREATE PROCEDURE [dbo].[SP_Add_Update_UsersTasksMonthly] 
  @CrntMnth INT = 0
 ,@DueYr    INT = 0
 ,@UTARecIdList NVARCHAR(MAX) = NULL
AS
/* 
    TRUNCATE TABLE SD_UsersTasksMonthly;
    EXEC SP_Add_Update_UsersTasksMonthly 0, 0, '1112,1113,1114';
    SELECT * FROM SD_UsersTasksMonthly;

    select distinct * froM SD_UsersTasksMonthly u inner join SD_Reports_Master rm on rm.rec_id = u.ReportId
*/
BEGIN
    SET NOCOUNT ON;

    DECLARE @EffectiveIdArray TABLE (ID INT);
    DECLARE @RptTypId INT, @HalfYearlyTaskAddMonth INT, @QuarterlyTaskAddMonth INT , @AnnualTaskAddMonth INT  ;
    DECLARE @DueMnth  INT = @CrntMnth + 2;

    BEGIN TRY

        IF ISNULL(@CrntMnth, 0) < 1  
        BEGIN
            SET @CrntMnth = DATEPART(MONTH, GETDATE());
            SET @DueMnth  = MONTH(DATEADD(MONTH, 2, GETDATE()));
            SET @DueYr    = DATEPART(YEAR, DATEADD(MONTH, 2, GETDATE())); 
        END 

        SELECT @HalfYearlyTaskAddMonth = HalfYearlyTaskAddMonth FROM SD_Calender_Master WHERE HalfYearlyTaskAddMonth = @CrntMnth;

        SELECT @QuarterlyTaskAddMonth = QuarterlyTaskAddMonth FROM SD_Calender_Master WHERE QuarterlyTaskAddMonth = @CrntMnth;

        SELECT @AnnualTaskAddMonth = AnnualTaskAddMonth FROM SD_Calender_Master WHERE AnnualTaskAddMonth = @CrntMnth;

        -- SELECT @CrntMnth, @HalfYearlyTaskAddMonth H, @QuarterlyTaskAddMonth Q, @AnnualTaskAddMonth A;

        IF OBJECT_ID('tempdb..#AUTM') IS NOT NULL
            DROP TABLE #AUTM;

        SELECT *
        INTO #AUTM FROM
        (
            SELECT ROW_NUMBER() OVER (partition by ReportId, UserId order by ReportId, UserId) RN, LM.User_Id UserId, RM.Rec_ID ReportId, RM.Report_Name ReportName, RM.TypeId RptTypId, RM.[Type], RM.Due_Date, UTA.Approver, UTA.RecId UTARecId 
            FROM SD_Reports_Master RM
                INNER JOIN SD_UserTaskAssignment UTA ON RM.Rec_ID = UTA.ReportId
                INNER JOIN SD_Login_Master LM ON LM.User_Id = UTA.UserId
            WHERE ISNULL(TRIM(UTA.UserId),'') != '' AND ISNULL(TRIM(UTA.Approver),'') !='' AND LM.Active = 1 AND RM.Active = 1 AND UTA.Active = 1
        ) TBL WHERE RN = 1;

        -- SELECT * FROM #AUTM;

        IF @UTARecIdList IS NOT NULL        
        BEGIN
            -- Split the string and insert into the table variable
            ;WITH Split AS (
                SELECT [value] ID FROM STRING_SPLIT(@UTARecIdList, ',')
            )
            INSERT INTO @EffectiveIdArray (ID)
            SELECT TRY_CAST(ID AS INT) FROM Split WHERE TRY_CAST(ID AS INT) IS NOT NULL;

            DELETE FROM #AUTM
            WHERE UTARecId NOT IN (
                SELECT ID FROM @EffectiveIdArray
            );
        END
        
        -- SELECT * FROM #AUTM;
    
        BEGIN TRANSACTION;

        MERGE INTO SD_UsersTasksMonthly AS Dest
        USING #AUTM AS Src
            ON Src.ReportId = Dest.ReportId AND Src.USERID = Dest.USERID AND Dest.[MONTH] = @CrntMnth 
            --if given report & userID already exists in crnt mnth, update the row OTHERWISE INSERT IT
        WHEN MATCHED THEN
           UPDATE SET
                DueDate = [DBO].[GetDueDate](Src.Due_Date, Src.RptTypId, @DueMnth, @DueYr)
               ,ReportName = SRC.ReportName
               ,ReportTypeId = SRC.RptTypId
               ,Modified_By = 'JOB'
               ,Modified_Date = GETDATE()
        WHEN NOT MATCHED 
            AND
            (
               Src.RptTypId < 3 
               OR 
               (Src.RptTypId = 3 AND ISNULL(@QuarterlyTaskAddMonth, 0) > 0)  --crnt mnth is Quarterly reports' add month
               OR
               (Src.RptTypId = 4 AND ISNULL(@HalfYearlyTaskAddMonth, 0) > 0)  --crnt mnth is Half yearly reports' add month
               OR
               (Src.RptTypId = 5 AND ISNULL(@AnnualTaskAddMonth, 0) > 0)  --crnt mnth is Half yearly reports' add month
            )  
        THEN        
            INSERT (UserId, ReportId, ReportName, ReportTypeId, [Month], Created_By, DueDate)
            -- OUTPUT inserted.RecId
            VALUES
            ( 
                Src.UserId, Src.ReportId, SRC.ReportName, Src.RptTypId, @CrntMnth, 'JOB', [DBO].[GetDueDate](Src.Due_Date, Src.RptTypId, @DueMnth, @DueYr)
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

