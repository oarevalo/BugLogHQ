<cfcomponent extends="finder">

	<cffunction name="findByID" returnType="domain" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","bugLog.components.domain").init( variables.oDAO );
				o.setDomainID(qry.domainID);
				o.setDomain(qry.domain);
				o.setCreatedOn(qry.createdOn);
				return o;
			} else {
				throw("ID not found","domainFinderException.IDNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="findByName" returnType="domain" access="public">
		<cfargument name="name" type="string" required="true">
		<cfscript>
			var qry = variables.oDAO.getByLabel(arguments.name);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","bugLog.components.domain").init( variables.oDAO );
				o.setDomainID(qry.domainID);
				o.setDomain(qry.domain);
				o.setCreatedOn(qry.createdOn);
				return o;
			} else {
				throw("domain not found","domainFinderException.domainNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="findByCode" returnType="domain" access="public">
		<cfargument name="code" type="string" required="true">
		<cfreturn findByName(arguments.code)>
	</cffunction>

</cfcomponent>