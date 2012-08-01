<cfcomponent>

	<cfset this.name = "BugLogListenerTest">
	<cfset this.clientManagement = false> 
	<cfset this.sessionManagement = false> 

	<!--- create an application mapping to the main bugLog directory (parent dir of this template) --->
	<cfset this.rootDir = GetDirectoryFromPath(GetDirectoryFromPath(GetCurrentTemplatePath()).ReplaceFirst( "[\\\/]{1}$", "" ))>
	<cfset this.mappings[ "/bugLog" ] = this.rootDir>

</cfcomponent>