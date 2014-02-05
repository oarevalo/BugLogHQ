<cfcomponent extends="bugLog.components.baseRule" 
			displayName="Discard message"
			hint="This rule removes items from the queue that matches the given parameters">

	<cfproperty name="severityCode" type="string" buglogType="severity" displayName="Severity Code" hint="The severity code (fatal,critical,error,etc) that will trigger the rule. Leave empty to look for all severity codes">
	<cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" displayName="Host Name" buglogType="host" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="message" type="string" displayName="Message" hint="The text of the bug report message">
	<cfproperty name="text" type="string" displayName="Text" hint="The text to search within the bug report contents">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="severityCode" type="string" required="false" default="">
		<cfargument name="application" type="string" required="false" default="">
		<cfargument name="host" type="string" required="false" default="">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="text" type="string" required="false" default="">
		<cfset variables.config.severityCode = trim(arguments.severityCode)>
		<cfset variables.config.application = trim(arguments.application)>
		<cfset variables.config.host = trim(arguments.host)>
		<cfset variables.config.message = trim(arguments.message)>
		<cfset variables.config.text = trim(arguments.text)>
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
			var alltext = item.getMessage() & item.getExceptionMessage() & item.getExceptionDetails() & item.getHTMLReport();
			var rtn = (config.application eq "" or (config.application neq "" and listFindNoCase(config.application, item.getApplicationCode())))
							and
							(config.severityCode eq "" or (config.severityCode neq "" and listFindNoCase(config.severityCode, item.getSeverityCode())))
							and
							(config.host eq "" or (config.host neq "" and listFindNoCase(config.host, item.getHostName())))
							and
							(config.message eq "" or (config.message neq "" and listFindNoCase(config.message, item.getMessage())))
							and
							(config.text eq "" or (config.text neq "" and findNoCase(config.text, alltext)));
			
			 return rtn;
		</cfscript>
	</cffunction>
	
	<cffunction name="explain" access="public" returntype="string">
		<cfset var rtn = "Discards any bug report received">
		<cfif variables.config.application  neq "">
			<cfset rtn &= " from application <b>#variables.config.application#</b>">
		</cfif>
		<cfif variables.config.severityCode  neq "">
			<cfset rtn &= " with a severity of <b>#variables.config.severityCode#</b>">
		</cfif>
		<cfif variables.config.host  neq "">
			<cfset rtn &= " from host <b>#variables.config.host#</b>">
		</cfif>
		<cfif variables.config.message  neq "">
			<cfset rtn &= " with message <b>'#htmlEditFormat(variables.config.message)#'</b>">
		</cfif>
		<cfif variables.config.text  neq "">
			<cfset rtn &= " containing the text <b>'#htmlEditFormat(variables.config.text)#'</b>">
		</cfif>
		<cfreturn rtn>
	</cffunction>

</cfcomponent>
	