
CREATE VIEW [dbo].[V_Performance]
AS
    SELECT CM.[Category_Name] AS Category_Name,
        CTM.[Category_Type_Name] AS Category_Type,
        LM.[User_Name] AS Plant_Name,
        SP.[Add_Date],
        RM.[Priority],
        RM.[Weight],
        IIF(RM.[Type] = 'W', 'Weekly', IIF(RM.[Type] = 'M', 'Monthly', RM.[Type])) AS Report_Type,
        RM.Due_Date,
        RM.[Report_Name] AS [Report_Name],
        FORMAT(EOMONTH(GETDATE(), -1), 'MMM, yyyy') [Month],
        LM.User_Id
    FROM dbo.SD_Category_Master AS CM
        INNER JOIN dbo.SD_Category_Type_Master AS CTM
        ON CM.Category_Type_Id = CTM.Rec_Id
        INNER JOIN dbo.SD_Reports_Master AS RM
        ON CM.Rec_Id = RM.Category_Id
        INNER JOIN dbo.SD_Performance AS SP
        ON RM.Rec_ID = SP.Report_Id
        INNER JOIN dbo.SD_Login_Master AS LM
        ON SP.[User_Id] = LM.[User_Id]
    WHERE (CM.Active = 1)
        AND (RM.Active = 1)
        AND (SP.Active = 1)
        AND (LM.Active = 1)

GO

EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[12] 2[53] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CM"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 206
               Right = 297
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "LM"
            Begin Extent = 
               Top = 7
               Left = 1021
               Bottom = 204
               Right = 1253
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "SP"
            Begin Extent = 
               Top = 9
               Left = 684
               Bottom = 206
               Right = 906
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RM"
            Begin Extent = 
               Top = 10
               Left = 385
               Bottom = 207
               Right = 607
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1880
         Table = 1170
         Output = 2040
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 530
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V_Performance';


GO

EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V_Performance';


GO

