<cfcomponent>
	
	<cfset variables.CONFIG_TYPE = "xml">
	
	<cffunction name="init" access="public" returntype="configFactory">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getConfig" access="public" returntype="config">
		<cfargument name="instance" type="string" required="false" default="">
		<cfset var config = 0>
		<cfswitch expression="#variables.CONFIG_TYPE#">
			<cfcase value="xml">
				<cfset config = getXMLConfig(instance)>
			</cfcase>
			<cfdefaultcase>
				<cfthrow message="Unkown config type">
			</cfdefaultcase>
		</cfswitch>
		<cfreturn config>
	</cffunction>
	
	
	<!--- Private Methods --->

	<cffunction name="getXMLConfig" access="private" returntype="config">
		<cfargument name="instance" type="string" required="false" default="">
		
		<cfif instance eq "" or instance eq "default">
			<cfset instance = "bugLog">
		</cfif>
		
		<cfset var config = createObject("component","config")
										.init(
												configProviderType = "xml",
												configDoc = "/#instance#/config/buglog-config.xml.cfm"
											) />
		<cfreturn config>
	</cffunction>
	
</cfcomponent>