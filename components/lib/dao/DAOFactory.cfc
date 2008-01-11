<cfcomponent>

	<cfset variables.oDataProvider = 0>
	<cfset variables.clientDAOPath = "">
	<cfset variables.dpType = "db">

	<cffunction name="init" access="public" returntype="DAOFactory">
		<cfargument name="configDocPath" type="string" required="true">
		<cfscript>
			var oConfigBean = 0;
			var xmlDoc = 0;
			var i = 0;
			var aNodes = 0;

			// read dao configuration
			xmlDoc = xmlParse(arguments.configDocPath);

			// get path to client dao objects
			if(structKeyExists( xmlDoc.xmlRoot, "clientDAOPath"))
				variables.clientDAOPath = xmlDoc.xmlRoot.clientDAOPath.xmlText;

			// get type of data provider
			variables.dpType = xmlDoc.xmlRoot.dataProviderType.xmlText;

			// create dataProvider config bean
			oConfigBean = createObject("component", variables.dpType & "DataProviderConfigBean").init();

			// setup bean
			aNodes = xmlDoc.xmlRoot.properties.xmlChildren;
			
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				oConfigBean.setProperty(aNodes[i].xmlAttributes.name, 
										aNodes[i].xmlAttributes.value);
			}
			
			// initialize dataProvider
			variables.oDataProvider = createObject("component", variables.dpType & "DataProvider").init(oConfigBean);

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getDAO" access="public" returntype="DAO" hint="returns a properly configured instance of a DAO">
		<cfargument name="entity" type="string" required="true">
		
		<cfset var oDAO = createObject("component",variables.clientDAOPath & arguments.entity & "DAO")>
		<cfset oDAO.init(variables.oDataProvider)>
		
		<cfreturn oDAO>
	</cffunction>

	<cffunction name="getDataProvider" access="public" returntype="dataProvider" hint="returns an instance of the dataProvider used">
		<cfreturn variables.oDataProvider>
	</cffunction>
</cfcomponent>