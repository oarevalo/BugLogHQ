<cfcomponent extends="finder">

	<cffunction name="findByID" returnType="host" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","bugLog.components.host").init( variables.oDAO );
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
				o = createObject("component","bugLog.components.host").init( variables.oDAO );
				o.setHostID(qry.hostID);
				o.setHostName(qry.hostName);
				return o;
			} else {
				throw("Hostname not found","hostFinderException.HostNameNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="findByCode" returnType="host" access="public">
		<cfargument name="code" type="string" required="true">
		<cfreturn findByName(arguments.code)>
	</cffunction>

</cfcomponent>