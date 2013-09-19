<cfcomponent>
	
	<cfset variables.instance = {
									jira = 0,
									configPath = "",
									config = 0
								}>
								
	<cffunction name="init" access="public" returntype="jiraService">
		<cfargument name="appService" type="any" required="true">
	
		<cfset variables.instance.app = arguments.appService>
		<cfset variables.instance.jira  = createObject("component","bugLog.components.jiraService").init( 
																											getSetting("endpoint"),
																											getSetting("username"),
																											getSetting("password") )>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="reinit" access="public" returntype="void">
		<cfset init( variables.instance.app )>
	</cffunction>

	<cffunction name="getProjects" access="public" returntype="array">
		<cfreturn variables.instance.jira.getProjects()>
	</cffunction>

	<cffunction name="getProject" access="public" returntype="struct">
		<cfargument name="projectKey" type="string" required="true">
		<cfreturn variables.instance.jira.getProject(arguments.projectKey)>
	</cffunction>

	<cffunction name="getIssueTypes" access="public" returntype="array">
		<cfargument name="projectKey" type="string" required="false" default="">
		<cfreturn variables.instance.jira.getIssueTypes(arguments.projectKey)>
	</cffunction>
	
	<cffunction name="createIssue" access="public" returntype="struct">
		<cfargument name="project" type="string" required="true">
		<cfargument name="issueType" type="string" required="true">
		<cfargument name="summary" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfreturn variables.instance.jira.createIssue(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getSetting" returnType="string" access="public" hint="Returns the given config setting, if doesnt exist, returns empty or default value">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="defaultValue" type="string" required="false" default="">
		<cfreturn variables.instance.app.getConfig().getSetting("jira." & arguments.settingName, arguments.defaultValue)>
	</cffunction>
	
	<cffunction name="setSetting" returntype="jiraService" access="public">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="settingValue" type="string" required="true">
		<cfset variables.instance.app.getConfig().setSetting("jira." & arguments.settingName, arguments.settingValue)>
		<cfreturn this>
	</cffunction>

</cfcomponent>