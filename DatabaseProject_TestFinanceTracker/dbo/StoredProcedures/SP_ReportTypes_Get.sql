-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <05-01-2024>
-- Description:	<Get the Category Type from SD_Category_Type_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ReportTypes_Get]
@Type_Id int = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT RM.RecId TypeId, TRIM(RM.TypeName) TypeName
    FROM [DBO].[SD_ReportType_Master] RM
    WHERE Active = 1 AND RM.[RecId] = IIF(@Type_Id = 0, RM.RecId, @Type_Id) AND DBO.IsEmpty(TypeName) = 0
    ORDER BY RecId
END
GO

