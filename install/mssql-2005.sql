-- BEGINNING TRANSACTION STRUCTURE
PRINT 'Beginning transaction STRUCTURE'
BEGIN TRANSACTION _STRUCTURE_
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Table bl_Application
Print 'Create Table bl_Application'
GO
CREATE TABLE [dbo].[bl_Application] (
		[ApplicationID]     int IDENTITY (1,1) NOT NULL,
		[Code]              varchar(100) NOT NULL,
		[Name]              varchar(250) NOT NULL
)
ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Primary Key PK_bl_Application to bl_Application
Print 'Add Primary Key PK_bl_Application to bl_Application'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Application]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'PK_bl_Application' AND [object_id]=OBJECT_ID(N'[dbo].[bl_Application]')))
ALTER TABLE [dbo].[bl_Application]
	ADD
	CONSTRAINT [PK_bl_Application]
	PRIMARY KEY
	([ApplicationID])
	ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Unique IX_bl_Application to bl_Application
Print 'Add Unique IX_bl_Application to bl_Application'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Application]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'IX_bl_Application' AND [object_id]=OBJECT_ID(N'[dbo].[bl_Application]')))
ALTER TABLE [dbo].[bl_Application]
	ADD
	CONSTRAINT [IX_bl_Application]
	UNIQUE
	([Code])
	ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Table bl_Entry
Print 'Create Table bl_Entry'
GO
CREATE TABLE [dbo].[bl_Entry] (
		[EntryID]              int IDENTITY (1,1) NOT NULL,
		[myDateTime]           datetime NOT NULL,
		[Message]              varchar(250) NOT NULL,
		[ApplicationID]        int NOT NULL,
		[SourceID]             int NOT NULL,
		[SeverityID]           int NOT NULL,
		[HostID]               int NOT NULL,
		[ExceptionMessage]     varchar(500) NULL,
		[ExceptionDetails]     varchar(5000) NULL,
		[CFID]                 varchar(255) NULL,
		[CFTOKEN]              varchar(255) NULL,
		[UserAgent]            varchar(500) NULL,
		[TemplatePath]         varchar(500) NULL,
		[HTMLReport]           text NULL,
		[createdOn]            datetime NOT NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Primary Key PK_bl_Entry to bl_Entry
Print 'Add Primary Key PK_bl_Entry to bl_Entry'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Entry]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'PK_bl_Entry' AND [object_id]=OBJECT_ID(N'[dbo].[bl_Entry]')))
ALTER TABLE [dbo].[bl_Entry]
	ADD
	CONSTRAINT [PK_bl_Entry]
	PRIMARY KEY
	([EntryID])
	ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Unique IX_bl_Entry to bl_Entry
Print 'Add Unique IX_bl_Entry to bl_Entry'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Entry]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'IX_bl_Entry' AND [object_id]=OBJECT_ID(N'[dbo].[bl_Entry]')))
ALTER TABLE [dbo].[bl_Entry]
	ADD
	CONSTRAINT [IX_bl_Entry]
	UNIQUE
	([EntryID])
	ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Default Constraint DF_bl_Entry_createdOn to bl_Entry
Print 'Add Default Constraint DF_bl_Entry_createdOn to bl_Entry'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Entry]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.objects WHERE [object_id]=OBJECT_ID(N'[dbo].[DF_bl_Entry_createdOn]') AND [parent_object_id]=OBJECT_ID(N'[dbo].[bl_Entry]')))
ALTER TABLE [dbo].[bl_Entry]
	ADD
	CONSTRAINT [DF_bl_Entry_createdOn]
	DEFAULT (getdate()) FOR [createdOn]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

-- Add Default Constraint DF_bl_Entry_myDateTime to bl_Entry
Print 'Add Default Constraint DF_bl_Entry_myDateTime to bl_Entry'
GO
IF (EXISTS(SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[bl_Entry]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sysobjects WHERE id=OBJECT_ID(N'[dbo].[DF_bl_Entry_createdOn]') AND parent_obj=OBJECT_ID(N'[dbo].[bl_Entry]')))
ALTER TABLE [dbo].[bl_Entry]
	ADD
	CONSTRAINT [DF_bl_Entry_myDateTime]
	DEFAULT (getdate()) FOR [myDateTime]
GO


IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Table bl_Host
Print 'Create Table bl_Host'
GO
CREATE TABLE [dbo].[bl_Host] (
		[HostID]       int IDENTITY (1,1) NOT NULL,
		[HostName]     varchar(250) NOT NULL
)
ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Primary Key PK_bl_Host to bl_Host
Print 'Add Primary Key PK_bl_Host to bl_Host'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Host]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'PK_bl_Host' AND [object_id]=OBJECT_ID(N'[dbo].[bl_Host]')))
ALTER TABLE [dbo].[bl_Host]
	ADD
	CONSTRAINT [PK_bl_Host]
	PRIMARY KEY
	([HostID])
	ON [PRIMARY]
GO


IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Table bl_Severity
Print 'Create Table bl_Severity'
GO
CREATE TABLE [dbo].[bl_Severity] (
		[SeverityID]     int IDENTITY (1,1) NOT NULL,
		[Name]           varchar(250) NOT NULL,
		[Code]           varchar(50) NOT NULL
)
ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Primary Key PK_bl_Severity to bl_Severity
Print 'Add Primary Key PK_bl_Severity to bl_Severity'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Severity]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'PK_bl_Severity' AND [object_id]=OBJECT_ID(N'[dbo].[bl_Severity]')))
ALTER TABLE [dbo].[bl_Severity]
	ADD
	CONSTRAINT [PK_bl_Severity]
	PRIMARY KEY
	([SeverityID])
	ON [PRIMARY]
GO



IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Table bl_Source
Print 'Create Table bl_Source'
GO
CREATE TABLE [dbo].[bl_Source] (
		[SourceID]     int IDENTITY (1,1) NOT NULL,
		[Name]         varchar(250) NOT NULL
)
ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Primary Key PK_bl_Source to bl_Source
Print 'Add Primary Key PK_bl_Source to bl_Source'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_Source]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'PK_bl_Source' AND [object_id]=OBJECT_ID(N'[dbo].[bl_Source]')))
ALTER TABLE [dbo].[bl_Source]
	ADD
	CONSTRAINT [PK_bl_Source]
	PRIMARY KEY
	([SourceID])
	ON [PRIMARY]
GO


IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Table bl_User
Print 'Create Table bl_User'
GO
CREATE TABLE [dbo].[bl_User] (
		[UserID]       int IDENTITY (1,1) NOT NULL,
		[Username]     varchar(250) NOT NULL,
		[Password]     varchar(50) NOT NULL,
		[IsAdmin]	   int NOT NULL,
		[email] 		VARCHAR(255) NULL
)
ON [PRIMARY]
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Add Primary Key PK_bl_User to bl_User
Print 'Add Primary Key PK_bl_User to bl_User'
GO
IF (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[bl_User]') AND [type]='U')) AND NOT (EXISTS (SELECT * FROM sys.indexes WHERE [name]=N'PK_bl_User' AND [object_id]=OBJECT_ID(N'[dbo].[bl_User]')))
ALTER TABLE [dbo].[bl_User]
	ADD
	CONSTRAINT [PK_bl_User]
	PRIMARY KEY
	([UserID])
	ON [PRIMARY]
GO


IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

-- Create Foreign Key FK_bl_Entry_bl_Application on bl_Entry
Print 'Create Foreign Key FK_bl_Entry_bl_Application on bl_Entry'
GO
IF OBJECT_ID(N'[dbo].[bl_Entry]') IS NOT NULL
	AND OBJECT_ID(N'[dbo].[bl_Application]') IS NOT NULL
	AND NOT EXISTS (SELECT * FROM sys.objects WHERE [object_id]=OBJECT_ID(N'[dbo].[FK_bl_Entry_bl_Application]') AND [parent_object_id]=OBJECT_ID(N'[dbo].[bl_Entry]'))
BEGIN
		ALTER TABLE [dbo].[bl_Entry]
			WITH NOCHECK
			ADD CONSTRAINT [FK_bl_Entry_bl_Application]
			FOREIGN KEY ([ApplicationID]) REFERENCES [dbo].[bl_Application] ([ApplicationID])
		ALTER TABLE [dbo].[bl_Entry]
			CHECK CONSTRAINT [FK_bl_Entry_bl_Application]

END
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Foreign Key FK_bl_Entry_bl_Host on bl_Entry
Print 'Create Foreign Key FK_bl_Entry_bl_Host on bl_Entry'
GO
IF OBJECT_ID(N'[dbo].[bl_Entry]') IS NOT NULL
	AND OBJECT_ID(N'[dbo].[bl_Host]') IS NOT NULL
	AND NOT EXISTS (SELECT * FROM sys.objects WHERE [object_id]=OBJECT_ID(N'[dbo].[FK_bl_Entry_bl_Host]') AND [parent_object_id]=OBJECT_ID(N'[dbo].[bl_Entry]'))
BEGIN
		ALTER TABLE [dbo].[bl_Entry]
			ADD CONSTRAINT [FK_bl_Entry_bl_Host]
			FOREIGN KEY ([HostID]) REFERENCES [dbo].[bl_Host] ([HostID])
END
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Foreign Key FK_bl_Entry_bl_Severity on bl_Entry
Print 'Create Foreign Key FK_bl_Entry_bl_Severity on bl_Entry'
GO
IF OBJECT_ID(N'[dbo].[bl_Entry]') IS NOT NULL
	AND OBJECT_ID(N'[dbo].[bl_Severity]') IS NOT NULL
	AND NOT EXISTS (SELECT * FROM sys.objects WHERE [object_id]=OBJECT_ID(N'[dbo].[FK_bl_Entry_bl_Severity]') AND [parent_object_id]=OBJECT_ID(N'[dbo].[bl_Entry]'))
BEGIN
		ALTER TABLE [dbo].[bl_Entry]
			ADD CONSTRAINT [FK_bl_Entry_bl_Severity]
			FOREIGN KEY ([SeverityID]) REFERENCES [dbo].[bl_Severity] ([SeverityID])
END
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO
-- Create Foreign Key FK_bl_Entry_bl_Source on bl_Entry
Print 'Create Foreign Key FK_bl_Entry_bl_Source on bl_Entry'
GO
IF OBJECT_ID(N'[dbo].[bl_Entry]') IS NOT NULL
	AND OBJECT_ID(N'[dbo].[bl_Source]') IS NOT NULL
	AND NOT EXISTS (SELECT * FROM sys.objects WHERE [object_id]=OBJECT_ID(N'[dbo].[FK_bl_Entry_bl_Source]') AND [parent_object_id]=OBJECT_ID(N'[dbo].[bl_Entry]'))
BEGIN
		ALTER TABLE [dbo].[bl_Entry]
			ADD CONSTRAINT [FK_bl_Entry_bl_Source]
			FOREIGN KEY ([SourceID]) REFERENCES [dbo].[bl_Source] ([SourceID])
END
GO

IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
GO

-- COMMITTING TRANSACTION STRUCTURE
PRINT 'Committing transaction STRUCTURE'
IF @@TRANCOUNT>0
	COMMIT TRANSACTION _STRUCTURE_
GO

SET NOEXEC OFF
GO
-- BEGINNING TRANSACTION DATA
PRINT 'Beginning transaction DATA'
BEGIN TRANSACTION _DATA_
GO

SET NOCOUNT ON
GO

-- Deleting from table: bl_User
PRINT 'Deleting from table: bl_User'
DELETE FROM [dbo].[bl_User]

-- Insert scripts for table: bl_User
PRINT 'Inserting rows into table: bl_User'
INSERT INTO [dbo].[bl_User] ([Username], [Password], [IsAdmin]) VALUES ('admin', 'admin', 1)


-- COMMITTING TRANSACTION DATA
PRINT 'Committing transaction DATA'
IF @@TRANCOUNT>0
	COMMIT TRANSACTION _DATA_
GO

SET NOEXEC OFF
GO

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


