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
		
		<cfmail from="#variables.config.senderEmail#" to="#variables.config.recipientEmail#"
				subject="BugLog: bug received" type="text/html">
			The following bug has just been received:<br><br>
			<cfdump var="#arguments.rawEntry.getMemento()#">
		</cfmail>
		
		<cfreturn true>
	</cffunction>

</cfcomponent>