<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule sends an email everytime a bug matching a given set of conditions is received">

	<cfproperty name="senderEmail" type="string" hint="An email address to use as sender of the email notifications">
	<cfproperty name="recipientEmail" type="string" hint="The email address to which to send the notifications">
	<cfproperty name="severityCode" type="string" hint="The severity code (fatal,critical,error,etc) that will trigger the rule. Leave empty to look for all severity codes">
	<cfproperty name="application" type="string" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="keywords" type="string" hint="A list of keywords that will trigger the rule. The keywords are searched within the bug message text">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="senderEmail" type="string" required="true">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="severityCode" type="string" required="true">
		<cfargument name="application" type="string" required="true">
		<cfargument name="keywords" type="string" required="true">
		<cfset variables.config.senderEmail = arguments.senderEmail>
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfset variables.config.severityCode = trim(arguments.severityCode)>
		<cfset variables.config.application = trim(arguments.application)>
		<cfset variables.config.keywords = trim(arguments.keywords)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		
		<cfscript>
			var stEntry = arguments.rawEntry.getMemento();
			var evalCond1 = true;
			var evalCond2 = true;
			var evalCond3 = true;

			// evaluate conditions
			evalCond1 = (variables.config.application eq "")
						or (variables.config.application neq "" and stEntry.applicationCode eq variables.config.application);
						
			evalCond2 = (variables.config.severityCode eq "")
						or (variables.config.severityCode neq "" and stEntry.severityCode eq variables.config.severityCode);

			for(i=1;i lte listLen(variables.config.keywords);i=i+1) {
				evalCond3 = evalCond3 and findNoCase(listGetAt(variables.config.keywords,i), stEntry.message);
				if(not evalCond3) break;
			}

			// if all conditions are met, then send the alert
			if(evalCond1 and evalCond2 and evalCond3)
				sendEmail(arguments.rawEntry);
				
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="sendEmail" access="private" returntype="void">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfmail from="#variables.config.senderEmail#" to="#variables.config.recipientEmail#"
				subject="BugLog: bug received" type="text/html">
			<cfdump var="#arguments.rawEntry.getMemento()#" label="Bug Info">
			<cfdump var="#variables.config#" label="Rule Criteria">
		</cfmail>
	</cffunction>


</cfcomponent>