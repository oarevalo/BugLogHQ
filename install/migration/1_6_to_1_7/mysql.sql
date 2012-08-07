CREATE TABLE `bl_extensionlog` (
  `extensionLogID` int(11) NOT NULL AUTO_INCREMENT,
  `extensionID` int(11) NOT NULL,
  `createdOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `entryID` int(11) NOT NULL,
  PRIMARY KEY (`extensionLogID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

