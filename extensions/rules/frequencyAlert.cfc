<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule checks the amount of messages received on a given timespan and if the number of bugs received is greater than a given threshold, send an email alert">

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
			if( dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.count ) {
			
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
		</cfmail>
		<cfset variables.lastEmailTimestamp = now()>
	</cffunction>

</cfcomponent>