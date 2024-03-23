-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <05-01-2024>
-- Description:	<Get the Category Type from SD_Category_Type_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_CategoryTypes]
@Category_Type_Id INT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT Rec_Id Category_Type_Id, TRIM(Category_Type_Name) Category_Type_Name
    FROM [DBO].[SD_Category_Type_Master] CTM
    WHERE Active = 1 AND Rec_Id = IIF( @Category_Type_Id =0, Rec_Id, @Category_Type_Id)
    ORDER BY Category_Type_Name
END

GO

