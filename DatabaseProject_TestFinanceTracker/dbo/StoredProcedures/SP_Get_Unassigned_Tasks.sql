-- =============================================
-- Author:      <Rashmi Gupta>
-- Create date: <25-02-2024>
-- Description: <Select tasks for a particular user which are not added>
-- =============================================
ALTER PROCEDURE [dbo].[SP_Get_Unassigned_Tasks]
     @Approver_Id VARCHAR(50) = NULL
   , @User_Id VARCHAR(50) = NULL
   , @Report_Id INT = 0
   , @Category_Id INT = 0
   , @Category_Type_Id INT = 0
   , @LocationId VARCHAR(20) = NULL
AS
BEGIN
    /*
        SP_Get_Unassigned_Tasks '', '2024-01-01', '2024-01-31', 0,'W'
        SP_Get_Unassigned_Tasks 'ashish', 'BLR', 168
        SP_Get_Unassigned_Tasks '', 'ANKIT', 00, 17, 16
        SP_Get_Unassigned_Tasks '', null, 0, 0, 0, 'KOC'
    */
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @Approver_Id = UPPER(TRIM(@Approver_Id));
    SET @User_Id     = UPPER(TRIM(@User_Id));
    SET @LocationId  = UPPER(TRIM(@LocationId));

    DECLARE @IsApprAdmin BIT = IIF(@Approver_Id IS NOT NULL AND @LocationId IS NOT NULL, 1, 0)
    DECLARE @IsAdmin     BIT = IIF(@Approver_Id IS NULL     AND @LocationId IS NOT NULL, 1, 0)
    DECLARE @IsApprover  BIT = IIF(@Approver_Id IS NOT NULL AND @LocationId IS     NULL, 1, 0)

    BEGIN TRY       
       WITH
        Users
        AS
        (
            --Get Approver with subordinates
            SELECT
            ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY [User_Name]) [Repeat], *
            FROM 
            (
                SELECT DISTINCT LM.User_Id UserId
                ,UTA.Approver Approver
                ,LM.[User_Name] User_Name
                ,LocM.Loc_Id
                ,UTA.ReportId ReportId
                ,UTA.RecId U_Id
                FROM
                    SD_Login_Master LM
                    LEFT JOIN
                    SD_UserTaskAssignment UTA ON UPPER(TRIM(LM.User_Id)) = UPPER(TRIM(UTA.UserId)) AND UTA.Active = 1
                    INNER JOIN
                    SD_Location_Master LocM ON UPPER(TRIM(LM.Location_Id)) = UPPER(TRIM(LocM.Loc_Id))
                WHERE
                    ISNULL(UPPER(TRIM(LM.User_Id)),'') = IIF(ISNULL(@User_Id,'')='', ISNULL(UPPER(TRIM(LM.User_Id)),''), @User_Id)
                    AND
                    LM.Active = 1
                    AND
                    LocM.Active = 1
                    -- AND
                    -- (
                    --     (@IsApprAdmin = 1 AND ((UTA.APPROVER IS NULL AND UPPER(TRIM(LocM.Loc_Id)) = @LocationId) OR UPPER(TRIM(UTA.Approver)) = @Approver_Id))
                    --     OR 
                    --     (@IsAdmin = 1 AND (UTA.APPROVER IS NULL AND UPPER(TRIM(LocM.Loc_Id)) = @LocationId))
                    --     OR
                    --     (@IsApprover = 1 AND UPPER(TRIM(UTA.Approver)) = @Approver_Id)
                    -- )
                    --If @ISAPAD UTA.APPROVER IS NULL OR = @APP ELSE IF @ISAD UTA.APP IS NULL ELSE IF @ISAP UTA.APP= @ISAP 
                    -- ISNULL(UPPER(TRIM(UTA.Approver)),'') = IIF(ISNULL(@Approver_Id,'') = '', ISNULL(UPPER(TRIM(UTA.Approver)),''), @Approver_Id)
                    -- ISNULL(UPPER(TRIM(UTA.Approver)),'') = ISNULL(@Approver_Id,'')
                    -- AND --EITHER THE APPROVER SHOULD BE THE APPROVER IN UTA OR IF @Approver_Id IS NULL I.E. IT IS ADMIN, THEN IT CAN ADD USERS WHICH ARE NOT IN  UTA 
                    -- (@Approver_Id IS NULL OR (@Approver_Id IS NOT NULL AND UTA.RecId IS NOT NULL))
                    -- OR
                    -- UPPER(TRIM(LocM.Loc_Id)) = IIF(ISNULL(@LocationId,'') = '', UPPER(TRIM(LocM.Loc_Id)), @LocationId)
                    -- AND
                    -- END CASE
                    -- IIF(@IsApprAdmin = 1, ((UTA.APPROVER IS NULL AND UPPER(TRIM(LocM.Loc_Id)) = @LocationId) OR UPPER(TRIM(UTA.Approver)) = @Approver_Id),
                    --     IIF(@IsAdmin = 1, (UTA.APPROVER IS NULL AND UPPER(TRIM(LocM.Loc_Id)) = @LocationId),
                    --         IIF(@IsApprover = 1, UPPER(TRIM(UTA.Approver)) = @Approver_Id, 0)
                    --         )
                    --     ) = 1 -- Adjust the conditions as per your requirements
                ) TBL
        )
        ,UsrRpt
        AS
        (
            --Get subordinate along with each report
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

    --Get unique subordinates + report combo whose approver is not already their in SD_UserTaskAssignment. Thus we get the unassigned tasks for each subordinate.
    SELECT
        ROW_NUMBER() OVER (ORDER BY U.User_Name, U.Report_Name) Sno,
        U.Repeat1,
        U.User_Name,
        U.UserId,
        U.Report_Name Task_Name,
        U.Approver UApprover,
        UTA.Approver UTAApprover,
        U.REPORT_ID ReportId,
        U.Category_Id,
        U.Category_Type_Id,
        U.[Loc_Id]
    FROM
        UsrRpt U
        LEFT JOIN [dbo].[SD_UserTaskAssignment] UTA
        ON 
            UPPER(TRIM(U.UserId)) = UPPER(TRIM(UTA.UserId))
            AND
            U.REPORT_ID = UTA.ReportId
            AND
            UTA.Active = 1
    WHERE 
        ISNULL(UPPER(TRIM(UTA.Approver)),'') = ''
        -- AND  
        -- UTA.RecId IS NULL
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE();
    END CATCH;
END;

GO

