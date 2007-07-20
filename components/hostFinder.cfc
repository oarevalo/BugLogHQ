<cfcomponent>
	
	<cffunction name="init" returntype="hostFinder" access="public">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("host")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="findByID" returnType="host" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","host").init();
				o.setHostID(qry.hostID);
				o.setHostName(qry.hostName);
				return o;
			} else {
				throw("ID not found","hostFinderException.IDNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="findByName" returnType="host" access="public">
		<cfargument name="name" type="string" required="true">
		<cfscript>
			var qry = variables.oDAO.getByLabel(arguments.name);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","host").init();
				o.setHostID(qry.hostID);
				o.setHostName(qry.hostName);
				return o;
			} else {
				throw("Hostname not found","hostFinderException.HostNameNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="throw" access="private" returntype="void">
		<cfargument name="message" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>
	
</cfcomponent>