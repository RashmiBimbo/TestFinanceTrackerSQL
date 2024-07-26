-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <17-1-2023>
-- Description:	<Update in SD_Performance. It is used in Finance_Tracker\Performance.aspx.cs\BtnApprove_Click >
-- =============================================

CREATE PROCEDURE [dbo].[SP_Submit_Tasks] 
    @Collection VARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    -- Insert statements for procedure here

    DECLARE @tbl TABLE
    (
        Rec_ID int,
        Submit_Date DATE,
        Modified_By VARCHAR(50),
        Modified_Date DATETIME
    );

    BEGIN TRY
        INSERT INTO @tbl
        (
            REC_ID, SUBMIT_DATE, MODIFIED_BY, MODIFIED_DATE
        )
        SELECT *
        FROM
            OPENJSON(@Collection)
            WITH
            (
                 REC_ID int '$.REC_ID',
                 SUBMIT_DATE DATE '$.SUBMIT_DATE',
                 MODIFIED_BY VARCHAR(50) '$.MODIFIED_BY',
                 MODIFIED_DATE DATETIME '$.MODIFIED_DATE'
            );   

        BEGIN TRANSACTION;

        MERGE INTO SD_Performance AS [target]
        USING @tbl AS [source]
        ON [target].REC_ID = [source].REC_ID
        WHEN MATCHED THEN --if the row already exists, update it            
            UPDATE SET [target].SUBMIT_DATE = [source].SUBMIT_DATE,
                       [target].MODIFIED_BY = UPPER([source].[MODIFIED_BY]),
                       [target].MODIFIED_DATE = IIF(ISNULL([source].[MODIFIED_DATE],'') = '', GETDATE(), [source].[MODIFIED_DATE])
            --OUTPUT $[action], inserted.*, deleted.*
            ;
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH
END;
    /* 
        SP_Submit_Tasks
        '[
            {
              "REC_ID": 94,
              "SUBMIT_DATE": "2024-01-31",
              "MODIFIED_BY": "Test",
              "MODIFIED_DATE": "2024-01-31 11:03:24.874"
            },
            {
            "REC_ID": 91,
            "SUBMIT_DATE": "2024-01-31",
            "MODIFIED_BY": "Test",
            "MODIFIED_DATE": "2024-01-31 11:03:42.210"
            }
        ]'
    */

GO

