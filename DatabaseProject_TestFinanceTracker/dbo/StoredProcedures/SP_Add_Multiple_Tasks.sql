SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <06-02-2024>
-- Description:	<add multiple tasks for same user >
-- =============================================
-- Create the stored procedure in the specified schema
ALTER PROCEDURE [dbo].[SP_Add_Multiple_Tasks]
   @Collection VARCHAR(MAX)
AS
BEGIN
    -- body of the stored procedure
    SET NOCOUNT ON;
   
    DECLARE @tbl TABLE
    (
         [User_Id] VARCHAR(20)
        ,[Report_Id] INT
        ,[Report_Type] CHAR(10)
        ,[Add_Date] DATE
        ,[Month_From_Date] DATE
        ,[Month_To_Date] DATE
        ,[Month_Week_No] INT
        ,[Location] VARCHAR(MAX)
        ,[Created_By] VARCHAR(20)
    );

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO @tbl
        (            
            [USER_ID] ,[REPORT_ID] ,[Report_Type] ,[Add_Date] ,[MONTH_FROM_DATE] ,[MONTH_TO_DATE] ,[MONTH_WEEK_NO] ,[LOCATION] ,[CREATED_BY]
		)
        SELECT *
        FROM
            OPENJSON(@Collection)
            WITH
            (
                 [User_Id] VARCHAR(20)    '$.USER_ID'
				,[Report_Id] INT          '$.REPORT_ID'
				,[Report_Type] CHAR(10)   '$.REPORT_TYPE'
				,[Add_Date] DATE          '$.ADD_DATE'
				,[Month_From_Date] DATE   '$.MONTH_FROM_DATE'
				,[Month_To_Date] DATE     '$.MONTH_TO_DATE'
				,[Month_Week_No] INT      '$.MONTH_WEEK_NO'
				,[Location] VARCHAR(MAX)  '$.LOCATION'
				,[Created_By] VARCHAR(20) '$.CREATED_BY'
            );   		

        MERGE INTO SD_Performance AS [target]
        USING @tbl AS [source]
        ON  
		    UPPER(TRIM([target].[User_Id])) = UPPER(TRIM([source].[User_Id]))
		    AND [target].[Report_Id] = [source].[Report_Id]
		    AND [target].[Month_From_Date]=[source].[Month_From_Date]
		    AND [target].[Month_To_Date] = [source].[Month_To_Date]
		    AND [target].[Month_Week_No] = [source].[Month_Week_No]	
            AND ACTIVE = 1			
        WHEN NOT MATCHED THEN                 
	        INSERT
	        (
	             [User_Id]
	            ,[Report_Id]
	            ,[Report_Type]
	            ,[Add_Date]
	            ,[Month_From_Date]
	            ,[Month_To_Date]
	            ,[Month_Week_No]
	            ,[Location]
	            ,[Created_By]
	        )
	        VALUES
	        (
	            UPPER(TRIM([Source].[USER_ID])) ,[Source].[REPORT_ID] ,UPPER(TRIM([Report_Type])) ,[Source].[Add_Date] ,[Source].[MONTH_FROM_DATE] ,[Source].[MONTH_TO_DATE] , [Source].[MONTH_WEEK_NO] ,[Source].[LOCATION] ,[Source].[CREATED_BY]
	        );
            
            --OUTPUT $[action], inserted.*, deleted.*;
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH
END

GO
