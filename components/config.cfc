<cfcomponent>
	<cfset variables.config = structNew()>
	<cfset variables.configProvider = 0>
	<cfset variables.configProviderType = "">
	
	<cffunction name="init" access="public" returntype="config">
		<cfargument name="configProviderType" type="string" required="true">
		<cfset variables.configProviderType = arguments.configProviderType>
		<cfset variables.configProvider = createObject("component", variables.configProviderType & "ConfigProvider").init(argumentCollection = arguments)>
		<cfset variables.config = variables.configProvider.load()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="reload" access="public" returntype="void" hint="Reloads all config settings">
		<cfset variables.config = variables.configProvider.load()>
	</cffunction>
	
	<cffunction name="getSetting" access="public" returntype="any">
		<cfargument name="name" type="string" required="true">
		<cfargument name="default" type="any" required="false">
		<cfset var rtn = 0>
		<cfif structKeyExists(variables.config, arguments.name)>
			<cfset rtn = variables.config[arguments.name].value>
		<cfelseif structKeyExists(arguments,"default")>
			<cfset rtn = arguments.default>
		<cfelse>
			<cfthrow message="Undefined setting '#arguments.name#'" type="settingNotFound">
		</cfif>
		<cfreturn rtn>
	</cffunction>

	<cffunction name="setSetting" access="public" returntype="config">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="any" required="false">
		<cfset variables.config[arguments.name] = structNew()>
		<cfset variables.config[arguments.name].name = arguments.name>
		<cfset variables.config[arguments.name].value = arguments.value>
		<cfset variables.configProvider.save(variables.config)>
		<cfset variables.config = variables.configProvider.load()>
		<cfreturn this>
	</cffunction>

	<cffunction name="getConfigKey" access="public" returntype="string">
		<cfreturn  variables.configProvider.getConfigKey() />
	</cffunction>
	
</cfcomponent>