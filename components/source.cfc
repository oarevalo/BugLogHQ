<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.sourceID = 0;
		variables.name = "";
		
		function setSourceID(data) {variables.sourceID = arguments.data;}
		function setName(data) {variables.name = arguments.data;}
		
		function getSourceID() {return variables.sourceID;}
		function getName() {return variables.name;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="source">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("source")>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(variables.sourceID, variables.name)>
		<cfset variables.sourceID = rtn>
	</cffunction>

</cfcomponent>