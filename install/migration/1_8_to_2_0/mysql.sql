ALTER TABLE `bl_Entry` 
ADD COLUMN `UUID` VARCHAR(50) NULL,
ADD COLUMN `updatedOn` DATETIME NULL,
ADD COLUMN `isProcessed` TINYINT NOT NULL DEFAULT 0,
ADD INDEX `IX_Entry_isProcessed` (`isProcessed` ASC),
ADD INDEX `IX_Entry_UUID` (`UUID` ASC);

UPDATE `bl_Entry` 
SET isProcessed = 1;

