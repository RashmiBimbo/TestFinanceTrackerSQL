CREATE TABLE [dbo].[SD_UserTaskAssignment_R] (
    [RecId]         NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [UserId]        VARCHAR (50)  NULL,
    [ReportId]      INT           NULL,
    [ReportName]    VARCHAR (150) NULL,
    [Active]        BIT           NOT NULL,
    [Created_Date]  DATETIME      NOT NULL,
    [Created_By]    VARCHAR (20)  NOT NULL,
    [Modified_Date] DATETIME      NULL,
    [Modified_By]   VARCHAR (20)  NULL,
    [Approver]      VARCHAR (50)  NULL
);


GO

