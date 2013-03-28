CREATE TABLE bl_userApplication (
   userApplicationID INT AUTO_INCREMENT NOT NULL,
   userID INT NOT NULL,
   applicationID INT NOT NULL,
  CONSTRAINT fk_userapplication_user FOREIGN KEY (userID) REFERENCES bl_user (UserID) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_userapplication_application FOREIGN KEY (applicationID) REFERENCES bl_application (ApplicationID) ON UPDATE CASCADE ON DELETE CASCADE,
  PRIMARY KEY (userApplicationID)
) ENGINE = InnoDB ROW_FORMAT = DEFAULT;

ALTER TABLE bl_user
 ADD apiKey VARCHAR(100) AFTER Email;

 