-- =============================================
-- Author:      <Rashmi Gupta>
-- Create date: <25-02-2024>
-- Description: <Select tasks for a particular user which are not added>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Assigned_Tasks]
    @Approver_Id VARCHAR(50) = NULL
   ,@User_Id VARCHAR(50) = NULL
   ,@Report_Id INT = 0
   ,@Category_Id int = 0
   ,@Category_Type_Id int = 0
   ,@LocationId VARCHAR(20) = NULL
AS
BEGIN
    /*
        SP_Get_Assigned_Tasks '', '2024-01-01', '2024-01-31', 0,'W'
        SP_Get_Assigned_Tasks 'ashish', '2024-02-01', '2024-02-29', 0,'W'
    */
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @Approver_Id = ISNULL(UPPER(TRIM(@Approver_Id)), '');
    SET @User_Id =     UPPER(TRIM(@User_Id));
    SET @LocationId =     UPPER(TRIM(@LocationId));

    BEGIN TRY    
        SELECT 
             ROW_NUMBER() OVER (ORDER BY User_Name, [Task_Name]) AS Sno,  *
             FROM (
                    SELECT DISTINCT
                     TRIM(UTA.ReportName) AS Task_Name
                    ,LM.[User_Name] 
                    ,UPPER(TRIM(UTA.UserId)) AS UserId
                    ,UTA.ReportId
                    ,UTA.Approver
                    ,UTA.RecId
                    ,LocM.Loc_Id
                    FROM 
                        [dbo].[SD_UserTaskAssignment] UTA
                    INNER JOIN 
                        SD_Login_Master LM ON LM.User_Id = UTA.UserId
                    INNER JOIN 
                        SD_Location_Master LocM ON UPPER(TRIM(LM.Location_Id)) = UPPER(TRIM(LocM.Loc_Id)) 
                    INNER JOIN 
                        SD_Reports_Master RM ON RM.Rec_ID = UTA.ReportId
                    INNER JOIN 
                        SD_Category_Master CM ON CM.Rec_Id = RM.Category_Id
                    INNER JOIN 
                        SD_Category_Type_Master CTM ON CTM.Rec_Id = CM.Category_Type_Id 
                    WHERE 
                    RM.[Rec_Id] = IIF(@Report_Id = 0, RM.[Rec_Id], @Report_Id) 
                    AND 
                    CM.[Rec_Id] = IIF(@Category_Id = 0, CM.[Rec_Id], @Category_Id) 
                    AND 
                    CTM.[Rec_Id] = IIF(@Category_Type_Id = 0, CTM.[Rec_Id], @Category_Type_Id) 
                    AND 
                    UPPER(TRIM(UTA.Approver)) = IIF(ISNULL(@Approver_Id, '') = '', UPPER(TRIM(UTA.Approver)), @Approver_Id) 
                    -- ISNULL(UPPER(TRIM(UTA.Approver)),'') = @Approver_Id 
                    AND 
                    UPPER(TRIM(UTA.UserId)) = IIF(ISNULL(@User_Id,'') = '', UPPER(TRIM(UTA.UserId)), @User_Id)
                    AND
                    UPPER(TRIM(LocM.Loc_Id)) = IIF(ISNULL(@LocationId,'') = '', UPPER(TRIM(LocM.Loc_Id)), @LocationId)
                    AND
                    UTA.Active = 1
                    AND 
                    LM.Active = 1
                    AND 
                    RM.Active = 1 
                    AND
                    CM.Active = 1 
                    AND
                    CTM.Active = 1 
                    AND
                    LocM.Active = 1
             ) TBL         
            ORDER BY 
                [User_Name], [Task_Name], [UserId] ASC
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE();
    END CATCH;
END;

GO

