USE [bugloghq]

GO

IF (NOT EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Domain]')))
	BEGIN	
		CREATE TABLE [dbo].[bl_Domain] (
				[DomainID]     int IDENTITY (1,1) NOT NULL,
				[domain]       varchar(512) NULL,
				[createdOn]    datetime NOT NULL
		)
		ON [PRIMARY]
	END

GO

-- Add Primary Key PK_bl_ExtensionLog to bl_DomainId
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Domain]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'PK_bl_Domain' AND [object_id]=OBJECT_ID(N'[dbo].[bl_Domain]')))
	BEGIN
		Print 'Add Primary Key PK_bl_Domain to bl_DomainId'
		ALTER TABLE [dbo].[bl_Domain]
			ADD
			CONSTRAINT [PK_bl_Domain]
			PRIMARY KEY
			([DomainID])
			ON [PRIMARY]
	END
GO

IF (NOT EXISTS(SELECT * FROM sys.columns WHERE Name = 'domainId' and Object_ID = Object_ID('bl_Entry')))
	BEGIN
		ALTER TABLE [bl_Entry]
			ADD domainId INT NULL
	END
	
