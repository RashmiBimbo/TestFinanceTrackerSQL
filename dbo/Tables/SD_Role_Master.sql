CREATE TABLE [dbo].[SD_Role_Master] (
    [Rec_Id]        INT          IDENTITY (1, 1) NOT NULL,
    [Role_Id]       INT          NOT NULL,
    [Role_Name]     VARCHAR (20) NOT NULL,
    [Active]        BIT          CONSTRAINT [DEFAULT_SD_Role_Master_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]  DATETIME     CONSTRAINT [DEFAULT_SD_Role_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]    VARCHAR (20) NOT NULL,
    [Modified_Date] DATETIME     NULL,
    [Modified_By]   VARCHAR (20) NULL,
    CONSTRAINT [PK_SD_Role_Master] PRIMARY KEY CLUSTERED ([Rec_Id] ASC),
    CONSTRAINT [UC_Role_Id] UNIQUE NONCLUSTERED ([Role_Id] ASC),
    CONSTRAINT [UC_Role_Name] UNIQUE NONCLUSTERED ([Role_Name] ASC)
);


GO

