<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.hostID = 0;
		variables.hostName = "";
		variables.environmentID = 0;
		variables.clusterID = 0;
		
		function setHostID(data) {variables.hostID = arguments.data;}
		function setHostName(data) {variables.hostName = arguments.data;}
		
		function getHostID() {return variables.hostID;}
		function getHostName() {return variables.hostName;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="host">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("host")>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(variables.hostID, variables.hostName)>
		<cfset variables.hostID = rtn>
	</cffunction>

</cfcomponent>