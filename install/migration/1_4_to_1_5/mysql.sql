DROP TABLE IF EXISTS `bl_Extension`;
CREATE TABLE `bl_Extension` (
  `ExtensionID` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `enabled` int(11) NOT NULL default 0,
  `description` varchar(500) NULL,
  `properties` longtext NULL,
  `createdBy` int(11) NULL,
  `createdOn` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`ExtensionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

ALTER TABLE bl_User
 ADD Email VARCHAR(255) NULL AFTER IsAdmin;
