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
   ,@RoleId INT = 0
   ,@Assigner VARCHAR(50) = NULL
AS
BEGIN
    /*
        SP_Get_Assigned_Tasks 'NIDHI','NITIN', 138
        SP_Get_Assigned_Tasks 'ADMIN1', null, 0, 0, 0, NULL, 0, 'SUPERADMIN1'
        SP_Get_Assigned_Tasks '', '2024-01-01', '2024-01-31', 0,'WEEKLY'
        SP_Get_Assigned_Tasks 'ashish', '2024-02-01', '2024-02-29', 0,'WEEKLY'
    */
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @Approver_Id = ISNULL(UPPER(TRIM(@Approver_Id)), '');
    SET @User_Id     = UPPER(TRIM(@User_Id));
    SET @LocationId  = UPPER(TRIM(@LocationId));
    SET @Assigner    = UPPER(TRIM(@Assigner));

    DECLARE @IsAdmin BIT = 0, @IsSuperAdmin BIT = 0; 
    
    IF EXISTS (SELECT * FROM SD_Login_Master WHERE (ISNULL(@Assigner,'')) != '' AND UPPER(TRIM(User_Id)) = @Assigner AND Active = 1 AND Role_Id = 4)
    BEGIN
        SET @IsSuperAdmin = 1;
        --SELECT 'SuperAdmin';
    END
    ELSE IF EXISTS ( SELECT * FROM SD_Login_Master WHERE Active = 1 AND UPPER(TRIM(User_Id)) = @Approver_Id AND Role_Id = 1 )  
        BEGIN
           SET @IsAdmin = 1;
           IF(ISNULL(@LocationId, '') = '')
               SELECT @LocationId = Location_Id FROM SD_Login_Master WHERE User_Id = @Approver_Id ;
        END

    BEGIN TRY    
        SELECT 
             ROW_NUMBER() OVER (ORDER BY User_Name, [Task_Name]) AS Sno,  *
             FROM (
                    SELECT DISTINCT
                     TRIM(RM.Report_Name) AS Task_Name
                    ,LM.[User_Name] 
                    ,UPPER(TRIM(LM.User_Id)) AS UserId
                    ,RM.Rec_ID ReportId
                    ,UTA.Approver
                    ,UTA.RecId
                    -- ,LocM.Loc_Id
                    ,LM.Role_Id
                    FROM 
                        [dbo].[SD_UserTaskAssignment] UTA
                    INNER JOIN 
                        SD_Login_Master LM ON LM.User_Id = UTA.UserId
                    -- INNER JOIN 
                    --     SD_Location_Master LocM ON UPPER(TRIM(LM.Location_Id)) = UPPER(TRIM(LocM.Loc_Id)) 
                    INNER JOIN 
                        SD_Reports_Master RM ON RM.Rec_ID = UTA.ReportId
                    INNER JOIN 
                        SD_Category_Master CM ON CM.Rec_Id = RM.Category_Id
                    INNER JOIN 
                        SD_Category_Type_Master CTM ON CTM.Rec_Id = CM.Category_Type_Id 
                    WHERE 
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
                    RM.[Rec_Id] = IIF(@Report_Id = 0, RM.[Rec_Id], @Report_Id) 
                    AND 
                    CM.[Rec_Id] = IIF(@Category_Id = 0, CM.[Rec_Id], @Category_Id) 
                    AND 
                    CTM.[Rec_Id] = IIF(@Category_Type_Id = 0, CTM.[Rec_Id], @Category_Type_Id) 
                    AND -- ISNULL(UPPER(TRIM(UTA.Approver)),'') = @Approver_Id 
                    UPPER(TRIM(UTA.UserId)) = IIF(ISNULL(@User_Id,'') = '', UPPER(TRIM(UTA.UserId)), @User_Id)
                    -- AND
                    -- UPPER(TRIM(LocM.Loc_Id)) = IIF(ISNULL(@LocationId,'') = '', UPPER(TRIM(LocM.Loc_Id)), @LocationId)
                    AND
                    LM.Role_Id = IIF(@RoleId = 0, LM.Role_Id, @RoleId)
                    -- AND
                    -- LocM.Active = 1
                    AND     
                    (                       
                        (
                            @IsAdmin = 0
                        )
                        OR 
                        (
                            @IsAdmin = 1 AND UTA.Approver IS NOT NULL
                        )
                    ) 
                            AND 
                            UPPER(TRIM(UTA.Approver)) = IIF(ISNULL(@Approver_Id, '') = '', UPPER(TRIM(UTA.Approver)), @Approver_Id)
             ) TBL         
            ORDER BY 
                [User_Name], [Task_Name], [UserId] ASC
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE();
    END CATCH;
END;
GO

