CREATE TABLE [dbo].[SD_Category_Master] (
    [Rec_Id]           INT          IDENTITY (1, 1) NOT NULL,
    [Category_Name]    VARCHAR (50) NOT NULL,
    [Category_Type_Id] INT          NOT NULL,
    [Active]           BIT          CONSTRAINT [DEFAULT_SD_Category_Master_Active] DEFAULT ((1)) NOT NULL,
    [Created_Date]     DATETIME     CONSTRAINT [DEFAULT_SD_Category_Master_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Created_By]       VARCHAR (20) NOT NULL,
    [Modified_Date]    DATETIME     NULL,
    [Modified_By]      VARCHAR (20) NULL,
    CONSTRAINT [PK_SD_Category_Master] PRIMARY KEY CLUSTERED ([Rec_Id] ASC),
    CONSTRAINT [FK_SD_Category_Master_SD_Category_Type_Master] FOREIGN KEY ([Category_Type_Id]) REFERENCES [dbo].[SD_Category_Type_Master] ([Rec_Id]),
    CONSTRAINT [UQ_Name_SD_Category_Master] UNIQUE NONCLUSTERED ([Category_Name] ASC)
);


GO

