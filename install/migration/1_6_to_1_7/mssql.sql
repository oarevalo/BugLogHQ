CREATE TABLE [dbo].[bl_ExtensionLog] (
		[ExtensionLogID]     int IDENTITY (1,1) NOT NULL,
		[extensionID]       int NULL,
		[createdOn]       datetime NOT NULL,
		[entryID]       int NULL
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[bl_ExtensionLog]
	ADD
	CONSTRAINT [DF_bl_ExtensionLog_createdOn]
	DEFAULT (getdate()) FOR [createdOn]
GO
