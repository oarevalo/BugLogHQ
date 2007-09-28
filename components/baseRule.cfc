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
		<!--- this method must be implemented by rules that extend the base rule --->
		<cfreturn true>
	</cffunction>

</cfcomponent>