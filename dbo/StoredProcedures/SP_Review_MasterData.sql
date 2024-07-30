-- =============================================
-- Author:		<Rashmi Gupta>
-- Create date: <12-02-2024>
-- Description:	<Get data of all users and their assigned tasks.>
-- =============================================
-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[SP_Review_MasterData]
    @Role_Id int = 0
   ,@User_Id varchar(20) = NULL
   ,@Type_Id INT = 0
   ,@Location_Id varchar(20) = NULL
   ,@Report_Id int = 0
   ,@Approver_Id varchar(20) = NULL
AS
BEGIN
/*
    SP_Review_MasterData 0, null, 0, 'corp'
*/
	SET @Approver_Id = UPPER(TRIM(@Approver_Id)); 
	SET @User_Id = UPPER(TRIM(@User_Id)); 
	SET @Location_Id = UPPER(TRIM(@Location_Id)); 

    SELECT 
         [Sno], [User_Name], Report_Name, [TypeName] [Report_Type], [Due_Date], Approve_Date, Priority, [Weight], [User_Id], [Report_Id] [Task_Id], [Approver], FileLocation [Location]
	    FROM 
            V_Review V
        WHERE
         ISNULL(TRIM(V.Approver),'') != '' 
         AND
        Type_Id = IIF(@Type_Id = 0, V.Type_Id, @Type_Id)
         AND
        User_Id= DBO.CheckStr(@User_Id, V.User_Id)
         AND
        Report_Id= IIF(@Report_Id = 0, V.Report_Id, @Report_Id)
         AND
        Role_Id= IIF(@Role_Id = 0, V.Role_Id, @Role_Id)
         AND
        Location_Id= dbo.CheckStr(@Location_Id, Location_Id)
         AND
        Approver= dbo.CheckStr(@Approver_Id, Approver)
END
GO

