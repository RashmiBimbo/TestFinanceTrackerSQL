-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <19-03-2024>
-- Description:	<Get the types of report>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Report_Type_Get]
@ReportId INT = 0,
@ReportName VARCHAR(150) = NULL
AS
BEGIN
    /*
    */
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @ReportName = UPPER(TRIM(@ReportName));

    SELECT DISTINCT RM.[Type] ReportType FROM SD_Reports_Master RM
    WHERE
    RM.Active = 1
    AND
    RM.Rec_ID = IIF(@ReportId = 0, RM.Rec_ID, @ReportId)
    AND
    RM.Report_Name = IIF(ISNULL(@ReportName,'') = '', RM.Report_Name, @ReportName)
    ORDER BY RM.[Type]
END;
GO

