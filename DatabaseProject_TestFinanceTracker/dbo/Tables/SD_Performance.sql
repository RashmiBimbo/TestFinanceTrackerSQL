CREATE TABLE [dbo].[SD_Performance] (
    [Rec_ID]          BIGINT                                      IDENTITY (1, 1) NOT NULL,
    [User_Id]         VARCHAR (50)                                NOT NULL,
    [Report_Id]       INT                                         NOT NULL,
    [Report_Type]     VARCHAR (50)                                NULL,
    [Add_Date]        DATE                                        CONSTRAINT [DEFAULT_SD_Performance_Submit_Date] DEFAULT (getdate()) NOT NULL,
    [Month_From_Date] DATE                                        NULL,
    [Month_To_Date]   DATE                                        NULL,
    [Month_Week_No]   INT                                         CONSTRAINT [DEFAULT_SD_Performance_Month_Week_No] DEFAULT ((0)) NULL,
    [Year_Quarter_No] INT                                         CONSTRAINT [DEFAULT_SD_Performance_Year_Quarter_No] DEFAULT ((0)) NULL,
    [Year_Half_No]    INT                                         CONSTRAINT [DEFAULT_SD_Performance_Year_Half_No] DEFAULT ((0)) NULL,
    [Location]        NVARCHAR (MAX)                              NULL,
    [Submit_Date]     DATE                                        NULL,
    [Approve_Date]    DATE                                        NULL,
    [Comments]        VARCHAR (1000)                              NULL,
    [Active]          BIT                                         CONSTRAINT [DEFAULT_SD_Performance_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]    DATETIME                                    CONSTRAINT [DEFAULT_SD_Performance_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]      VARCHAR (20)                                NOT NULL,
    [Modified_Date]   DATETIME                                    NULL,
    [Modified_By]     VARCHAR (20)                                NULL,
    [SysStartTime]    DATETIME2 (7) GENERATED ALWAYS AS ROW START NOT NULL,
    [SysEndTime]      DATETIME2 (7) GENERATED ALWAYS AS ROW END   NOT NULL,
    CONSTRAINT [PK_SD_Performance] PRIMARY KEY CLUSTERED ([Rec_ID] ASC),
    CONSTRAINT [FK_SD_Performance_SD_Login_Master] FOREIGN KEY ([User_Id]) REFERENCES [dbo].[SD_Login_Master] ([User_Id]),
    CONSTRAINT [FK_SD_Performance_SD_Reports_Master] FOREIGN KEY ([Report_Id]) REFERENCES [dbo].[SD_Reports_Master] ([Rec_ID]),
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[MSSQL_SD_Performance_History], DATA_CONSISTENCY_CHECK=ON));


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This table will have the data of the reports submitted by the plants, corporate and other users.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SD_Performance';


GO



ALTER TABLE [dbo].[SD_Performance]
    ADD CONSTRAINT [DEFAULT_SD_Performance_Year_Quarter_No] DEFAULT ((0)) FOR [Year_Quarter_No];
GO

