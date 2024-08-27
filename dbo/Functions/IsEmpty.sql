-- =============================================
-- Author:		<RASHMI GUPTA>
-- Create date: <14-05-2024>
-- Description:	<SQL equivalent of string.IsNullOrEmptyOrWhiteSpace>
-- =============================================
CREATE FUNCTION [dbo].[IsEmpty] 
(
	@Obj VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
    /*    
        SELECT DBO.IsEmpty('HI');
    */
	-- Declare the return variable here
	DECLARE @Ans BIT;

	-- Add the T-SQL statements to compute the return value here
	If(ISNULL(TRIM(@Obj),'') = '')
		SET  @Ans = 1;
	ELSE 
		SET @Ans = 0;

	-- Return the result of the function
	RETURN @ANS;

END
GO

