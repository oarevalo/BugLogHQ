<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule checks the amount of messages received on a given timespan and if the number of bugs received is greater than a given threshold, send an email alert">
	
	<cfproperty name="senderEmail" type="string" hint="An email address to use as sender of the email notifications">
	<cfproperty name="recipientEmail" type="string" hint="The email address to which to send the notifications">
	<cfproperty name="count" type="numeric" hint="The number of bugreports that will trigger the rule">
	<cfproperty name="timespan" type="numeric" hint="The number in minutes for which to count the amount of bug reports received">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="senderEmail" type="string" required="true">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="count" type="numeric" required="true">
		<cfargument name="timespan" type="numeric" required="true">
		<cfset variables.config.senderEmail = arguments.senderEmail>
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfset variables.config.count = arguments.count>
		<cfset variables.config.timespan = arguments.timespan>
		<cfset variables.lastEmailTimestamp = createDateTime(1800,1,1,0,0,0)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		
		<cfscript>
			// only evaluate this rule if the amount of timespan minutes has passed after the last email was sent
			if( dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.timespan ) {
			
				oEntryFinder = createObject("component","bugLog.components.entryFinder").init();
	
				qry = oEntryFinder.search(searchTerm = "", 
											startDate = dateAdd("n", variables.config.timespan * (-1), now() ),
											endDate = now()
										);
	
				if(qry.recordCount gt variables.config.count)
					sendEmail();
			
			}
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="sendEmail" access="private" returntype="void">
		<cfmail from="#variables.config.senderEmail#" to="#variables.config.recipientEmail#"
				subject="BugLog: bug frequency alert!!" type="text/html">
			BugLog has received more than #variables.config.count# bug reports 
			on the last #variables.config.timespan# minutes.
			<br><br><br>
			** This email has been sent from the BugLog server at 
			<a href="http://#cgi.HTTP_HOST##cgi.script_name#">http://#cgi.HTTP_HOST##cgi.script_name#</a>
		</cfmail>
		<cfset variables.lastEmailTimestamp = now()>
	</cffunction>

</cfcomponent>