<cfcomponent>
	
	<cffunction name="init" returntype="severityFinder" access="public">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("severity")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="findByID" returnType="severity" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","severity").init();
				o.setSeverityID(qry.severityID);
				o.setName(qry.name);
				o.setCode(qry.code);
				return o;
			} else {
				throw("ID not found","severityFinderException.IDNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="findByCode" returnType="severity" access="public">
		<cfargument name="code" type="string" required="true">
		<cfscript>
			var qry = variables.oDAO.getByLabel(arguments.code);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","severity").init();
				o.setSeverityID(qry.severityID);
				o.setName(qry.name);
				o.setCode(qry.code);
				return o;
			} else {
				throw("Severity code not found","severityFinderException.codeNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="throw" access="private" returntype="void">
		<cfargument name="message" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>
	
</cfcomponent>