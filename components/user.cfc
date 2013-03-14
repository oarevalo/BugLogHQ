<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.instance.ID = 0;
		variables.instance.username = "";
		variables.instance.password = "";
		variables.instance.isAdmin = 0;
		variables.instance.email = "";
		variables.instance.apiKey = "";
		variables.apps = [];
		
		function setUserID(data) {variables.instance.ID = arguments.data;}
		function setUsername(data) {variables.instance.username = arguments.data;}
		function setPassword(data) {variables.instance.password = arguments.data;}
		function setIsAdmin(data) {variables.instance.isAdmin = arguments.data;}
		function setEmail(data) {variables.instance.email = arguments.data;}
		function setAPIKey(data) {variables.instance.apiKey = arguments.data;}
		function setAllowedApplications(data) {variables.apps = arguments.data;}
		
		function getUserID() {return variables.instance.ID;}
		function getUsername() {return variables.instance.username;}
		function getPassword() {return variables.instance.password;}
		function getIsAdmin() {return variables.instance.isAdmin;}
		function getEmail() {return variables.instance.email;}
		function getAPIKey() {return  variables.instance.apiKey;}
		function getAllowedApplications() {return  variables.apps;}

		function getID() {return variables.instance.ID;}
		
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

	<cffunction name="isApplicationAllowed" access="public" returntype="boolean">
		<cfargument name="app" type="any" required="true" hint="applicationID or application object">
		<cfscript>
			var appID = isNumeric(arguments.app) ? arguments.app : arguments.app.getApplicationID();
			if(getIsAdmin()) return true;
			for(var i=1;i lte arrayLen(apps);i++) {
				if(apps[i].getApplicationID() eq appID) {
					return true;
				}
			}
			return false;
		</cfscript>
	</cffunction>

</cfcomponent>