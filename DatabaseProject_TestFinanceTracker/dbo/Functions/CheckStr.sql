-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <14-05-2024>
-- Description:	<Return default string if @Str is Null/Empty/WhiteSpace otherwise return it in Upper case>
-- =============================================
CREATE FUNCTION [dbo].[CheckStr] 
(
	@Str VARCHAR(MAX), @Default VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    --Select dbo.CheckStr(' ')
	-- Declare the return variable here
	DECLARE @Ans VARCHAR(MAX);

    SET @Str = UPPER(TRIM(@Str));
    SET @Default = UPPER(TRIM(@Default));

	-- Add the T-SQL statements to compute the return value here
	If(ISNULL(@Str,'') = '')
		SET @Ans = @Default;
	ELSE 
		SET @Ans = @Str;

	-- Return the result of the function
	RETURN @ANS;

END
GO

