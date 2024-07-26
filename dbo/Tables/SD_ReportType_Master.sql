CREATE TABLE [dbo].[SD_ReportType_Master] (
    [RecId]         INT          IDENTITY (1, 1) NOT NULL,
    [TypeName]      VARCHAR (50) NOT NULL,
    [Active]        BIT          CONSTRAINT [DEFAULT_SD_ReportType_Master_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]  DATETIME     CONSTRAINT [DEFAULT_SD_ReportType_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]    VARCHAR (20) NOT NULL,
    [Modified_Date] DATETIME     NULL,
    [Modified_By]   VARCHAR (20) NULL,
    CONSTRAINT [PK_SD_ReportType_Master] PRIMARY KEY CLUSTERED ([RecId] ASC)
);
GO

