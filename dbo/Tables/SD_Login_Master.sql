CREATE TABLE [dbo].[SD_Login_Master] (
    [Rec_Id]               BIGINT                                      IDENTITY (1, 1) NOT NULL,
    [User_Id]              VARCHAR (50)                                NOT NULL,
    [Password]             VARCHAR (MAX)                               NOT NULL,
    [User_Name]            VARCHAR (250)                               NOT NULL,
    [Company_Id]           VARCHAR (10)                                NULL,
    [Sub_Company_Id]       VARCHAR (10)                                NULL,
    [Role_Id]              INT                                         NOT NULL,
    [Email]                NVARCHAR (320)                              NOT NULL,
    [Location_Id]          VARCHAR (20)                                NULL,
    [Login_Type]           CHAR (1)                                    NULL,
    [Active]               BIT                                         CONSTRAINT [DEFAULT_SD_Login_Master_Active] DEFAULT ((1)) NOT NULL,
    [Flag]                 BIT                                         CONSTRAINT [DEFAULT_SD_Login_Master_Flag] DEFAULT ((1)) NOT NULL,
    [Change_Password_Date] DATE                                        NULL,
    [Changed_Password]     BIT                                         CONSTRAINT [DEFAULT_SD_Login_Master_Changed_Password] DEFAULT ((0)) NOT NULL,
    [Address]              VARCHAR (MAX)                               NULL,
    [IP_Address]           VARCHAR (30)                                NULL,
    [Created_Date]         DATETIME                                    CONSTRAINT [DEFAULT_SD_Login_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]           VARCHAR (250)                               NOT NULL,
    [Modified_Date]        DATETIME                                    NULL,
    [Modified_By]          VARCHAR (250)                               NULL,
    [SysStartTime]         DATETIME2 (7) GENERATED ALWAYS AS ROW START NOT NULL,
    [SysEndTime]           DATETIME2 (7) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_SD_Login_Master] PRIMARY KEY CLUSTERED ([Rec_Id] ASC),
    CONSTRAINT [FK_SD_Login_Master_SD_Location_Master] FOREIGN KEY ([Location_Id]) REFERENCES [dbo].[SD_Location_Master] ([Loc_Id]),
    CONSTRAINT [FK_SD_Login_Master_SD_Role_Master] FOREIGN KEY ([Role_Id]) REFERENCES [dbo].[SD_Role_Master] ([Role_Id]),
    CONSTRAINT [UQ_User_Id_SD_Login_Master] UNIQUE NONCLUSTERED ([User_Id] ASC),
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
);


GO

