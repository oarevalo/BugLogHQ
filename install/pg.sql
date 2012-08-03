
CREATE TABLE bl_Application (
  ApplicationID SERIAL,
  Code varchar(100) NOT NULL,
  Name varchar(250) NOT NULL,
  CONSTRAINT bl_Application_pkey PRIMARY KEY (ApplicationID),
  CONSTRAINT bl_Application_Code_unique UNIQUE (Code)
)

CREATE TABLE bl_Host (
  HostID SERIAL,
  HostName varchar(255) NOT NULL,
  CONSTRAINT bl_Host_pkey PRIMARY KEY (HostID)
)

CREATE TABLE  bl_Severity (
  SeverityID SERIAL,
  Name varchar(250) NOT NULL,
  Code varchar(10) NOT NULL,
  CONSTRAINT bl_Severity_pkey PRIMARY KEY (SeverityID)
)

CREATE TABLE  bl_Source (
  sourceID SERIAL,
  Name varchar(255) NOT NULL,
  CONSTRAINT bl_Source_pkey PRIMARY KEY (sourceID)
)

CREATE TABLE bl_Entry (
  EntryID SERIAL,
  myDateTime TIMESTAMP NOT NULL,
  Message varchar(500) NOT NULL,
  ApplicationID int4 NOT NULL references bl_Application,
  SourceID int4 NOT NULL references bl_Source,
  SeverityID int4 NOT NULL references bl_Severity,
  HostID int4 NOT NULL references bl_Host,
  exceptionMessage varchar(500) default NULL,
  exceptionDetails TEXT default NULL,
  CFID varchar(255) default NULL,
  CFTOKEN varchar(255) default NULL,
  UserAgent varchar(500) default NULL,
  TemplatePath varchar(500) default NULL,
  HTMLReport TEXT,
  createdOn TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT bl_Entry_pkey PRIMARY KEY (EntryID)
) 

CREATE TABLE bl_User (
  UserID SERIAL,
  Username varchar(255) NOT NULL,
  Password varchar(50) NOT NULL,
  IsAdmin INTEGER NOT NULL default 0,
  Email varchar(255) NULL,
  CONSTRAINT bl_User_pkey PRIMARY KEY (UserID)
) 

INSERT INTO bl_User (UserID,Username,Password,IsAdmin) VALUES (1,'admin','admin',1);


CREATE TABLE bl_Extension (
  ExtensionID SERIAL,
  name varchar(255) NOT NULL,
  type varchar(255) NOT NULL,
  enabled INTEGER NOT NULL default 0,
  description varchar(500) NULL,
  properties TEXT NULL,
  createdBy INTEGER NULL,
  createdOn TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT bl_Extension_pkey PRIMARY KEY (ExtensionID)
)
