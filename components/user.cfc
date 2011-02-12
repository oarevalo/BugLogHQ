<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.instance.ID = 0;
		variables.instance.username = "";
		variables.instance.password = "";
		variables.instance.isAdmin = 0;
		variables.instance.email = "";
		
		function setUserID(data) {variables.instance.ID = arguments.data;}
		function setUsername(data) {variables.instance.username = arguments.data;}
		function setPassword(data) {variables.instance.password = arguments.data;}
		function setIsAdmin(data) {variables.instance.isAdmin = arguments.data;}
		function setEmail(data) {variables.instance.email = arguments.data;}
		
		function getUserID() {return variables.instance.ID;}
		function getUsername() {return variables.instance.username;}
		function getPassword() {return variables.instance.password;}
		function getIsAdmin() {return variables.instance.isAdmin;}
		function getEmail() {return variables.instance.email;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="user">
		<cfargument name="dao" type="bugLog.components.db.userDAO" required="true">
		<cfset variables.oDAO = arguments.dao>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(argumentCollection = variables.instance)>
		<cfset variables.instance.ID = rtn>
	</cffunction>

</cfcomponent>