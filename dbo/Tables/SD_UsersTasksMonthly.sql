CREATE TABLE [dbo].[SD_UsersTasksMonthly] (
    [RecId]         INT           IDENTITY (1, 1) NOT NULL,
    [UserId]        VARCHAR (50)  NOT NULL,
    [ReportId]      INT           NOT NULL,
    [ReportName]    VARCHAR (150) NULL,
    [DueDate]       VARCHAR (50)  NOT NULL,
    [Month]         INT           CONSTRAINT [DEFAULT_SD_UsersTasksMonthly_Month] DEFAULT ((0)) NOT NULL,
    [ReportTypeId]  INT           NULL,
    [Active]        BIT           CONSTRAINT [DEFAULT_SD_UsersTasksMonthly_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]  DATETIME      CONSTRAINT [DEFAULT_SD_UsersTasksMonthly_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]    VARCHAR (20)  NOT NULL,
    [Modified_Date] DATETIME      NULL,
    [Modified_By]   VARCHAR (20)  NULL
);
GO

