CREATE TABLE [dbo].[SD_UserTaskAssignment] (
    [RecId]         NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [UserId]        VARCHAR (50)  NOT NULL,
    [ReportId]      INT           NOT NULL,
    [ReportName]    VARCHAR (150) NULL,
    [Approver]      VARCHAR (50)  NULL,
    [Active]        BIT           CONSTRAINT [DEFAULT_SD_UserTaskAssignment_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]  DATETIME      NOT NULL,
    [Created_By]    VARCHAR (20)  NOT NULL,
    [Modified_Date] DATETIME      NULL,
    [Modified_By]   VARCHAR (20)  NULL,
    CONSTRAINT [FK_SD_UserTaskAssignment_SD_Login_Master_New] FOREIGN KEY ([UserId]) REFERENCES [dbo].[SD_Login_Master] ([User_Id]),
    CONSTRAINT [FK_SD_UserTaskAssignment_SD_Reports_Master_New] FOREIGN KEY ([ReportId]) REFERENCES [dbo].[SD_Reports_Master] ([Rec_ID])
);


GO

