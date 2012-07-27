<cfcomponent>
	
	<!--- Application settings --->
	<cfset this.name = "bugLogHQ"> 
	<cfset this.sessionManagement = true> 

	<!--- create an application mapping to the main bugLog directory (parent dir of this template) --->
	<cfset this.rootDir = GetDirectoryFromPath(GetDirectoryFromPath(GetCurrentTemplatePath()).ReplaceFirst( "[\\\/]{1}$", "" ))>
	<cfset this.mappings[ "/bugLog" ] = this.rootDir>

	<cffunction name="onRequestStart">
		<cfargument name="pageName" type="string" required="false" default="">

		<!--- see if this is a request for a named instance.
			A "named instance" is a separate deployment of buglog under a different directory other than /buglog or web root.
			A single server can host multiple named instances at the same time.
		 --->
		<cfset var current_path_dir = replace(getDirectoryFromPath(cgi.script_name), "/", "", "ALL")>
		<cfif current_path_dir neq "hq" and current_path_dir neq "bugLoghq">
			<!--- custom buglog instance name (same as url of containing folder, but without slashes) --->
			<cfset request.bugLogInstance = current_path_dir>
		</cfif>
	</cffunction>
	
</cfcomponent>

