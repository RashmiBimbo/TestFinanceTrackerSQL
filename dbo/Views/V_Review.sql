
CREATE VIEW [dbo].[V_Review]
/* 
SELECT * FROM V_Review
*/
AS
    SELECT ROW_NUMBER() OVER ( ORDER BY [User_Name], Report_Name) Sno, * FROM (
    SELECT ROW_NUMBER() OVER (PARTITION BY LM.[User_Id], RM.Report_Name ORDER BY LM.[User_Id], RM.Report_Name) RN, LM.User_Id, LM.[User_Name], LM.Location_Id, LM.Role_Id, LM.Rec_Id Login_Rec_Id, UTA.Approver, UTA.RecId UTA_REC_ID, RM.Rec_ID Report_Id, RM.Report_Name, RTM.RecId [Type_Id], RTM.TypeName, RM.Due_Date, RM.Priority, RM.Weight, CM.Category_Name, CM.Rec_Id CATEGORY_ID, CTM.Rec_Id Category_Type_ID, CTM.Category_Type_Name, P.Add_Date, P.Approve_Date, P.Comments, P.Month_From_Date, P.Month_To_Date, P.Month_Week_No, P.Submit_Date, P.Year_Half_No, P.Year_Quarter_No, P.Rec_ID Performance_ID, P.[Location] [FileLocation]
    FROM 
        SD_Login_Master LM 
        INNER JOIN SD_UserTaskAssignment UTA ON UTA.UserId = LM.User_Id
        INNER JOIN SD_Reports_Master RM ON RM.Rec_ID = UTA.ReportId
        INNER JOIN SD_Category_Master CM ON CM.Rec_Id = RM.Category_Id
        INNER JOIN SD_Category_Type_Master CTM ON CTM.Rec_Id = CM.Category_Type_Id
        INNER JOIN SD_ReportType_Master RTM ON RTM.RecId = RM.TypeId
        LEFT JOIN SD_Performance P ON UPPER(TRIM(LM.User_Id)) = UPPER(TRIM(P.[User_Id])) AND P.Report_Id = RM.Rec_ID
        WHERE
            RM.Active = 1
            AND
            CM.Active = 1
            AND
            CTM.Active = 1
            AND 
            (UTA.Active = 1 and ISNULL(TRIM(UTA.Approver),'') != '')
        ) TBL
        WHERE RN = 1
GO

