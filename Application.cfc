<cfcomponent>
	
	<cfset this.name = "bugLogHQ">
	<cfset this.sessionManagement = false> 
	
	<!--- create an application mapping to bugLog location --->
	<cfset this.mappings[ "/bugLog" ] = getDirectoryFromPath(getcurrentTemplatePath()) />
	 
</cfcomponent>