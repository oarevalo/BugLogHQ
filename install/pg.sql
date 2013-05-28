

SET CONSTRAINTS ALL DEFERRED;

--
-- Definition of table bl_Application
--


DROP TABLE IF EXISTS bl_Application;
CREATE TABLE bl_Application (
  ApplicationID SERIAL,
  Code varchar(100) NOT NULL,
  Name varchar(250) NOT NULL,
  CONSTRAINT bl_Application_pkey PRIMARY KEY (ApplicationID),
  CONSTRAINT bl_Application_Code_unique UNIQUE (Code)
) ;

--
-- Definition of table bl_Host
--

DROP TABLE IF EXISTS bl_Host;
CREATE TABLE bl_Host (
  HostID SERIAL,
  HostName varchar(255) NOT NULL,
  CONSTRAINT bl_Host_pkey PRIMARY KEY (HostID)
) ;

--
-- Definition of table bl_Severity
--

DROP TABLE IF EXISTS bl_Severity;
CREATE TABLE  bl_Severity (
  SeverityID SERIAL,
  Name varchar(250) NOT NULL,
  Code varchar(10) NOT NULL,
  CONSTRAINT bl_Severity_pkey PRIMARY KEY (SeverityID)
) ;


--
-- Definition of table bl_Source
--

DROP TABLE IF EXISTS bl_Source;
CREATE TABLE  bl_Source (
  sourceID SERIAL,
  Name varchar(255) NOT NULL,
  CONSTRAINT bl_Source_pkey PRIMARY KEY ( sourceID )
) ;

--
-- Definition of table bl_Entry
--

DROP TABLE IF EXISTS bl_Entry;
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
);

--
-- Table structure for table bl_User
--

DROP TABLE IF EXISTS bl_User;
CREATE TABLE bl_User (
  UserID SERIAL,
  Username varchar(255) NOT NULL,
  Password varchar(50) NOT NULL,
  IsAdmin INTEGER NOT NULL default 0,
  Email varchar(255) NULL,
  ApiKey varchar(100) NULL,
  CONSTRAINT bl_User_pkey PRIMARY KEY (UserID)
) ;

--
-- Insert data for table bl_User
--

INSERT INTO bl_User (Username,Password,IsAdmin) VALUES ('admin','admin',1);


--
-- Table structure for table bl_Extension
--


DROP TABLE IF EXISTS bl_Extension;
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
) ;


--
-- Table structure for table `bl_ExtensionLog`
--
DROP TABLE IF EXISTS bl_extensionlog;
CREATE TABLE bl_extensionlog (
  extensionLogID SERIAL,
  extensionID INTEGER NOT NULL,
  createdOn TIMESTAMP NOT NULL DEFAULT now(),
  entryID INTEGER NOT NULL,
  CONSTRAINT bl_ExtensionLog_pkey PRIMARY KEY (extensionLogID)
);


--
-- Table structure for table `bl_userApplication`
--
DROP TABLE IF EXISTS bl_UserApplication;
CREATE TABLE bl_UserApplication (
   userApplicationID SERIAL,
   userID INTEGER NOT NULL references bl_User,
   applicationID INTEGER NOT NULL references bl_Application,
  CONSTRAINT bl_UserApplication_pkey PRIMARY KEY (userApplicationID)
);
 
 

