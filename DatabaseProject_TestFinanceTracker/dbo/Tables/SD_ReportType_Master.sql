CREATE TABLE [dbo].[SD_ReportType_Master] (
    [RecId]         INT          IDENTITY (1, 1) NOT NULL,
    [TypeName]      VARCHAR (50) NOT NULL,
    [Active]        BIT          NOT NULL,
    [Created_Date]  DATETIME     NOT NULL,
    [Created_By]    VARCHAR (20) NOT NULL,
    [Modified_Date] DATETIME     NULL,
    [Modified_By]   VARCHAR (20) NULL
);
GO

ALTER TABLE [dbo].[SD_ReportType_Master]
    ADD CONSTRAINT [DEFAULT_SD_ReportType_Master_Active] DEFAULT ((1)) FOR [Active];
GO

ALTER TABLE [dbo].[SD_ReportType_Master]
    ADD CONSTRAINT [DEFAULT_SD_ReportType_Master_Created_Date] DEFAULT (getdate()) FOR [Created_Date];
GO

