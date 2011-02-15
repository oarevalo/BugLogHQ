<cfcomponent>
	
	<cfset variables.instance = {
									wsdl = "",
									username = "",
									password = "",
									jiraws = 0
								}>
								
	<cffunction name="init" access="public" returntype="jiraService">
		<cfargument name="wsdl" required="true" type="string">
		<cfargument name="username" required="true" type="string">
		<cfargument name="password" required="true" type="string">
		<cfset variables.instance.wsdl = arguments.wsdl>
		<cfset variables.instance.username = arguments.username>
		<cfset variables.instance.password = arguments.password>
		<cfscript>
			if(left(variables.instance.wsdl,1) eq "/") {
				if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
				thisHost = thisHost & cgi.server_name;
				if(cgi.server_port neq 80) thisHost = thisHost & ":" & cgi.server_port;
				variables.instance.wsdl = thisHost & variables.instance.wsdl;
			}
		</cfscript>
		<cfreturn this>
	</cffunction>

	<cffunction name="getProjects" access="public" returntype="array">
		<cfset var token = getAuthToken()>
		<cfset var ws = variables.instance.jiraws>
		<cfreturn ws.getProjectsNoSchemes(token)>
	</cffunction>

	<cffunction name="getIssueTypes" access="public" returntype="array">
		<cfset var ws = variables.instance.jiraws>
		<cfset var token = getAuthToken()>
		<cfreturn ws.getIssueTypes(token)>
	</cffunction>
	
	<cffunction name="createIssue" access="public" returntype="void">
		<cfargument name="project" type="string" required="true">
		<cfargument name="issueType" type="string" required="true">
		<cfargument name="summary" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfset var ws = variables.instance.jiraws>
		<cfset var token = getAuthToken()>
		<cfset var remoteIssue = structNew()>
		
		<cfset remoteIssue.project = arguments.project>
		<cfset remoteIssue.summary = arguments.summary>
		<cfset remoteIssue.type = arguments.issueType>
		<cfset remoteIssue.description = arguments.description>
		
		<cfset ws.createIssue(token, remoteIssue)>
	</cffunction>

	<cffunction name="getAuthToken" access="private" returntype="string">
		<cfset variables.instance.jiraws = createObject("webservice",variables.instance.wsdl)>
		<cfreturn variables.instance.jiraws.login(variables.instance.username, variables.instance.password)>
	</cffunction>

</cfcomponent>