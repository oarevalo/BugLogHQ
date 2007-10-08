<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule sends an email everytime a bug is received">

	<cfproperty name="senderEmail" type="string" hint="An email address to use as sender of the email notifications">
	<cfproperty name="recipientEmail" type="string" hint="The email address to which to send the notifications">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="senderEmail" type="string" required="true">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfset variables.config.senderEmail = arguments.senderEmail>
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		
		<cfset sendToEmail(rawEntryBean = arguments.rawEntry, 
							sender = variables.config.senderEmail,
							recipient = variables.config.recipientEmail,
							subject = "BugLog: #arguments.rawEntry.getMessage()#")>
		
		<cfreturn true>
	</cffunction>

</cfcomponent>