-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <14-05-2024>
-- Description:	<Return default string if @Str is Null/Empty/WhiteSpace otherwise return it in Upper case>
-- =============================================
CREATE FUNCTION [dbo].[GetCatTypeByUserType] 
(
	@User_Type VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    /*    
    SELECT [dbo].[GetCatTypeByUserType]('CORPORATE') ;
    */
    DECLARE @Type_Id INT = 0;

    IF DBO.IsEmpty(@User_Type) = 0   ---UsrTyp is not null, empty, whitespace
        SELECT @Type_Id = Rec_Id FROM SD_Category_Type_Master 
            WHERE DBO.CapsStr(Category_Type_Name) = DBO.CapsStr(@User_Type);

	RETURN @Type_Id;
END
GO

