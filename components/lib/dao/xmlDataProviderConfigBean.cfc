<cfcomponent extends="configBean">
	
	<cfproperty name="dataRoot" type="string" required="false" default="">
	
	<cffunction name="init" access="public" returntype="xmlDataProviderConfigBean">
		<cfscript>
			variables.instance = structNew();
			variables.instance.dataRoot = "";
		</cfscript>
		<cfreturn this>
	</cffunction>

	<cffunction name="getDataRoot" returntype="string" access="public">
		<cfreturn getProperty("dataRoot")>
	</cffunction>


	<cffunction name="setDataRoot" returntype="void" access="public">
		<cfargument name="data" type="string" required="true">
		<cfset setProperty("dataRoot", arguments.data)>
	</cffunction>

</cfcomponent>