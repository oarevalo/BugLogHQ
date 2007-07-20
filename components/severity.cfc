<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.severityID = 0;
		variables.name = "";
		variables.code = 0;
		
		function setSeverityID(data) {variables.severityID = arguments.data;}
		function setName(data) {variables.name = arguments.data;}
		function setCode(data) {variables.code = arguments.data;}
		
		function getSeverityID() {return variables.severityID;}
		function getName() {return variables.name;}
		function getCode() {return variables.code;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="severity">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("severity")>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(variables.severityID, variables.code, variables.name)>
		<cfset variables.severityID = rtn>
	</cffunction>

</cfcomponent>