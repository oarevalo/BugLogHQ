<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule sends an email everytime a bug is received">

	<cfproperty name="recipientEmail" buglogType="email" displayName="Recipient Email" type="string" hint="The email address to which to send the notifications">
	<cfproperty name="includeHTMLReport" type="boolean" displayName="Include HTML Report?" hint="When enabled, the HTML Report section of the bug report is included in the email body">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="includeHTMLReport" type="string" required="false" default="">
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfset variables.config.includeHTMLReport = (isBoolean(arguments.includeHTMLReport) and arguments.includeHTMLReport)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfset logTrigger(entry)>
		<cfset sendToEmail(rawEntryBean = arguments.rawEntry, 
							recipient = variables.config.recipientEmail,
							subject = "BugLog: #arguments.rawEntry.getMessage()#",
							entryId = arguments.entry.getEntryId(),
							includeHTMLReport = variables.config.includeHTMLReport)>
							
		<cfset writeToCFLog("'mailRelay' rule fired. Email sent. Msg: '#arguments.rawEntry.getMessage()#'")>
		<cfreturn true>
	</cffunction>

	<cffunction name="explain" access="public" returntype="string">
		<cfset var rtn = "Sends an alert ">
		<cfif variables.config.recipientEmail  neq "">
			<cfset rtn &= " to <b>#variables.config.recipientEmail#</b>">
		</cfif>
		<cfset rtn &= " every time a bug report is received">
		<cfreturn rtn>
	</cffunction>
</cfcomponent>