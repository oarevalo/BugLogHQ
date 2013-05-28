CREATE TABLE bl_UserApplication (
   userApplicationID INT AUTO_INCREMENT NOT NULL,
   userID INT NOT NULL,
   applicationID INT NOT NULL,
  CONSTRAINT fk_userapplication_user FOREIGN KEY (userID) REFERENCES bl_User (UserID) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_userapplication_application FOREIGN KEY (applicationID) REFERENCES bl_Application (ApplicationID) ON UPDATE CASCADE ON DELETE CASCADE,
  PRIMARY KEY (userApplicationID)
) ENGINE = InnoDB ROW_FORMAT = DEFAULT;

ALTER TABLE bl_User
 ADD apiKey VARCHAR(100) AFTER Email;

 