-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.0.27-standard


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Definition of table `bl_Application`
--

DROP TABLE IF EXISTS `bl_Application`;
CREATE TABLE  `bl_Application` (
  `ApplicationID` int(11) NOT NULL auto_increment,
  `Code` varchar(100) NOT NULL,
  `Name` varchar(250) NOT NULL COMMENT '\n',
  PRIMARY KEY  (`ApplicationID`),
  UNIQUE KEY `Code` (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Definition of table `bl_Host`
--

DROP TABLE IF EXISTS `bl_Host`;
CREATE TABLE `bl_Host` (
  `HostID` int(11) NOT NULL auto_increment,
  `HostName` varchar(255) NOT NULL,
  PRIMARY KEY  (`HostID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Definition of table `bl_Severity`
--

DROP TABLE IF EXISTS `bl_Severity`;
CREATE TABLE  `bl_Severity` (
  `SeverityID` int(11) NOT NULL auto_increment,
  `Name` varchar(250) NOT NULL COMMENT '\n',
  `Code` varchar(10) NOT NULL,
  PRIMARY KEY  (`SeverityID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Definition of table `bl_Source`
--

DROP TABLE IF EXISTS `bl_Source`;
CREATE TABLE  `bl_Source` (
  `sourceID` int(11) NOT NULL auto_increment,
  `Name` varchar(255) NOT NULL,
  PRIMARY KEY  (`sourceID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `bl_Source`
--

/*!40000 ALTER TABLE `bl_Source` DISABLE KEYS */;
LOCK TABLES `bl_Source` WRITE;
INSERT INTO `bl_Source` VALUES  (1,'WebService'),
 (2,'Post');
UNLOCK TABLES;
/*!40000 ALTER TABLE `bl_Source` ENABLE KEYS */;



--
-- Definition of table `bl_Entry`
--

DROP TABLE IF EXISTS `bl_Entry`;
CREATE TABLE `bl_Entry` (
  `EntryID` int(11) NOT NULL auto_increment,
  `myDateTime` datetime NOT NULL COMMENT '\n',
  `Message` varchar(500) NOT NULL,
  `ApplicationID` int(11) NOT NULL COMMENT '\n',
  `SourceID` int(11) NOT NULL,
  `SeverityID` int(11) NOT NULL COMMENT '\n',
  `HostID` int(11) NOT NULL,
  `exceptionMessage` varchar(500) default NULL,
  `exceptionDetails` varchar(5000) default NULL COMMENT '\n',
  `CFID` varchar(255) default NULL COMMENT '\n',
  `CFTOKEN` varchar(255) default NULL COMMENT '\n',
  `UserAgent` varchar(500) default NULL COMMENT '\n',
  `TemplatePath` varchar(500) default NULL COMMENT '\n',
  `HTMLReport` longtext,
  `createdOn` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`EntryID`),
  KEY `FK_Entry_ApplicationID` (`ApplicationID`),
  KEY `FK_Entry_SourceID` (`SourceID`),
  KEY `FK_Entry_SeverityID` (`SeverityID`),
  KEY `FK_Entry_HostID` (`HostID`),
  CONSTRAINT `FK_Entry_HostID` FOREIGN KEY (`HostID`) REFERENCES `bl_Host` (`HostID`),
  CONSTRAINT `FK_Entry_SeverityID` FOREIGN KEY (`SeverityID`) REFERENCES `bl_Severity` (`SeverityID`),
  CONSTRAINT `FK_Entry_SourceID` FOREIGN KEY (`SourceID`) REFERENCES `bl_Source` (`sourceID`),
  CONSTRAINT `FK_Entry_ApplicationID` FOREIGN KEY (`ApplicationID`) REFERENCES `bl_Application` (`ApplicationID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `bl_User`
--

DROP TABLE IF EXISTS `bl_User`;
CREATE TABLE `bl_User` (
  `UserID` int(11) NOT NULL auto_increment,
  `Username` varchar(255) NOT NULL COMMENT '\n',
  `Password` varchar(50) NOT NULL COMMENT '\n',
  PRIMARY KEY  (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `bl_User`
--

LOCK TABLES `bl_User` WRITE;
/*!40000 ALTER TABLE `bl_User` DISABLE KEYS */;
INSERT INTO `bl_User` VALUES (1,'admin','admin');
/*!40000 ALTER TABLE `bl_User` ENABLE KEYS */;
UNLOCK TABLES;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
