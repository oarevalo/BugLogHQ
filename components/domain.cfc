<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.instance.domainId = 0;
		variables.instance.domain = "";
		variables.instance.createdOn = now();
		
		function setDomainId(data) {variables.instance.domainId = arguments.data;}
		function setDomain(data) {variables.instance.domain = arguments.data;}
		function setCreatedOn(data) {variables.instance.createdOn = arguments.data;}
		
		function getDomainId() {return variables.instance.domainId;}
		function getDomain() {return variables.instance.domain;}
		function getCreatedOn() {return variables.instance.createdOn;}

		function getID() {return getDomainId();}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="host">
		<cfargument name="dao" type="bugLog.components.db.hostDAO" required="true">
		<cfset variables.oDAO = arguments.dao>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset variables.instance.ID = getId()>
		<cfset rtn = variables.oDAO.save(argumentCollection = variables.instance)>
		<cfset setDomainId(rtn)>
	</cffunction>

</cfcomponent>