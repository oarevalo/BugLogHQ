<cfcomponent output="false">
	
	<cfset this.name = "bugLogMobile">
	<cfset this.sessionManagement = true> 

	<cffunction name="onRequestStart" output="false">
		<cfargument name="pageName" type="string" required="false" default="">
		
		<!--- initialize app service --->
		<cfif not structKeyExists(application,"appService") or structKeyExists(url,"resetApp")>
			<cflock type="exclusive" name="buglogmobile_init" timeout="10">
				<cfset application.appService = createObject("component","bugLog.components.hq.appService").init()>
			</cflock>
		</cfif>	
		
		<!--- get the full url path to buglog --->
		<cfset request.fullBugLogHQPath = createObject("component","bugLog.components.util").getBugLogHQAssetsHREF(application.appService.getConfig())>

	</cffunction>
	 
</cfcomponent>