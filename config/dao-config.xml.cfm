<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<!-- define data provider type:
		db: standard datasource
		xml: xml storage (file-based)
	 -->
	<dataProviderType>db</dataProviderType>

	<!-- this is the path to where the DAOs for the application are stored -->
	<clientDAOPath>bugLog.components.db.</clientDAOPath>

	<properties>
		<!-- xml storage -->
		<property name="dataRoot" value="/bugLog/data/" />
		

		<!-- database storage -->
		<property name="dsn" value="bugLog" />
		<property name="dbtype" value="mysql" />
		<property name="username" value="" />
		<property name="password" value="" />
		
	</properties>
</config>