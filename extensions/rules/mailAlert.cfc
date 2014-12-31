<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule sends an email everytime a bug matching a given set of conditions is received">

	<cfproperty name="recipientEmail" type="string" buglogType="email" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="severity" type="string" buglogType="severity" displayName="Severity Code" hint="The severity code (fatal,critical,error,etc) that will trigger the rule. Leave empty to look for all severity codes">
	<cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" displayName="Host Name" buglogType="host" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="keywords" type="string" displayName="Keywords" hint="A list of keywords that will trigger the rule. The keywords are searched within the bug message text">
	<cfproperty name="includeHTMLReport" type="boolean" displayName="Include HTML Report?" hint="When enabled, the HTML Report section of the bug report is included in the email body">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="keywords" type="string" required="false" default="">
		<cfargument name="includeHTMLReport" type="string" required="false" default="">
		<cfscript>
			arguments.includeHTMLReport = (isBoolean(arguments.includeHTMLReport) && arguments.includeHTMLReport);
			super.init(argumentCollection = arguments);
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="matchCondition" access="public" returntype="boolean" hint="Returns true if the entry bean matches a custom condition">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var stEntry = arguments.entry.getMemento();
			var matches = !(arrayLen(listToArray(variables.config.keywords)) > 0);

			for(var keyword in listToArray(variables.config.keywords)) {
				matches = matches || findNoCase(keyword, stEntry.message);
			}
			return matches;
		</cfscript>
	</cffunction>

	<cffunction name="doAction" access="public" returntype="boolean" hint="Performs an action when the entry matches the scope and conditions">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			sendToEmail(entry = arguments.entry, 
						recipient = variables.config.recipientEmail,
						subject = "BugLog: #arguments.entry.getMessage()#",
						comment = getAlertMessage(),
						entryID = arguments.entry.getEntryID(),
						includeHTMLReport = variables.config.includeHTMLReport);
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="explain" access="public" returntype="string">
		<cfset var rtn = "Sends an alert ">
		<cfif variables.config.recipientEmail  neq "">
			<cfset rtn &= " to <b>#variables.config.recipientEmail#</b>">
		</cfif>
		<cfset rtn &= " when receiving a bug report">
		<cfif variables.config.application  neq "">
			<cfset rtn &= " from application <b>#variables.config.application#</b>">
		</cfif>
		<cfif variables.config.host neq "">
			<cfset rtn &= " on host <b>#variables.config.host#</b> ">
		</cfif>
		<cfif variables.config.severity  neq "">
			<cfset rtn &= " with a severity of <b>#variables.config.severity#</b>">
		</cfif>
		<cfif variables.config.keywords  neq "">
			<cfset var tmpKeywordsList = listQualify(variables.config.keywords,"'")>
			<cfset rtn &= " containing any of the following keywords <b>#tmpKeywordsList#</b>">
		</cfif>
		<cfreturn rtn>
	</cffunction>	

	<cffunction name="getAlertMessage" type="string" access="private">
		<cfset var msg = "BugLog has received a new bug report">
		<cfif variables.config.application neq "">
			<cfset msg &= " from application <b>#variables.config.application#</b>">
		</cfif>
		<cfif variables.config.severity neq "">
			<cfset msg &= " with severity code <b>#variables.config.severity#</b>">
		</cfif>
		<cfif variables.config.host neq "">
			<cfset msg &= " on host <b>#variables.config.host#</b>">
		</cfif>
		<cfif variables.config.keywords  neq "">
			<cfset var tmpKeywordsList = listQualify(variables.config.keywords,"'")>
			<cfset msg &= " containing any of the following keywords <b>#tmpKeywordsList#</b>">
		</cfif>
		<cfreturn msg>
	</cffunction>
	
</cfcomponent>
