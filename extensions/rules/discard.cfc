<cfcomponent extends="bugLog.components.baseRule" 
			displayName="Discard message"
			hint="This rule removes items from the queue that matches the given parameters">

	<cfproperty name="severityCode" type="string" buglogType="severity" displayName="Severity Code" hint="The severity code (fatal,critical,error,etc) that will trigger the rule. Leave empty to look for all severity codes">
	<cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" displayName="Host Name" buglogType="host" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="message" type="string" displayName="Message" hint="The text of the bug report message">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="severityCode" type="string" required="false" default="">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="message" type="string" required="false" default="">
		<cfset variables.config.severityCode = trim(arguments.severityCode)>
		<cfset variables.config.application = trim(arguments.application)>
		<cfset variables.config.host = trim(arguments.host)>
		<cfset variables.config.message = trim(arguments.message)>
		<cfreturn this>
	</cffunction>

	<cffunction name="processQueueStart" access="public" returntype="boolean" hint="This method gets called BEFORE each processing of the queue (only invoked when using the asynch listener)">
		<cfargument name="queue" type="array" required="true">
		<cfscript>
			for(var i=1;i lte arrayLen(queue);i++) {
				if(matches(queue[i])) {
					arrayDeleteat(queue,i);
					i--;
				}
			}
			return true;
		</cfscript>
	</cffunction>
	
	<cffunction name="matches" access="private" returntype="boolean">
		<cfargument name="item" type="any" required="true">
		<cfscript>
			var rtn = (config.application eq "" or (config.application neq "" and listFindNoCase(config.application, item.getApplicationCode())))
							and
							(config.severityCode eq "" or (config.severityCode neq "" and listFindNoCase(config.severityCode, item.getSeverityCode())))
							and
							(config.host eq "" or (config.host neq "" and listFindNoCase(config.host, item.getHostName())))
							and
							(config.message eq "" or (config.message neq "" and listFindNoCase(config.message, item.getMessage())));
			
			 return rtn;
		</cfscript>
	</cffunction>
	
</cfcomponent>
	