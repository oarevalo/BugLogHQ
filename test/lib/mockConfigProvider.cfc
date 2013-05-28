<cfcomponent hint="i simulate a config provider">
	
	<cfset this.config = {}>
	
	<cffunction name="init" access="public" returntype="mockConfigProvider">
		<cfreturn this>
	</cffunction>

	<cffunction name="load" access="public" returntype="struct">
		<cfreturn this.config>
	</cffunction>

	<cffunction name="save" access="public" returntype="void">
		<cfargument name="config" type="any" required="true">
		<cfset this.config = arguments.config>
	</cffunction>

	<cffunction name="getConfigKey" access="public" returntype="string">
		<cfreturn  "test" />
	</cffunction>
	
</cfcomponent>