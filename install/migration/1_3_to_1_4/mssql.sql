ALTER TABLE [bl_User] ADD COLUMN IsAdmin INT NOT NULL;

UPDATE [bl_User] SET IsAdmin = 1;
