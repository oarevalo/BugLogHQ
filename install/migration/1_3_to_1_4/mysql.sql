ALTER TABLE `bl_User` ADD COLUMN IsAdmin int(11) NOT NULL default 0;

UPDATE bl_User SET IsAdmin = 1;
