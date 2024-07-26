-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <17-1-2023>
-- Description:	<Reject the approved task submitted by user in SD_Performance. It is used in Finance_Tracker\Review.aspx.cs\BtnReject_Click >
-- =============================================

CREATE PROCEDURE [dbo].[SP_Reject_Tasks] 
    @Collection VARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    -- Insert statements for procedure here

    DECLARE @tbl TABLE
    (
        Rec_ID int,
        Comments VARCHAR(1000),
        Modified_By VARCHAR(50),
        Modified_Date DATETIME
    );

    BEGIN TRY
        INSERT INTO @tbl
        (
            Rec_ID, Comments, Modified_By, Modified_Date
        )
        SELECT *
        FROM
            OPENJSON(@Collection)
            WITH
            (
                 Rec_ID int '$.REC_ID',
                 Comments VARCHAR(1000)  '$.COMMENTS',
                 Modified_By VARCHAR(50) '$.MODIFIED_BY',
                 Modified_Date DATETIME '$.MODIFIED_DATE'
            );   

        BEGIN TRANSACTION;

        MERGE INTO SD_Performance AS [target]
        USING @tbl AS [source]
        ON [target].REC_ID = [source].REC_ID
        WHEN MATCHED THEN --if the row already exists, update it            
            UPDATE SET 
                [target].Approve_Date = NULL,
                [target].Submit_Date = NULL,
                [target].[Comments] = source.[Comments],
                [target].MODIFIED_BY = UPPER(TRIM([source].[MODIFIED_BY])),
                [target].MODIFIED_DATE = IIF(ISNULL([source].[MODIFIED_DATE],'') = '', GETDATE(), [source].[MODIFIED_DATE])
            --OUTPUT $[action], inserted.*, deleted.*
            ;
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH
    /* 
    SP_Reject_Tasks
        '[
           {
             "REC_ID": "10122",
             "COMMENTS": "hi",
             "MODIFIED_BY": "Ashish",
             "MODIFIED_DATE": "2024-03-06 10:00:56.504"
           }
         ]'
    */
END;

GO

