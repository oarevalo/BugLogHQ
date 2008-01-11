<cfcomponent extends="finder">
		
	<cffunction name="findByID" returnType="source" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","source").init( variables.oDAO );
				o.setSourceID(qry.sourceID);
				o.setName(qry.name);
				return o;
			} else {
				throw("ID not found","sourceFinderException.IDNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="findByName" returnType="source" access="public">
		<cfargument name="name" type="string" required="true">
		<cfscript>
			var qry = variables.oDAO.getByLabel(arguments.name);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","source").init( variables.oDAO );
				o.setSourceID(qry.sourceID);
				o.setName(qry.name);
				return o;
			} else {
				throw("Source name not found","sourceFinderException.codeNotFound");
			}
		</cfscript>
	</cffunction>

</cfcomponent>