<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule sends an email everytime a bug is received">

	<cfproperty name="recipientEmail" buglogType="email" displayName="Recipient Email" type="string" hint="The email address to which to send the notifications">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfset sendToEmail(rawEntryBean = arguments.rawEntry, 
							recipient = variables.config.recipientEmail,
							subject = "BugLog: #arguments.rawEntry.getMessage()#")>
		<cfset writeToCFLog("'mailRelay' rule fired. Email sent. Msg: '#arguments.rawEntry.getMessage()#'")>
		<cfreturn true>
	</cffunction>

</cfcomponent>