-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <02-01-2024>
-- Description:	<Get the Locations from SD_Location_Master>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Locations] @Company_Id VARCHAR(20) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT UPPER(TRIM(LM.Loc_Id)) [Loc_Id],
           TRIM(LM.Loc_Name) [Loc_Name],
           Company_Id,
           TRIM(LM.[ADDRESS]) [Loc_Address]
    FROM [DBO].[SD_Location_Master] LM
    WHERE Company_Id = IIF(ISNULL(@Company_Id, '') = '', Company_Id, @Company_Id)
        and Active = 1
    ORDER BY Loc_Name
END

GO

