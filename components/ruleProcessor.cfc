<cfcomponent displayname="ruleProcessor" hint="This component is in charge of evaluating a set of rules">

	<cfset variables.aRules = arrayNew(1)>

	<cffunction name="init" access="public" returntype="ruleProcessor">
		<cfset variables.aRules = arrayNew(1)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="addRule" access="public" returnType="void" hint="adds a rule to be processed">
		<cfargument name="rule" type="baseRule" required="true">
		<cfset arrayAppend(variables.aRules, arguments.rule)>
	</cffunction>
	
	<cffunction name="processRules" access="public" returnType="void" hint="Process all rules with a given raw entry bean">
		<cfargument name="rawEntry" type="rawEntryBean" required="true">
		<cfargument name="dataProvider" type="bugLog.components.lib.dao.dataProvider" required="true">
		
		<cfscript>
			for(i=1;i lte arrayLen(variables.aRules);i=i+1) {
				try {
					// process rule with current entry bean					
					rtn = variables.aRules[i].processRule(arguments.rawEntry, arguments.dataProvider);

					// if rule returns false, then that means that no more rules will be processed, so we exit
					if(not rtn) break;

				} catch(any e) {
					// if an error occurs while a rule executes, then write to normal log file
					writeToCFLog(e.message & e.detail);	
				}
			}
		</cfscript>
	</cffunction>
	

	<cffunction name="writeToCFLog" access="private" returntype="void" hint="writes a message to the internal cf logs">
		<cfargument name="message" type="string" required="true">
		<cflog application="true" file="bugLog_ruleProcessor" text="#arguments.message#">
	</cffunction>

</cfcomponent>