<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule sends an email everytime a bug matching a given set of conditions is received">

	<cfproperty name="recipientEmail" type="string" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="severityCode" type="string" displayName="Severity Code" hint="The severity code (fatal,critical,error,etc) that will trigger the rule. Leave empty to look for all severity codes">
	<cfproperty name="application" type="string" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="keywords" type="string" displayName="Keywords" hint="A list of keywords that will trigger the rule. The keywords are searched within the bug message text">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="severityCode" type="string" required="false" default="">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="keywords" type="string" required="false" default="">
		<cfset variables.config.recipientEmail = arguments.recipientEmail>
		<cfset variables.config.severityCode = trim(arguments.severityCode)>
		<cfset variables.config.application = trim(arguments.application)>
		<cfset variables.config.keywords = trim(arguments.keywords)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		<cfargument name="configObj" type="bugLog.components.config" required="true">
		<cfscript>
			var stEntry = arguments.rawEntry.getMemento();
			var evalCond1 = true;
			var evalCond2 = true;
			var evalCond3 = true;
			var i = 0;

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
			if(evalCond1 and evalCond2 and evalCond3) {
				sendToEmail(rawEntryBean = arguments.rawEntry, 
							sender = arguments.configObj.getSetting("general.adminEmail"),
							recipient = variables.config.recipientEmail,
							subject = "BugLog: #arguments.rawEntry.getMessage()#",
							comment = "This message has been sent because the following bug report matched the given criteria. To review or modify the criteria please log into the bugLog server and go into the Rules section.");
				
				writeToCFLog("MailAlertRule. Rule fired. Email sent.");
			}
				
			return true;
		</cfscript>
	</cffunction>

</cfcomponent>