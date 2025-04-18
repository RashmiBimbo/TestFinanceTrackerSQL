-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <17-1-2023>
-- Description:	<Add OR Update UserTaskAssignment. It is used in Finance_Tracker\UserTaskAssignment.aspx.cs\BtnUnAssign_Click and BtnAssign_Click >
-- =============================================

ALTER PROCEDURE [dbo].[SP_Add_Update_TaskAssignment] 
    @Collection VARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    DECLARE @tbl TABLE
    (
         [UserId]       VARCHAR (50) 
        ,[ReportId]     INT          
        ,[ReportName]   VARCHAR (150)
        ,[Created_Date] DATETIME     
        ,[Created_By]   VARCHAR (20) 
        ,[Approver]     VARCHAR (50) 
        ,[Active]       BIT
    );
    
    DECLARE @InsertedRecIds TABLE (
        RecId INT
    );

    BEGIN TRY
        INSERT INTO @tbl
        (
            [UserId], [ReportId], [ReportName], [Created_By], [Approver], [Active]    
        )
        SELECT UPPER(TRIM([UserId])), [ReportId], [ReportName], TRIM([Created_By]), UPPER(TRIM([Approver])), CAST([Active] AS BIT)      
        FROM OPENJSON(@Collection)
        WITH
        (
             [UserId]     VARCHAR (50)  '$.USER_ID'
            ,[ReportId]   INT           '$.REPORT_ID'
            ,[ReportName] VARCHAR (150) '$.REPORT_NAME'
            ,[Created_By] VARCHAR (20)  '$.CREATED_BY'
            ,[Approver]   VARCHAR (50)  '$.APPROVER'
            ,[Active]     BIT           '$.ACTIVE'
        );   

        BEGIN TRANSACTION;

        MERGE INTO SD_UserTaskAssignment AS [target]
        USING @tbl AS [source]
        ON 
            UPPER(TRIM([target].[UserId])) = [source].[UserId]     --if given user and report already present, modify approver and active status
            AND [target].[ReportId] = [source].[ReportId]
        -- AND ISNULL(UPPER(TRIM([target].[Approver])),'') = ISNULL(UPPER(TRIM([source].[Approver])),'')
        WHEN MATCHED THEN            
            UPDATE 
            SET 
                [target].[Active]        = [source].[ACTIVE],
                [target].[ReportName]    = [source].[ReportName],
                [target].[Approver]      = UPPER(TRIM([source].[Approver])),
                [target].[MODIFIED_BY]   = TRIM([source].[Created_By]),
                [target].[MODIFIED_DATE] = GETDATE()
        WHEN NOT MATCHED THEN --if the row not exists, add it            
            INSERT
            (
                [UserId], [ReportId], [ReportName], [Created_Date], [Created_By], [Approver], [Active]
            )
            VALUES
            ( 
                [source].[UserId], [source].[ReportId], [source].[ReportName], GETDATE(), [source].[Created_By], [source].[Approver], [source].[ACTIVE]
            )
            -- OUTPUT $action, inserted.*, inserted.*

            OUTPUT inserted.RecId INTO @InsertedRecIds
            ;

            --Convert the RecIds to a comma-delimited string
            DECLARE @RecIdList NVARCHAR(MAX);
            
            SELECT @RecIdList = STRING_AGG(CAST(RecId AS NVARCHAR), ',') FROM @InsertedRecIds;

            EXEC SP_Add_Update_UsersTasksMonthly 0, 0, @RecIdList;
            
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH
END;
    /* 
        SP_Add_Update_TaskAssignment
        '
            [
              {
                "USER_ID": "ASHISH",
                "REPORT_ID": "509",
                "REPORT_NAME": "plnt ir hy 1",
                "CREATED_BY": "Ashish",
                "APPROVER": "ASHISH",
                "ACTIVE": "0"
              }
            ]
        '
    */
GO

