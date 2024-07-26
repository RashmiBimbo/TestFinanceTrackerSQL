CREATE TABLE [dbo].[MSSQL_SD_Login_Master_History] (
    [Rec_Id]               BIGINT         NOT NULL,
    [User_Id]              VARCHAR (50)   NOT NULL,
    [Password]             VARCHAR (MAX)  NOT NULL,
    [User_Name]            VARCHAR (250)  NOT NULL,
    [Company_Id]           VARCHAR (10)   NULL,
    [Sub_Company_Id]       VARCHAR (10)   NULL,
    [Role_Id]              INT            NOT NULL,
    [Email]                NVARCHAR (320) NULL,
    [Login_Type]           CHAR (1)       NULL,
    [Active]               BIT            NOT NULL,
    [Flag]                 BIT            NOT NULL,
    [Change_Password_Date] DATE           NULL,
    [Address]              VARCHAR (MAX)  NULL,
    [IP_Address]           VARCHAR (30)   NULL,
    [Location_Id]          VARCHAR (20)   NULL,
    [Created_Date]         DATETIME       NOT NULL,
    [Created_By]           VARCHAR (250)  NOT NULL,
    [Modified_Date]        DATETIME       NULL,
    [Modified_By]          VARCHAR (250)  NULL,
    [SysStartTime]         DATETIME2 (7)  NOT NULL,
    [SysEndTime]           DATETIME2 (7)  NOT NULL
);


GO

CREATE CLUSTERED INDEX [ix_MSSQL_SD_Login_Master_History]
    ON [dbo].[MSSQL_SD_Login_Master_History]([SysEndTime] ASC, [SysStartTime] ASC) WITH (DATA_COMPRESSION = PAGE);


GO

