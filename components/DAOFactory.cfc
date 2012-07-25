<cfcomponent>

	<cffunction name="init" access="public" returntype="bugLog.components.lib.dao.DAOFactory">
		<cfargument name="configObj" type="config" required="true">
		<cfscript>
			var oConfigBean = 0;
			var oDataProvider = 0;
			var oDAOFactory = 0;

			// create dataProvider config bean
			oConfigBean = createObject("component", "bugLog.components.lib.dao.dbDataProviderConfigBean").init();

			// setup bean
			oConfigBean.setProperty("dsn", arguments.configObj.getSetting("db.dsn","bugLog"));
			oConfigBean.setProperty("dbtype", arguments.configObj.getSetting("db.dbtype","mysql"));
			oConfigBean.setProperty("username", arguments.configObj.getSetting("db.username",""));
			oConfigBean.setProperty("password", arguments.configObj.getSetting("db.password",""));
	
			// initialize dataProvider
			oDataProvider = createObject("component", "bugLog.components.lib.dao.dbDataProvider").init(oConfigBean);
			
			// create the real factory
			oDAOFactory = createObject("component","bugLog.components.lib.dao.DAOFactory").init();
			oDAOFactory.setClientDAOPath("bugLog.components.db.");
			oDAOFactory.setDataProvider(oDataProvider);

			return oDAOFactory;
		</cfscript>
	</cffunction>

</cfcomponent>