-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <09-01-2024>
-- Description:	<Get the Report details from SD_Report_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Report_Get]
  @Category_Id int = 0
 ,@Category_Type_Id int = 0
 ,@Type VARCHAR(50) = NULL
 ,@Report_Id int = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    /*
        SP_Get_Reports  17
    */
    SELECT ROW_NUMBER() OVER(ORDER BY Report_Name) Sno, * FROM
    (
        Select DISTINCT TRIM(RM.Report_Name) Report_Name, TRIM(RM.[Type]) [Type_orgnl], RM.Rec_Id Report_Id 
        -- ,CASE 
        -- WHEN UPPER(RM.[Type])='W' THEN 'Weekly'
        -- WHEN UPPER(RM.[Type])='M' THEN 'Monthly'
        -- WHEN UPPER(RM.[Type])='HY' THEN 'Half Yearly'
        -- END
        -- [Type]
        ,[Type]
        -- ,IIF(UPPER(RM.[Type])='W', 'Weekly', 'Monthly') 
        , TRIM(RM.Due_Date) [Due_Date_Orgnl]
        -- ,IIF
        -- (
        --     ISNUMERIC(RM.Due_Date) = 1 
        --     ,RM.Due_Date
        --     -- Every Weekday e.g. Every Thusrday
        --     ,IIF
        --      (
        --          TRIM(ISNULL(RM.Due_Date,'')) = '', 
        --          '',
        --          'Every ' + LEFT(UPPER(TRIM(RM.Due_Date)), 1) + SUBSTRING(LOWER(TRIM(RM.Due_Date)), 2, LEN(TRIM(RM.Due_Date)) - 1)
        --      )
        -- ) 
        -- [Due_Date]
        ,IIF
        (
            ISNUMERIC(RM.Due_Date) = 1 
            ,CASE
                WHEN RM.Due_Date = '41' THEN '01-Jan-'+ CAST(YEAR(GETDATE()) AS VARCHAR(4))
                WHEN RM.Due_Date = '42' THEN '01-Jul-'+ CAST(YEAR(GETDATE()) AS VARCHAR(4))
                ELSE RM.Due_Date
            END 
            -- Every Weekday e.g. Every Thusrday
            ,IIF
             (
                 TRIM(ISNULL(RM.Due_Date,'')) = '', 
                 '',
                 'Every ' + LEFT(UPPER(TRIM(RM.Due_Date)), 1) + SUBSTRING(LOWER(TRIM(RM.Due_Date)), 2, LEN(TRIM(RM.Due_Date)) - 1)
             )
        ) 
        [Due_Date]
        , RM.Priority, RM.Weight, CTM.Category_Type_Name, CM.Category_Name,CM.Rec_Id [Category_Id], CTM.Rec_Id [Category_Type_Id]
        ,'Edit' BtnTxt
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
        RM.[Type] = IIF(ISNULL(@Type, '') = '', [Type], @Type) 
        AND 
        RM.Active = 1 
        AND
        CM.Active = 1 
        AND
        CTM.Active = 1 
    ) TBL
    ORDER BY Report_Name, Report_Id
END
GO

