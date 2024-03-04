-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <05-01-2024>
-- Description:	<Get the Category Type from SD_Category_Type_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_CategoryTypes]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT Rec_Id Category_Type_Id,
           TRIM(Category_Type_Name)
    FROM [DBO].[SD_Category_Type_Master] CTM
    WHERE Active = 1
    ORDER BY Category_Type_Name
END

GO

