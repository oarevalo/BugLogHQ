<cfcomponent displayname="baseRule" hint="This is the base component for any rule. A rule is a process that is evaluated each time a bug arrives and can determine if some actions need to be taken, such as sending an alert via email">

	<!--- the internal config structure is used to store configuration values
			for the current instance of this rule --->
	<cfset variables.config = structNew()>

	<cffunction name="init" access="public" returntype="baseRule">
		<!--- the default behavior is to copy the arguments to the config 
			but this can be overriden if other type of initialization is needed
		--->
		<cfset variables.config = duplicate(arguments)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="processRule" access="public" returnType="boolean"
				hint="This method performs the actual evaluation of the rule. Each rule is evaluated on a rawEntryBean. 
						The method returns a boolean value that can be used by the caller to determine if additional rules
						need to be evaluated.">
		<cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true>
	</cffunction>

	<cffunction name="sendToEmail" access="public" returntype="void">
		<cfargument name="rawEntryBean" type="bugLog.components.rawEntryBean" required="true">
		<cfargument name="sender" type="string" required="true">
		<cfargument name="recipient" type="string" required="true">
		<cfargument name="subject" type="string" required="false" default="BugLog: bug received">
		<cfargument name="comment" type="string" required="false" default="">
		
		<cfset var stEntry = arguments.rawEntryBean.getMemento()>

		<cfmail from="#arguments.sender#" 
				to="#arguments.recipient#" 
				type="html" 
				subject="#arguments.subject#">
			<cfif arguments.comment neq "">
				<div style="font-family:arial;font-size:12px;">
				#arguments.comment#
				</div>
				<hr>
			</cfif>

			<table style="font-family:arial;font-size:12px;">
				<tr>
					<td><b>Date/Time:</b></td>
					<td>#lsDateFormat(stEntry.dateTime)# - #lsTimeFormat(stEntry.dateTime)#</td>
				</tr>
				<tr>
					<td><b>Application:</b></td>
					<td>#stEntry.applicationCode#</td>
				</tr>
				<tr>
					<td><b>Host:</b></td>
					<td>#stEntry.hostName#</td>
				</tr>
				<tr>
					<td><b>Template Path:</b></td>
					<td>#stEntry.templatePath#</td>
				</tr>
				<tr valign="top">
					<td><b>Exception Message:</b></td>
					<td>#stEntry.exceptionMessage#</td>
				</tr>
				<tr valign="top">
					<td><b>Exception Detail:</b></td>
					<td>#stEntry.exceptionDetails#</td>
				</tr>
			</table>			
			
			<hr>
			<br><br><br>
			<div style="font-family:arial;font-size:11px;">
				** This email has been sent automatically from the BugLog server at 
				<a href="http://#cgi.HTTP_HOST#/bugLog/hq">http://#cgi.HTTP_HOST#/bugLog/hq</a><br />
				<em>To disable automatic notifications log into the bugLog server and disable the corresponding rule.</em>
			</div>
		</cfmail>
		
	</cffunction>

	<cffunction name="writeToCFLog" access="private" returntype="void" hint="writes a message to the internal cf logs">
		<cfargument name="message" type="string" required="true">
		<cflog application="true" file="bugLog_ruleProcessor" text="#arguments.message#">
	</cffunction>
	
</cfcomponent>