CREATE TABLE [dbo].[SD_Location_Master] (
    [Rec_Id]        INT            IDENTITY (1, 1) NOT NULL,
    [Loc_Id]        VARCHAR (20)   NOT NULL,
    [Loc_Name]      VARCHAR (50)   NOT NULL,
    [Company_Id]    VARCHAR (20)   NOT NULL,
    [Address]       NVARCHAR (MAX) NULL,
    [Zone]          VARCHAR (50)   NULL,
    [Active]        BIT            CONSTRAINT [DEFAULT_SD_Location_Master_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]  DATETIME       CONSTRAINT [DEFAULT_SD_Location_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]    VARCHAR (20)   NOT NULL,
    [Modified_Date] DATETIME       NULL,
    [Modified_By]   VARCHAR (20)   NULL,
    CONSTRAINT [PK_SD_Location_Master] PRIMARY KEY CLUSTERED ([Rec_Id] ASC),
    CONSTRAINT [UC_Loc_Id] UNIQUE NONCLUSTERED ([Loc_Id] ASC),
    CONSTRAINT [UC_Loc_Name] UNIQUE NONCLUSTERED ([Loc_Name] ASC)
);


GO

