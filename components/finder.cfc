<cfcomponent hint="Base class for Finder objects. Find objects are used to find instances of entities.">
	<cfset variables.oDAO = 0>
	
	<cffunction name="init" returntype="finder" access="public">
		<cfargument name="dao" type="bugLog.components.lib.dao.DAO" required="true">
		<cfset variables.oDAO = arguments.dao>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="throw" access="private" returntype="void">
		<cfargument name="message" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>
	
</cfcomponent>