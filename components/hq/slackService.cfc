<cfcomponent>

	<cfset variables.instance = {
		slack = 0,
		endpoint = "",
		enabled = 0
	}>

	<cffunction name="init" access="public" returntype="slackService">
		<cfargument name="appService" type="any" required="true">

		<cfset variables.instance.app = arguments.appService>
		<cfset variables.instance.slack = createObject("component","bugLog.components.slackService").init(
			variables.instance.app.getConfig()
		)>
		<cfreturn this>
	</cffunction>

	<cffunction name="reinit" access="public" returntype="void">
		<cfset init( variables.instance.app )>
	</cffunction>

	<cffunction name="postIssue" access="public" returntype="void">
		<cfargument name="text" type="string" required="true">
		<cfset variables.instance.slack.postIssue(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="getSetting" returnType="string" access="public" hint="Returns the given config setting, if doesnt exist, returns empty or default value">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="defaultValue" type="string" required="false" default="">
		<cfreturn variables.instance.app.getConfig().getSetting("slack." & arguments.settingName, arguments.defaultValue)>
	</cffunction>

	<cffunction name="setSetting" returntype="slackService" access="public">
		<cfargument name="settingName" type="string" required="true">
		<cfargument name="settingValue" type="string" required="true">
		<cfset variables.instance.app.getConfig().setSetting("slack." & arguments.settingName, arguments.settingValue)>
		<cfreturn this>
	</cffunction>

</cfcomponent>