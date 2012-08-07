<cfcomponent displayname="ruleProcessor" hint="This component is in charge of evaluating a set of rules">

	<cfset variables.aRules = arrayNew(1)>
	<cfset variables.buglogClient = 0>
	<cfset variables.bugLogListenerEndpoint = "bugLog.listeners.bugLogListenerWS">

	<cffunction name="init" access="public" returntype="ruleProcessor">
		<cfset variables.aRules = arrayNew(1)>
		<cfset variables.buglogClient = createObject("component","bugLog.client.bugLogService").init(variables.bugLogListenerEndpoint)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="addRule" access="public" returnType="void" hint="adds a rule to be processed">
		<cfargument name="rule" type="baseRule" required="true">
		<cfset arrayAppend(variables.aRules, arguments.rule)>
	</cffunction>
	
	<cffunction name="processRules" access="public" returnType="void" hint="Process all rules with a given raw entry bean">
		<cfargument name="rawEntry" type="rawEntryBean" required="true">
		<cfargument name="entry" type="entry" required="true">
		<cfset _processRules("processRule", arguments)>
	</cffunction>
	
	<cffunction name="processQueueStart" access="public" returntype="void" hint="This method gets called BEFORE each processing of the queue (only invoked when using the asynch listener)">
		<cfargument name="queue" type="array" required="true">
		<cfset _processRules("processQueueStart", arguments)>
	</cffunction>

	<cffunction name="processQueueEnd" access="public" returntype="void" hint="This method gets called AFTER each processing of the queue (only invoked when using the asynch listener)">
		<cfargument name="queue" type="array" required="true">
		<cfset _processRules("processQueueEnd", arguments)>
	</cffunction>

	<cffunction name="writeToCFLog" access="private" returntype="void" hint="writes a message to the internal cf logs">
		<cfargument name="message" type="string" required="true">
		<cflog application="true" file="bugLog_ruleProcessor" text="#arguments.message#">
		<cfdump var="BugLog::RuleProcessor: #arguments.message#" output="console">
	</cffunction>


	<cffunction name="_processRules" access="private" returntype="void">
		<cfargument name="method" type="string" required="true">
		<cfargument name="args" type="struct" required="true">
		<cfscript>
			var rtn = false;
			var ruleName = "";
			var thisRule = 0;
			
			for(var i=1;i lte arrayLen(variables.aRules);i=i+1) {
				ruleName = "Rule #i#"; // a temporary name just in case the getMetaData() call fails
				thisRule = variables.aRules[i];
				try {
					ruleName = getMetaData(thisRule).name;
								
					// process rule					
					rtn = invokeRule(thisRule, arguments.method, args);

					// if rule returns false, then that means that no more rules will be processed, so we exit
					if(not rtn) break;

				} catch(any e) {
					// if an error occurs while a rule executes, then write to normal log file
					buglogClient.notifyService("RuleProcessor Error: #e.message#", e);
					writeToCFLog(ruleName & ": " & e.message & e.detail);	
				}
			}
		</cfscript>
	</cffunction>

	<cffunction name="invokeRule" access="private" returntype="boolean">
		<cfargument name="instance" type="any" required="true">
		<cfargument name="method" type="string" required="true">
		<cfargument name="args" type="struct" required="true">
		<cfset var rtn = 0>
		<cfinvoke component="#arguments.instance#" method="#arguments.method#" argumentcollection="#args#" returnvariable="rtn">
		<cfreturn rtn>
	</cffunction>	

</cfcomponent>