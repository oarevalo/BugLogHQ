<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.userID = 0;
		variables.username = "";
		variables.password = "";
		
		function setUserID(data) {variables.userID = arguments.data;}
		function setUsername(data) {variables.username = arguments.data;}
		function setPassword(data) {variables.password = arguments.data;}
		
		function getUserID() {return variables.userID;}
		function getUsername() {return variables.username;}
		function getPassword() {return variables.password;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="user">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("user")>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(variables.userID, variables.username, variables.password)>
		<cfset variables.userID = rtn>
	</cffunction>

</cfcomponent>