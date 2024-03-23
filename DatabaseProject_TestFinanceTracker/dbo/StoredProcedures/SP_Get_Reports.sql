-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <09-01-2024>
-- Description:	<Get the Report details from SD_Report_Master>
-- =============================================
ALTER PROCEDURE [dbo].[SP_Report_Get]
  @Category_Id int = 0
 ,@Category_Type_Id int = 0
 ,@Report_Id int = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    /*
        SP_Get_Reports 
    */
    SELECT
     RM.Rec_Id Report_Id, TRIM(RM.Report_Name) Report_Name, TRIM(RM.[Type]) [Type], TRIM(RM.Due_Date) [Due_Date], CM.Rec_Id [Category_Id], CTM.Rec_Id [Category_Type_Id] 
    FROM [DBO].[SD_Reports_Master] RM
    INNER JOIN SD_Category_Master CM ON CM.Rec_Id = RM.Category_Id
    INNER JOIN SD_Category_Type_Master CTM ON CTM.Rec_Id = CM.Category_Type_Id 
    WHERE 
    RM.[Rec_Id] = IIF(@Report_Id = 0, RM.[Rec_Id], @Report_Id) 
    AND 
    CM.[Rec_Id] = IIF(@Category_Id = 0, CM.[Rec_Id], @Category_Id) 
    AND 
    CTM.[Rec_Id] = IIF(@Category_Type_Id = 0, CTM.[Rec_Id], @Category_Type_Id) 
    AND 
    RM.Active = 1 
    AND
    CM.Active = 1 
    AND
    CTM.Active = 1 
    ORDER BY Report_Name, Report_Id
END

GO

