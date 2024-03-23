-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <05-01-2024>
-- Description:	<Get the Category Type from SD_Category_Type_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Report_Delete]
    @Collection VARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    DECLARE @tbl TABLE
    (
        Rec_ID int,
        Modified_By VARCHAR(50),
        Modified_Date DATETIME
    );

    BEGIN TRY
        INSERT INTO @tbl
        (
            Rec_ID, Modified_By, Modified_Date
        )
        SELECT *
        FROM
            OPENJSON(@Collection)
            WITH
            (
                 Rec_ID int '$.REC_ID',
                 Modified_By VARCHAR(50) '$.MODIFIED_BY',
                 Modified_Date DATETIME '$.MODIFIED_DATE'
            );   

        BEGIN TRANSACTION;

        MERGE INTO SD_Reports_Master AS [target]
        USING @tbl AS [source]
        ON [target].REC_ID = [source].REC_ID
        WHEN MATCHED THEN  
            UPDATE SET 
                [target].[Active]      = 0,
                [target].MODIFIED_BY   = UPPER(TRIM([source].[MODIFIED_BY])),
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
    SP_Report_Delete
        '[
           {
             "REC_ID": "10122",
             "MODIFIED_BY": "Ashish",
             "MODIFIED_DATE": "2024-03-06 10:00:56.504"
           }
         ]'
    */
END;
GO

