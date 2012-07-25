<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.instance.ID = 0;
		variables.instance.name = "";
		
		function setSourceID(data) {variables.instance.ID = arguments.data;}
		function setName(data) {variables.instance.name = arguments.data;}
		
		function getSourceID() {return variables.instance.ID;}
		function getName() {return variables.instance.name;}

		function getID() {return variables.instance.ID;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="source">
		<cfargument name="dao" type="bugLog.components.db.sourceDAO" required="true">
		<cfset variables.oDAO = arguments.dao>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(argumentCollection = variables.instance)>
		<cfset variables.instance.ID = rtn>
	</cffunction>

</cfcomponent>