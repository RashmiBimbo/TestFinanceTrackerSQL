-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <14-05-2024>
-- Description:	<Return default string if @Str is Null/Empty/WhiteSpace otherwise return it in Upper case>
-- =============================================
CREATE FUNCTION [dbo].[CapsStr] 
(
	@Str VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    /*    
    SELECT [dbo].[CapsStr]('abvc') ;
    */
	RETURN UPPER(TRIM(@Str));

END
GO

