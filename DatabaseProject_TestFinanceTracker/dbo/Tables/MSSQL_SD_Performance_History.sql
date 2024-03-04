CREATE TABLE [dbo].[MSSQL_SD_Performance_History] (
    [Rec_ID]          BIGINT         NOT NULL,
    [User_Id]         VARCHAR (50)   NOT NULL,
    [Report_Id]       INT            NOT NULL,
    [Report_Type]     CHAR (10)      NULL,
    [Add_Date]        DATE           NOT NULL,
    [Month_From_Date] DATE           NULL,
    [Month_To_Date]   DATE           NULL,
    [Month_Week_No]   INT            NULL,
    [Location]        NVARCHAR (MAX) NULL,
    [Submit_Date]     DATE           NULL,
    [Approve_Date]    DATE           NULL,
    [Active]          BIT            NOT NULL,
    [Created_Date]    DATETIME       NOT NULL,
    [Created_By]      VARCHAR (20)   NOT NULL,
    [Modified_Date]   DATETIME       NULL,
    [Modified_By]     VARCHAR (20)   NULL,
    [SysStartTime]    DATETIME2 (7)  NOT NULL,
    [SysEndTime]      DATETIME2 (7)  NOT NULL
);


GO

