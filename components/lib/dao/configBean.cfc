<cfcomponent>
	
	<cffunction name="init" access="public" returntype="configBean">
		<cfset variables.instance = structNew()>
		<cfreturn this>
	</cffunction>

	<cffunction name="getProperty" returntype="string" access="public">
		<cfargument name="name" type="string" required="true">
		<cfif not structKeyExists(variables.instance, arguments.name)>
			<cfthrow message="Property #arguments.name# does not exist" type="dao.configBean.invalidProperty">
		</cfif>
		<cfreturn variables.instance[arguments.name]>
	</cffunction>

	<cffunction name="setProperty" returntype="void" access="public">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfset variables.instance[arguments.name] = arguments.value>
	</cffunction>

	<cffunction name="getMemento" returntype="struct" access="public">
		<cfreturn variables.instance>
	</cffunction>

</cfcomponent>