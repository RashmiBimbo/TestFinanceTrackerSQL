-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <05-01-2024>
-- Description:	<Get the Category Type from SD_Category_Type_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Categories]
@Type_Id int = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT CM.Rec_Id Category_Id,
           TRIM(CM.Category_Name) Category_Name,
            LEFT(UPPER(TRIM(Category_Name)), 1) + SUBSTRING(LOWER(TRIM(Category_Name)), 2, LEN(TRIM(Category_Name)) - 1) Cat
    FROM [TestFinanceTracker].[DBO].[SD_Category_Master] CM
    WHERE Active = 1 AND CM.[Category_TYPE_ID] = IIF(@Type_Id = 0, CM.Category_TYPE_ID, @Type_Id) 
    ORDER BY Category_Name
END

GO

