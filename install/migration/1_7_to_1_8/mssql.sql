CREATE TABLE [dbo].[bl_userApplication] (
		[userApplicationID]     int IDENTITY (1,1) NOT NULL,
		[userID]       int NULL,
		[applicationID]       int NULL
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[bl_userApplication]
	ADD
	CONSTRAINT [FK_bl_userApplication_bl_user]
	FOREIGN KEY ([userID]) REFERENCES [dbo].[bl_User] ([userID])
GO

ALTER TABLE [dbo].[bl_userApplication]
	ADD
	CONSTRAINT [FK_bl_userApplication_bl_application]
	FOREIGN KEY ([applicationID]) REFERENCES [dbo].[bl_application] ([applicationID])
GO


ALTER TABLE [bl_User] ADD COLUMN apiKey VARCHAR(100) NULL;
GO