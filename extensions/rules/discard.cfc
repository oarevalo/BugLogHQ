<cfcomponent extends="bugLog.components.baseRule" 
			displayName="Discard message"
			hint="This rule removes items from the queue that matches the given parameters">

	<cfproperty name="severity" type="string" buglogType="severity" displayName="Severity Code" hint="The severity code (fatal,critical,error,etc) that will trigger the rule. Leave empty to look for all severity codes">
	<cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
	<cfproperty name="host" type="string" displayName="Host Name" buglogType="host" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
	<cfproperty name="message" type="string" displayName="Message" hint="The text of the bug report message">
	<cfproperty name="text" type="string" displayName="Text" hint="The text to search within the bug report contents">

	<cffunction name="init" access="public" returntype="bugLog.components.baseRule">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="text" type="string" required="false" default="">
		<cfscript>
			arguments.message = trim(arguments.message);
			arguments.text = trim(arguments.text);
			super.init(argumentCollection = arguments);
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="matchCondition" access="public" returntype="boolean" hint="Returns true if the entry bean matches a custom condition">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var alltext = entry.getMessage() & entry.getExceptionMessage() & entry.getExceptionDetails() & entry.getHTMLReport();
			var rtn = (config.message eq "" or (config.message neq "" and listFindNoCase(config.message, entry.getMessage())))
						and
						(config.text eq "" or (config.text neq "" and findNoCase(config.text, alltext)));
			 return rtn;
		</cfscript>
	</cffunction>

	<cffunction name="doAction" access="public" returntype="boolean" hint="Performs an action when the entry matches the scope and conditions">
		<cfargument name="entry" type="bugLog.components.entry" required="true">
		<cfscript>
			var oEntryDAO = getDAOFactory().getDAO("entry");
			oEntryDAO.delete( entry.getEntryID() );
			return false;
		</cfscript>
	</cffunction>

	<cffunction name="explain" access="public" returntype="string">
		<cfset var rtn = "Discards any bug report received">
		<cfif variables.config.application  neq "">
			<cfset rtn &= " from application <b>#variables.config.application#</b>">
		</cfif>
		<cfif variables.config.severity  neq "">
			<cfset rtn &= " with a severity of <b>#variables.config.severity#</b>">
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
	
