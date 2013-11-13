<cfcomponent extends="bugLog.components.baseRule" 
			hint="This rule sends an email everytime a bug matching a given set of conditions is received">

	<cfproperty name="recipientEmail" type="string" buglogType="email" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="severityCode" type="string" buglogType="severity" displayName="Severity Code" hint="The severity code (fatal,critical,error,etc) that will trigger the rule. Leave empty to look for all severity codes">
	<cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
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
		<cfargument name="entry" type="bugLog.components.entry" required="true">
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

			for(var i=1;i lte listLen(variables.config.keywords);i=i+1) {
				evalCond3 = evalCond3 and findNoCase(listGetAt(variables.config.keywords,i), stEntry.message);
				if(not evalCond3) break;
			}

			// if all conditions are met, then send the alert
			if(evalCond1 and evalCond2 and evalCond3) {
				logTrigger(entry);
				sendToEmail(rawEntryBean = arguments.rawEntry, 
							recipient = variables.config.recipientEmail,
							subject = "BugLog: #arguments.rawEntry.getMessage()#",
							comment = getAlertMessage(),
							entryID = arguments.entry.getEntryID());
				
				writeToCFLog("'MailAlertRule' rule fired. Email sent. Msg: '#arguments.rawEntry.getMessage()#'");
			}
				
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
		<cfif variables.config.severityCode  neq "">
			<cfset rtn &= " with a severity of <b>#variables.config.severityCode#</b>">
		</cfif>
		<cfif variables.config.keywords  neq "">
			<cfset var tmpKeywordsList = listQualify(variables.config.keywords,"'")>
			<cfset rtn &= " containing any of the following keywords <b>#tmpKeywordsList#</b>">
		</cfif>
		<cfreturn rtn>
	</cffunction>	

	<cffunction name="getAlertMessage" type="string" access="private">
		<cfset var msg = "BugLog has received a bug report">
		<cfif variables.config.application neq "">
			<cfset msg &= " from application <b>#variables.config.application#</b>">
		</cfif>
		<cfif variables.config.severityCode neq "">
			<cfset msg &= " with severity code <b>#variables.config.severityCode#</b>">
		</cfif>
		<cfif variables.config.keywords  neq "">
			<cfset var tmpKeywordsList = listQualify(variables.config.keywords,"'")>
			<cfset msg &= " containing any of the following keywords <b>#tmpKeywordsList#</b>">
		</cfif>
		<cfreturn msg>
	</cffunction>
	
</cfcomponent>