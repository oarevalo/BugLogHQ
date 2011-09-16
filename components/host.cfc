<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.instance.hostID = 0;
		variables.instance.hostName = "";
		variables.instance.environmentID = 0;
		variables.instance.clusterID = 0;
		
		function setHostID(data) {variables.instance.hostID = arguments.data;}
		function setHostName(data) {variables.instance.hostName = arguments.data;}
		
		function getHostID() {return variables.instance.hostID;}
		function getHostName() {return variables.instance.hostName;}

		function getID() {return getHostID();}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="host">
		<cfargument name="dao" type="bugLog.components.db.hostDAO" required="true">
		<cfset variables.oDAO = arguments.dao>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset variables.instance.ID = variables.instance.hostID>
		<cfset rtn = variables.oDAO.save(argumentCollection = variables.instance)>
		<cfset variables.instance.hostID = rtn>
	</cffunction>

</cfcomponent>