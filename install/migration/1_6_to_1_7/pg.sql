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

