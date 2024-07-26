-- =============================================
-- Author:      <Rashmi Gupta>
-- Create date: <25-02-2024>
-- Description: <Select tasks for a particular user which are not added>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Unassigned_Tasks_OLD]
    @Approver_Id VARCHAR(50) = NULL
   ,@User_Id VARCHAR(50) = NULL
   ,@Report_Id INT = 0
   ,@Category_Id INT = 0
   ,@Category_Type_Id INT = 0
   ,@LocationId VARCHAR(20) = NULL
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
    SET @User_Id =     UPPER(TRIM(@User_Id));
    SET @LocationId =     UPPER(TRIM(@LocationId));

    BEGIN TRY       

       WITH Users AS
        (
            --Get Approver with subordinates
            SELECT 
            ROW_NUMBER() OVER (PARTITION BY UTA.UserID, UTA.Approver ORDER BY LM.[User_Name]) [Repeat],                
            UTA.UserId,
            UTA.Approver Approver,
            LM.[User_Name] User_Name,
            LocM.Loc_Id,
            UTA.ReportId ReportId, 
            UTA.RecId U_Id
            FROM 
            SD_UserTaskAssignment UTA
            INNER JOIN
            SD_Login_Master LM ON LM.User_Id = UTA.UserId 
            INNER JOIN 
            SD_Location_Master LocM ON UPPER(TRIM(LM.Location_Id)) = UPPER(TRIM(LocM.Loc_Id))        
            WHERE
                ISNULL(UPPER(TRIM(UTA.Approver)),'') = IIF(ISNULL(@Approver_Id,'') = '', ISNULL(UPPER(TRIM(UTA.Approver)),''), @Approver_Id) 
                -- ISNULL(UPPER(TRIM(UTA.Approver)),'') = ISNULL(@Approver_Id,'')
                AND 
                ISNULL(UPPER(TRIM(UTA.UserId)),'') = IIF(ISNULL(@User_Id,'')='', ISNULL(UPPER(TRIM(UTA.UserId)),''), @User_Id)
                AND
                UPPER(TRIM(LocM.Loc_Id)) = IIF(ISNULL(@LocationId,'') = '', UPPER(TRIM(LocM.Loc_Id)), @LocationId)
                AND
                LM.Active = 1
                AND 
                UTA.Active = 1 
                AND 
                UTA.UserId IS NOT NULL
                AND 
                LocM.Active = 1
        )
        , UsrRpt AS
        (
            --Get unique Approver, subordinates combo along with each report
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
            U.Repeat = 1 --get only 1 combo of Approver, subordinate
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
            --Get unique Approver + subordinates + report combo which is not already their in SD_UserTaskAssignment. Thus we get the unassigned tasks for each subordinate.
        SELECT 
        ROW_NUMBER() OVER (ORDER BY U.Approver, U.User_Name, U.Report_Name) Sno, 
        U.Repeat1,
        U.UserId, 
        U.User_Name User_Name,
        U.Approver, 
        U.Report_Name Task_Name, 
        U.REPORT_ID ReportId, 
        U.Category_Id,
        U.Category_Type_Id,
        U.[Loc_Id]
        FROM 
        UsrRpt U
        LEFT JOIN [dbo].[SD_UserTaskAssignment] UTA
        ON 
        ISNULL(UPPER(TRIM(U.UserId)),'') = ISNULL(UPPER(TRIM(UTA.UserId)),'') 
        -- AND  
        -- ISNULL(UPPER(TRIM(U.Approver)),'') = ISNULL(UPPER(TRIM( UTA.Approver)),'') 
        AND 
        U.REPORT_ID = UTA.ReportId 
        AND 
        UTA.Active = 1
        WHERE 
        UTA.RecId IS NULL
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE();
    END CATCH;
END;

GO

