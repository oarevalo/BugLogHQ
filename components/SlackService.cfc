<cfcomponent>

    <cfset variables.endpoint = "">
    <cfset variables.enabled = "">

    <cffunction name="init" access="public" returntype="slackService">
		<cfargument name="configObj" type="config" required="true">
        <cfscript>
            variables.endpoint = arguments.configObj.getSetting("slack.endpoint", variables.endpoint);
            variables.enabled = arguments.configObj.getSetting("slack.enabled", variables.enabled);
            return this;
        </cfscript>
    </cffunction>

	<cffunction name="postIssue" access="public" returntype="void">
		<cfargument name="text">
		<cfset var body = { "text" = arguments.text }>
		<cfset var response  = {}>

		<cfhttp url="#variables.endpoint#" result="response" method="POST" throwonerror="false">
			<cfhttpparam type="header" name="Content-Type" value="application/json">
			<cfhttpparam type="body"  value="#serializeJson(body)#">
		</cfhttp>
	</cffunction>

</cfcomponent>
