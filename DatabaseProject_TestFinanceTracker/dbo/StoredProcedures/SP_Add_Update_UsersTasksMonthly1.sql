
create PROCEDURE [dbo].[SP_Add_Update_UsersTasksMonthly1]
AS
-- TRUNCATE table SD_UsersTasksMonthly
BEGIN
    SET NOCOUNT ON;
    DECLARE @TypeExists BIT;
    DECLARE @CrntMnth AS INT = DATEPART(MONTH, GETDATE());
    DECLARE @CrntYr AS INT = DATEPART(YEAR, GETDATE());

    DECLARE @FebLstDay INT = IIF((YEAR(GETDATE()) % 4 = 0) AND (YEAR(GETDATE()) % 100 != 0) OR (YEAR(GETDATE()) % 400 = 0), 29, 28);
    DECLARE @DateFormat VARCHAR(10) = 'dd-MMM-yyyy';

    DECLARE @RptTypId INT;
    DECLARE RptTypCrsr CURSOR FOR
    SELECT RecId FROM SD_ReportType_Master;

    IF OBJECT_ID('tempdb..#AUTM') IS NOT NULL
        DROP TABLE #AUTM;

    SELECT *
    INTO #AUTM FROM
    (
        SELECT ROW_NUMBER() OVER( partition by ReportId, UserId order by ReportId, UserId) RN, RM.Rec_ID ReportId, LM.User_Id UserId, RM.TypeId RptTypId, RM.Due_Date, UTA.Approver
        FROM SD_Reports_Master RM
            INNER JOIN SD_UserTaskAssignment UTA ON RM.Rec_ID = UTA.ReportId
            INNER JOIN SD_Login_Master LM ON LM.User_Id = UTA.UserId
        WHERE ISNULL(TRIM(UTA.UserId),'') != '' AND ISNULL(TRIM(UTA.Approver),'') !='' AND LM.Active = 1 AND RM.Active = 1 AND UTA.Active = 1
    ) TBL WHERE RN = 1;

    --  SELECT * FROM #AUTM

    OPEN RptTypCrsr;
    FETCH NEXT FROM RptTypCrsr INTO @RptTypId;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @RptTypId;

        SELECT @TypeExists = COALESCE(MAX(1), 0) FROM #AUTM WHERE @RptTypId = RptTypId

        IF @TypeExists = 1
        print 'tyepexists'
        BEGIN
            IF @RptTypId = 1	--Weekly 
            BEGIN            
                PRINT 'Reached weekly'

                MERGE INTO SD_UsersTasksMonthly AS Dest
                USING #AUTM AS Src
                    ON Src.USERID = Dest.USERID AND Src.ReportId = Dest.ReportId AND Src.RptTypId = @RptTypId AND Dest.[MONTH] = @CrntMnth
                WHEN MATCHED THEN
                    UPDATE SET
                        DueDate = IIF
                        (
                            ISNULL(TRIM(Due_Date),'') = '', 
                            '',
                            'Every ' + LEFT(UPPER(TRIM(Due_Date)), 1) + SUBSTRING(LOWER(TRIM(Due_Date)), 2, LEN(TRIM(Due_Date)) - 1)
                        )
                        ,Modified_By = 'JOB'
                        ,Modified_Date = GETDATE()
                WHEN NOT MATCHED AND Src.RptTypId = @RptTypId THEN
                    INSERT (UserId, ReportId, DueDate, Created_By, [Month], ReportTypeId)
                    -- OUTPUT inserted.RecId
                    VALUES( 
                        Src.UserId, Src.ReportId
                        ,IIF
                        (
                            ISNULL(TRIM(Src.Due_Date),'') = '', 
                            '',
                            'Every ' + LEFT(UPPER(TRIM(Src.Due_Date)), 1) + SUBSTRING(LOWER(TRIM(Src.Due_Date)), 2, LEN(TRIM(Src.Due_Date)) - 1)
                        )
                        ,'JOB', @CrntMnth, SRC.RptTypId
                    )
                    -- OUTPUT $action, inserted.*,  deleted.*
                    ;
                PRint 'saved weekly'
            END
            ELSE
            IF @RptTypId = 2	--Monthly
            BEGIN            
                PRINT 'Reached Monthly'

                MERGE INTO SD_UsersTasksMonthly AS Dest
                USING #AUTM AS Src
                    ON Src.USERID = Dest.USERID AND Src.ReportId = Dest.ReportId AND Src.RptTypId = @RptTypId AND Dest.[MONTH] = @CrntMnth
                WHEN MATCHED THEN
                    UPDATE SET                                        
                        Modified_By = 'JOB'
                        ,Modified_Date = GETDATE()
                        ,DueDate = 
                        CASE
                            WHEN ISNUMERIC(Src.Due_Date) = 1 THEN
                            CASE
                                WHEN Src.Due_Date > 28 THEN
                                    CASE WHEN MONTH(@CrntMnth) = 2 THEN --when mnth is FEB and Due date is more than 28
                                    FORMAT
                                    (   -- dd-MMM-yyyy format e.g. 10-Jan-2024
                                       DATEADD(MONTH, 1, DATEFROMPARTS(@CrntYr, @CrntMnth, @FebLstDay)), @DateFormat
                                    ) -- Non-leap year February
                                    ELSE
                                    CASE -- when given Due date is 31 but mnth has only 30 days
                                    WHEN ISDATE(CONVERT(varchar, DATEFROMPARTS(@CrntYr, @CrntMnth, Src.Due_Date))) = 0 THEN 
                                        FORMAT
                                        (  
                                           DATEADD(MONTH, 1, DATEFROMPARTS(@CrntYr, @CrntMnth, 30)), @DateFormat
                                        )
                                    ELSE
                                        FORMAT
                                        (   
                                           DATEADD(MONTH, 1, DATEFROMPARTS(@CrntYr, @CrntMnth, Src.Due_Date)), @DateFormat
                                        )
                                    END
                                    END
                                ELSE
                                    FORMAT
                                    (  
                                        DATEADD(MONTH, 1, DATEFROMPARTS(@CrntYr, @CrntMnth, Src.Due_Date)), @DateFormat
                                    )
                            END
                        END
                WHEN NOT MATCHED AND Src.RptTypId = @RptTypId THEN
                    INSERT (UserId, ReportId, DueDate, Created_By, [Month], ReportTypeId)
                    -- OUTPUT inserted.RecId
                    VALUES
                    ( 
                        Src.UserId, Src.ReportId,
                        CASE
                            WHEN ISNUMERIC(Src.Due_Date) = 1 THEN
                            CASE
                                WHEN Src.Due_Date > 28 THEN
                                CASE WHEN MONTH(@CrntMnth) = 2 THEN --when mnth is FEB and Due date is more than 28
                                    FORMAT
                                    (   -- dd-MMM-yyyy format e.g. 10-Jan-2024
                                       DATEADD(MONTH, 1, DATEFROMPARTS(@CrntYr, @CrntMnth, @FebLstDay)), @DateFormat
                                    ) -- Non-leap year February
                                    ELSE
                                    CASE -- when given Due date is 31 but mnth has only 30 days
                                    WHEN ISDATE(CONVERT(varchar, DATEFROMPARTS(@CrntYr, @CrntMnth, Src.Due_Date))) = 0 THEN 
                                        FORMAT
                                        (  
                                           DATEADD(MONTH, 1, DATEFROMPARTS(@CrntYr, @CrntMnth, 30)), @DateFormat
                                        )
                                    ELSE
                                        FORMAT
                                        (   
                                           DATEADD(MONTH, 1, DATEFROMPARTS(@CrntYr, @CrntMnth, Src.Due_Date)), @DateFormat
                                        )
                                    END
                                END
                            ELSE
                                FORMAT
                                (  
                                    DATEADD(MONTH, 1, DATEFROMPARTS(@CrntYr, @CrntMnth, Src.Due_Date)), @DateFormat
                                )
                            END
                        END
                    ,'JOB', @CrntMnth, SRC.RptTypId
                    )
                    -- OUTPUT $action, inserted.*,  deleted.*
                    ;
                PRint 'saved Monthly'
            END
            ELSE
            IF @RptTypId = 4	--HalfYearly
            BEGIN   
                MERGE INTO SD_UsersTasksMonthly AS Dest
                USING #AUTM AS Src
                    ON Src.USERID = Dest.USERID AND Src.ReportId = Dest.ReportId AND Src.RptTypId = @RptTypId AND Dest.[MONTH] = @CrntMnth
                WHEN MATCHED THEN
                    UPDATE SET
                        DueDate =
                            CASE
                            WHEN Src.Due_Date = '41' THEN '01-Jan-'+ CAST(@CrntYr AS VARCHAR(4))  --Report for First Half
                            WHEN Src.Due_Date = '42' THEN '01-Jul-'+ CAST(@CrntYr AS VARCHAR(4))  --Report for 2nd Half
                            END
                        ,Modified_By = 'JOB'
                        ,Modified_Date = GETDATE()
                WHEN NOT MATCHED AND Src.RptTypId = @RptTypId THEN
                    INSERT (UserId, ReportId, DueDate, Created_By, [Month], ReportTypeId)
                    -- OUTPUT inserted.RecId
                    VALUES( 
                        Src.UserId, Src.ReportId
                        ,CASE
                        WHEN Src.Due_Date = '41' THEN '01-Jan-'+ CAST(@CrntYr AS VARCHAR(4))  --Report for First Half
                        WHEN Src.Due_Date = '42' THEN '01-Jul-'+ CAST(@CrntYr AS VARCHAR(4))  --Report for 2nd Half
                        END
                        ,'JOB', @CrntMnth, SRC.RptTypId
                    )
                    -- OUTPUT $action, inserted.*,  deleted.*
                    ;
                    PRINT 'Saved Half Yearly'
            END

            UPDATE SD_UsersTasksMonthly
            SET DueDate = ''
            WHERE DueDate IS NULL
        END

        FETCH NEXT FROM RptTypCrsr INTO @RptTypId;       
        PRINT @RptTypId;

        PRINT @@FETCH_STATUS;
    END;

    CLOSE RptTypCrsr;
    DEALLOCATE RptTypCrsr;

    -- select DueDate,ReportTypeId,UserId,ReportId from SD_UsersTasksMonthly
    -- INTERSECT
    -- select Due_Date,RptTypId,UserId, ReportId from #AUTM
    --TRUNCATE TABLE SD_UsersTasksMonthly
    --SELECT * FROM SD_UsersTasksMonthly
    --SELECT * FROM SD_UserTaskAssignment
END
GO

