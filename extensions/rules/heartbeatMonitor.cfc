<cfcomponent extends="bugLog.components.baseRule" 
			displayName="Heartbeat Monitor"
			hint="This rule checks if we have received a matching message in X minutes. If not, an alert is sent.">

	<cfproperty name="recipientEmail" type="string" buglogType="email" displayName="Recipient Email" hint="The email address to which to send the notifications">
	<cfproperty name="timespan" type="numeric" displayName="Timespan" hint="The number in minutes to wait for a matching message">
	<cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" buglogType="host" displayName="Host Name" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="severity" type="string" buglogType="severity" displayName="Severity Code" hint="The severity that will trigger the rule. Leave empty to look for all severities">
	<cfproperty name="alertInterval" type="numeric" displayName="Alert Interval" hint="The number of minutes to wait between alert messages">

	<cfset variables.lastEmailTimestamp = createDateTime(1800,1,1,0,0,0)>

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="recipientEmail" type="string" required="true">
		<cfargument name="timespan" type="string" required="true">
		<cfargument name="alertInterval" type="string" required="false" default="">
		<cfscript>
			arguments.timespan = max(val(arguments.timespan),1);
			arguments.alertInterval = max(val(arguments.alertInterval),1);
			super.init(argumentCollection = arguments);
			return this;
		</cfscript>		
	</cffunction>

	<cffunction name="processQueueEnd" access="public" returntype="void" hint="This method gets called AFTER each processing of the queue">
		<cfargument name="queue" type="array" required="true">
		<cfscript>
			var matches = false;
			var oEntryDAO = getDAOFactory().getDAO("entry");
			var oEntryFinder = createObject("component","bugLog.components.entryFinder").init(oEntryDAO);

			// only evaluate this rule if 'alertInterval' minutes has passed after the last email was sent
			if( dateDiff("n", variables.lastEmailTimestamp, now()) gt variables.config.alertInterval ) {

				var args = {
					startDate = dateAdd("n", variables.config.timespan * (-1), now() ),
					endDate = now()
				};

				for(var key in structKeyArray(scope)) {
					var ids = [];
					for(var item in scope[key]["items"]) {
						ids.add( scope[key]["items"][item] );
					}
					if(arrayLen(ids)) {
						args[key & "id"] = (scope[key]["not_in"] ? "-" : "") & listToArray(ids)
					}
				}

				var qry = oEntryFinder.search(argumentCollection = args);

				if(qry.recordCount == 0) {
					sendEmail();
					variables.lastEmailTimestamp = now();
				}

			}
		</cfscript>	
	</cffunction>

	<cffunction name="matchCondition" access="public" returntype="boolean" hint="Returns true if the entry bean matches a custom condition">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfreturn false />		
	</cffunction>

	<cffunction name="doAction" access="public" returntype="boolean" hint="Performs an action when the entry matches the scope and conditions">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			sendEmail();
			variables.lastEmailTimestamp = now();
			return true;
		</cfscript>
	</cffunction>

	<cffunction name="sendEmail" access="private" returntype="void" output="true">
		
		<cfset var numHours = int(variables.config.timespan / 60)>
		<cfset var numMinutes = variables.config.timespan mod 60>
		
		<cfsavecontent variable="intro">
			<cfoutput>
				BugLog has <b>NOT</b> received a report 
				<cfif variables.config.application neq "">
					for application <strong>#variables.config.application#</strong>
				</cfif>
				<cfif variables.config.host neq "">
					on host <strong>#variables.config.host#</strong>
				</cfif>
				<cfif variables.config.severity neq "">
					with a severity of <strong>#variables.config.severity#</strong>
				</cfif>
				on the last 
				<b>
					<cfif numHours gt 0> #numHours# hour<cfif numHours gt 1>s</cfif> <cfif numMinutes gt 0> and </cfif></cfif>
					<cfif numMinutes gt 0> #numMinutes# minute<cfif numMinutes gt 1>s</cfif></cfif>
				</b>
				<br />
				It is possible that the monitored application is not functioning correctly.
				<br />
			</cfoutput>
		</cfsavecontent>			
		
		<cfset sendToEmail(recipient = variables.config.recipientEmail,
							subject= "BugLog: [Heartbeat Monitor Alert][#variables.config.application#][#variables.config.host#]", 
							comment = intro)>
		
		<cfset writeToCFLog("'heartbeatMonitor' rule fired. Email sent. [#variables.config.application#][#variables.config.host#]")>
	</cffunction>

	<cffunction name="explain" access="public" returntype="string">
		<cfset var rtn = "Sends an alert ">
		<cfif variables.config.recipientEmail  neq "">
			<cfset rtn &= " to <b>#variables.config.recipientEmail#</b>">
		</cfif>
		<cfset rtn &= " when BugLog has NOT received a bug report ">
		<cfif variables.config.timespan  neq "">
			<cfset rtn &= " within the last <b>#variables.config.timespan#</b> minutes">
		</cfif>
		<cfif variables.config.application  neq "">
			<cfset rtn &= " from application <b>#variables.config.application#</b>">
		</cfif>
		<cfif variables.config.severity  neq "">
			<cfset rtn &= " with a severity of <b>#variables.config.severity#</b>">
		</cfif>
		<cfif variables.config.host  neq "">
			<cfset rtn &= " from host <b>#variables.config.host#</b>">
		</cfif>
		<cfif variables.config.alertInterval neq "">
			<cfset rtn &= ". Alerts will be re-sent every <b>#variables.config.alertInterval#</b> minutes thereafter until a mathing report is received.">
		</cfif>
		<cfreturn rtn>
	</cffunction>
			
</cfcomponent>
