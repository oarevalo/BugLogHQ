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
 
 ALTER TABLE bl_User ADD COLUMN apiKey VARCHAR(100) NULL;
