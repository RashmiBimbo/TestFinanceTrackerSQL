CREATE TABLE [dbo].[SD_Reports_Master] (
    [Rec_ID]        INT           IDENTITY (1, 1) NOT NULL,
    [Report_Name]   VARCHAR (150) NOT NULL,
    [Category_Id]   INT           NOT NULL,
    [Priority]      INT           NOT NULL,
    [Weight]        INT           NOT NULL,
    [Type]          VARCHAR (50)  NULL,
    [TypeId]        INT           NOT NULL,
    [Due_Date]      VARCHAR (10)  NOT NULL,
    [Active]        BIT           CONSTRAINT [DEFAULT_SD_Reports_Master_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]  DATETIME      CONSTRAINT [DEFAULT_SD_Reports_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]    VARCHAR (20)  NOT NULL,
    [Modified_Date] DATETIME      NULL,
    [Modified_By]   VARCHAR (20)  NULL,
    CONSTRAINT [PK_SD_Reports_Master] PRIMARY KEY CLUSTERED ([Rec_ID] ASC),
    CONSTRAINT [FK_SD_Reports_Master_SD_Category_Master] FOREIGN KEY ([Category_Id]) REFERENCES [dbo].[SD_Category_Master] ([Rec_Id]),
    CONSTRAINT [FK_SD_Reports_Master_SD_ReportType_Master] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[SD_ReportType_Master] ([RecId])
);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Make sure that categories which are already present in SD_Category_Master are added.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SD_Reports_Master', @level2type = N'CONSTRAINT', @level2name = N'FK_SD_Reports_Master_SD_Category_Master';


GO







ALTER TABLE [dbo].[SD_Reports_Master]
    ADD CONSTRAINT [FK_SD_Reports_Master_SD_ReportType_Master] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[SD_ReportType_Master] ([RecId]);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The TypeIds are RecIds of SD_ReportType_Master', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SD_Reports_Master', @level2type = N'CONSTRAINT', @level2name = N'FK_SD_Reports_Master_SD_ReportType_Master';
GO

