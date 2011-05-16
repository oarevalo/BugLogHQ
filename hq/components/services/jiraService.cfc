<cfcomponent>
	
	<cfset variables.instance = {
									jira = 0,
									configPath = "",
									config = 0
								}>
								
	<cffunction name="init" access="public" returntype="jiraService">
		<cfargument name="config" type="any" required="true">
	
		<cfset variables.instance.config = arguments.config>
		<cfset variables.instance.jira  = createObject("component","bugLog.components.jiraService").init( wsdl = getSetting("wsdl"),
																											username = getSetting("username"),
																											password = getSetting("password") )>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="reinit" access="public" returntype="void">
		<cfset init( variables.instance.config )>
	</cffunction>

	<cffunction name="getProjects" access="public" returntype="array">
		<cfreturn variables.instance.jira.getProjects()>
	</cffunction>

	<cffunction name="getIssueTypes" access="public" returntype="array">
		<cfreturn variables.instance.jira.getIssueTypes()>
	</cffunction>
	
	<cffunction name="createIssue" access="public" returntype="void">
		<cfargument name="project" type="string" required="true">
		<cfargument name="issueType" type="string" required="true">
		<cfargument name="summary" type="string" required="true">
		<cfargument name="description" type="string" required="true">
		<cfreturn variables.instance.jira.createIssue(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getSetting" returnType="string" access="public" hint="Returns the given config setting, if doesnt exist, returns empty or default value">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="defaultValue" type="string" required="false" default="">
		<cfreturn variables.instance.config.getSetting("jira." & arguments.settingName, arguments.defaultValue)>
	</cffunction>
	
	<cffunction name="setSetting" returntype="jiraService" access="public">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="settingValue" type="string" required="true">
		<cfset variables.instance.config.setSetting("jira." & arguments.settingName, arguments.settingValue)>
		<cfreturn this>
	</cffunction>

</cfcomponent>