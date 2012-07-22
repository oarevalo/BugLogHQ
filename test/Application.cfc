<cfcomponent>

	<cfset this.name = "BugLogListenerTest">
	<cfset this.clientManagement = false> 
	<cfset this.sessionManagement = false> 

	<!--- create an application mapping to bugLog location --->
	<cfset this.rootDir = replace(getDirectoryFromPath(getcurrentTemplatePath()),"test","")>
	<cfset this.mappings[ "/bugLog" ] = left(this.rootDir,len(this.rootDir)-1) />

</cfcomponent>