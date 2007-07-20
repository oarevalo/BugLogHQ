<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.applicationID = 0;
		variables.name = "";
		variables.code = 0;
		
		function setApplicationID(data) {variables.applicationID = arguments.data;}
		function setName(data) {variables.name = arguments.data;}
		function setCode(data) {variables.code = arguments.data;}
		
		function getApplicationID() {return variables.applicationID;}
		function getName() {return variables.name;}
		function getCode() {return variables.code;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="app">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("application")>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(variables.applicationID, variables.code, variables.name)>
		<cfset variables.applicationID = rtn>
	</cffunction>

</cfcomponent>