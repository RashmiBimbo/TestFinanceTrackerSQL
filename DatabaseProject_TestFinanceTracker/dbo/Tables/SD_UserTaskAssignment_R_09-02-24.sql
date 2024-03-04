CREATE TABLE [dbo].[SD_UserTaskAssignment_R_09-02-24] (
    [RecId]         NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [UserId]        VARCHAR (50)  NULL,
    [ReportId]      INT           NULL,
    [ReportName]    VARCHAR (150) NULL,
    [Active]        BIT           NOT NULL,
    [Created_Date]  DATETIME      CONSTRAINT [DF_TaskAssignment_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]    VARCHAR (20)  NOT NULL,
    [Modified_Date] DATETIME      NULL,
    [Modified_By]   VARCHAR (20)  NULL,
    [Approver]      VARCHAR (50)  NULL,
    CONSTRAINT [PK_SD_UserTaskAssignment] PRIMARY KEY CLUSTERED ([RecId] ASC),
    CONSTRAINT [FK_SD_UserTaskAssignment_SD_Login_Master] FOREIGN KEY ([UserId]) REFERENCES [dbo].[SD_Login_Master] ([User_Id]),
    CONSTRAINT [FK_SD_UserTaskAssignment_SD_Reports_Master] FOREIGN KEY ([ReportId]) REFERENCES [dbo].[SD_Reports_Master] ([Rec_ID])
);


GO

