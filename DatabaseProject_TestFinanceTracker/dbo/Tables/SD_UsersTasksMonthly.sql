CREATE TABLE [dbo].[SD_UsersTasksMonthly] (
    [RecId]         INT          IDENTITY (1, 1) NOT NULL,
    [ReportId]      INT          NOT NULL,
    [UserId]        VARCHAR (50) NOT NULL,
    [DueDate]       VARCHAR (50) NULL,
    [Month]         INT          NOT NULL,
    [ReportTypeId]  INT          NULL,
    [Active]        BIT          NOT NULL,
    [Created_Date]  DATETIME     NOT NULL,
    [Created_By]    VARCHAR (20) NOT NULL,
    [Modified_Date] DATETIME     NULL,
    [Modified_By]   VARCHAR (20) NULL
);
GO

ALTER TABLE [dbo].[SD_UsersTasksMonthly]
    ADD CONSTRAINT [DEFAULT_SD_UsersTasksMonthly_Month] DEFAULT ((0)) FOR [Month];
GO

ALTER TABLE [dbo].[SD_UsersTasksMonthly]
    ADD CONSTRAINT [DEFAULT_SD_UsersTasksMonthly_Created_Date] DEFAULT (getdate()) FOR [Created_Date];
GO

ALTER TABLE [dbo].[SD_UsersTasksMonthly]
    ADD CONSTRAINT [DEFAULT_SD_UsersTasksMonthly_Active] DEFAULT ((1)) FOR [Active];
GO

