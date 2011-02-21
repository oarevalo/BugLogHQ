CREATE TABLE [dbo].[bl_Extension] (
		[ExtensionID]     int IDENTITY (1,1) NOT NULL,
		[name]            varchar(255) NOT NULL,
		[type]            varchar(255) NOT NULL,
		[enabled]         bit NOT NULL,
		[description]     varchar(500) NULL,
		[properties]      text NULL,
		[createdBy]       int NULL,
		[createdOn]       datetime NOT NULL
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[bl_Extension]
	ADD
	CONSTRAINT [DF_bl_Extension_enabled]
	DEFAULT 0 FOR [enabled]
GO

ALTER TABLE [dbo].[bl_Extension]
	ADD
	CONSTRAINT [DF_bl_Extension_createdOn]
	DEFAULT (getdate()) FOR [createdOn]
GO


ALTER TABLE [bl_User] ADD COLUMN email VARCHAR(255) NULL;
GO
