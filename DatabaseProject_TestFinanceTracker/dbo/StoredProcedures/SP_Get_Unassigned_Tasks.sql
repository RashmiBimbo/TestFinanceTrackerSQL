-- =============================================
-- Author:      <Rashmi Gupta>
-- Create date: <25-02-2024>
-- Description: <Select tasks for a particular user which are not added>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Unassigned_Tasks]
     @Approver_Id VARCHAR(50) = NULL
   , @User_Id VARCHAR(50) = NULL
   , @Report_Id INT = 0
   , @Category_Id INT = 0
   , @Category_Type_Id INT = 0
   , @LocationId VARCHAR(20) = NULL
   , @RoleId INT = 0
   , @Assigner VARCHAR(50) = NULL
AS
BEGIN
    /*
        SP_Get_Unassigned_Tasks 'CORPORATE1', '', 0, 0, 0, 'corp'
        SP_Get_Unassigned_Tasks 'ashish', '', 0, 0, 0, 'CORP', 0, ''
        SP_Get_Unassigned_Tasks 'ashish', '', 0, 0, 0, NULL, 0
        SP_Get_Unassigned_Tasks 'ABHA', 'ANKIT', 00, 17, 16
        SP_Get_Unassigned_Tasks '', null, 0, 0, 0, 'KOC'
    */
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    BEGIN TRY
        SET @Approver_Id = UPPER(TRIM(@Approver_Id));
        SET @User_Id     = UPPER(TRIM(@User_Id));
        SET @LocationId  = UPPER(TRIM(@LocationId));
        SET @Assigner    = UPPER(TRIM(@Assigner));

        DECLARE @IsApprAdmin BIT, @IsAdmin BIT, @IsApprover BIT, @IsSuperAdmin BIT; 

        
        IF EXISTS (SELECT * FROM SD_Login_Master WHERE (ISNULL(@Assigner,'')) != '' AND UPPER(TRIM(User_Id)) = @Assigner AND Active = 1 AND Role_Id = 4)
        BEGIN
            SET @IsSuperAdmin = 1;
            --SELECT 'SuperAdmin';
        END
        ELSE
        -- Decide whether the given user is admin or approver or both
        IF EXISTS(SELECT * FROM SD_Login_Master WHERE UPPER(TRIM(Location_Id)) = @LocationId AND Active = 1 AND (ISNULL(@Approver_Id,'') = '' OR UPPER(TRIM(User_Id)) = @Approver_Id AND Role_Id = 1 ))
        BEGIN    
            IF EXISTS( SELECT * FROM SD_UserTaskAssignment WHERE UPPER(TRIM(Approver)) = @Approver_Id AND Active = 1)
            BEGIN
               SET @IsApprAdmin = 1;
            --    SELECT 'ApprAdmin';
            END
            ELSE
            BEGIN
               SET @IsAdmin = 1;
            --    SELECT 'Admin';
            END
        END
        ELSE 
            IF EXISTS( SELECT * FROM SD_UserTaskAssignment WHERE UPPER(TRIM(Approver)) = @Approver_Id AND Active = 1)
            BEGIN
               SET @IsApprover = 1;
            --    SELECT 'Appr';
            END
            ELSE
                BEGIN
                    Select 'Please enter either a valid location or a user which is either SuperAdmin or admin or approver!' Error;
                    RETURN;
                END        

        IF OBJECT_ID('TEMPDB..#TBL') IS NOT NULL
        BEGIN
            DROP TABLE #TBL;
        END 

        --SELECT THE USER+REPORT COMBO WHICH IS ACTIVE AND HAS APPROVER. LATER WE WILL EXCLUDE THESE RECORDS FROM SUPERSET OF USER+REPORT COMBO. THUS WE GET THE USER+REPORT COMBO WHICH DOES NOT HAVE ANY APPROVER OR INACTIVE OR DOES NOT EXIST IN USERTASKASSIGNMENT.
        SELECT * INTO #TBL FROM
        (
            SELECT ROW_NUMBER() OVER (PARTITION BY UserID, REPORTID ORDER BY [Approver]) [Repeat], * FROM SD_UserTaskAssignment UTA
            WHERE (UTA.Active = 1 and ISNULL(TRIM(UTA.Approver),'') != '')
        ) TBL
        WHERE [Repeat] = 1;

        -- SELECT * FROM #TBL;

        WITH
        Users
        AS
        (
            -- Get unique subordinates of given location/approver. 
            -- For given @LocationId subordinates are selected from login_master,  
            -- if @LocationId is not given but @approverId is, subordinates whose approver is @approverId are selected from usertaskassignment. 
            -- If both are given, subordinates whose approver is @approverId are selected from usertaskassignment + subordinates whose location is @LocationId are selected from login_master   
            SELECT
            ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY [User_Name]) [Repeat], TBL.*
            -- , LM.User_Id ApproverId
            FROM 
            (
                SELECT DISTINCT 
                LM.User_Id UserId                
                ,UTA.Approver Approver
                ,LM.[User_Name] User_Name
                ,uta.ReportName
                ,LocM.Loc_Id
                ,UTA.ReportId
                ,UTA.RecId U_Id
                ,LM.Role_Id
                FROM
                    SD_Login_Master LM
                    LEFT JOIN
                    SD_Location_Master LocM ON UPPER(TRIM(LM.Location_Id)) = UPPER(TRIM(LocM.Loc_Id))
                    LEFT JOIN
                    SD_UserTaskAssignment UTA ON UPPER(TRIM(LM.User_Id)) = UPPER(TRIM(UTA.UserId)) AND UTA.Active = 1
                WHERE
                    LM.Active = 1
                    AND
                   (LocM.Active IS NOT NULL OR LocM.Active = 1)
                    AND
                   (UTA.Active IS NOT NULL OR UTA.Active = 1)
                    AND
                    UPPER(TRIM(LM.User_Id)) = IIF(ISNULL(@User_Id,'')='', UPPER(TRIM(LM.User_Id)), @User_Id)
                    AND
                    (
                        (@IsSuperAdmin = 1)
                        OR
                        (@IsApprAdmin = 1 AND ((UTA.APPROVER IS NULL AND UPPER(TRIM(LocM.Loc_Id)) = @LocationId) OR UPPER(TRIM(UTA.Approver)) = @Approver_Id))
                        OR 
                        (@IsAdmin = 1 AND (UTA.APPROVER IS NULL AND UPPER(TRIM(LocM.Loc_Id)) = @LocationId))
                        OR
                        (@IsApprover = 1 AND UPPER(TRIM(UTA.Approver)) = @Approver_Id)
                    )
                    AND
                    LM.Role_Id = IIF(@RoleId = 0, LM.Role_Id, @RoleId)
            ) TBL
            -- CROSS JOIN SD_Login_Master LM 
            -- WHERE LM.Active = 1 AND UPPER(TRIM(USER_ID))= DBO.CHECKSTR(@Approver_Id, User_Id)
        ) 
        --get only unique subordinate
        -- SELECT * FROM Users U 
        -- WHERE U.Repeat = 1
        ,UsrRpt
        AS
        (
            --Get subordinates along with each report and create a superset/cartesian product of subordinates*reports
            SELECT DISTINCT
                ROW_NUMBER() OVER (PARTITION BY U.UserID, RM.Report_Name ORDER BY U.[User_Name]) [Repeat1],
                RM.Report_Name,
                U.UserId,
                U.Approver,
                U.[User_Name],
                U.[Loc_Id],
                RM.Active RM_Active,
                RM.Rec_ID REPORT_ID,
                CM.Rec_Id Category_Id,
                CTM.Rec_Id Category_Type_Id
               ,U.Role_Id 
            FROM Users U
            CROSS JOIN 
            SD_Reports_Master RM
            INNER JOIN SD_Category_Master CM ON CM.Rec_Id = RM.Category_Id
            INNER JOIN SD_Category_Type_Master CTM ON CTM.Rec_Id = CM.Category_Type_Id
            WHERE
                U.Repeat = 1 --get only unique subordinate
                AND
                RM.Rec_ID = IIF(@Report_Id = 0, RM.Rec_ID, @Report_Id)
                AND
                RM.Category_Id = IIF(@Category_Id = 0, RM.Category_Id, @Category_Id)
                AND
                CM.Category_Type_Id = IIF(@Category_Type_Id = 0, CM.Category_Type_Id, @Category_Type_Id)
                AND
                RM.Active = 1
                AND
                CM.Active = 1
                AND
                CTM.Active = 1
        )
        -- SELECT * FROM UsrRpt

        /* Get unique SUBORDINATES+REPORT COMBO WHICH IS NOT ACTIVE OR DOES NOT HAVE APPROVER OR DOES NOT EXIST IN UTA. Thus we get the combo WHICH IS EITHER NOT ACTIVE OR DOES NOT HAVE APPROVER OR NOT PRESENT IN USERTASKASSIGNMENT .*/
        SELECT 
        ROW_NUMBER() OVER (ORDER BY User_Name, Task_Name) Sno, * 
        FROM 
        (
            SELECT 
                ROW_NUMBER() OVER (PARTITION BY U.UserID, U.REPORT_ID ORDER BY UTA.[Approver]) [Repeat],
                UTA.RecId UTRecId,
                U.User_Name User_Name ,
                U.UserId UserId,
                U.Report_Name Task_Name,
                UTA.ReportName UTReport_Name,
                U.Approver Approver,
                UTA.Approver UTA_Approver,
                U.REPORT_ID ReportId,
                UTA.REPORTID UTA_ReportId,
                U.Category_Id,
                U.Category_Type_Id,
                U.[Loc_Id],
                U.Repeat1
                ,U.Role_Id
            FROM
            UsrRpt U
            LEFT JOIN #TBL UTA
            ON 
                UPPER(TRIM(U.UserId)) = UPPER(TRIM(UTA.UserId))
                AND
                U.REPORT_ID = UTA.ReportId
            WHERE 
                UTA.RecId IS NULL
        ) SQ
        WHERE SQ.Repeat = 1;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() Error;
    END CATCH;
END;
GO

