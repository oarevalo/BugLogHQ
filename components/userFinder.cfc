<cfcomponent extends="finder">
	
	<cffunction name="findByID" returnType="user" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","bugLog.components.user").init( variables.oDAO );
				o.setUserID(qry.userID);
				o.setUsername(qry.username);
				o.setPassword(qry.password);
				o.setIsAdmin(qry.isAdmin);
				o.setEmail(qry.email);
				return o;
			} else {
				throw("ID not found","userFinderException.IDNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="findByUsername" returnType="user" access="public">
		<cfargument name="username" type="string" required="true">
		<cfscript>
			var qry = variables.oDAO.getByLabel(arguments.username);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","bugLog.components.user").init( variables.oDAO );
				o.setUserID(qry.userID);
				o.setUsername(qry.username);
				o.setPassword(qry.password);
				o.setIsAdmin(qry.isAdmin);
				o.setEmail(qry.email);
				return o;
			} else {
				throw("Username not found","userFinderException.usernameNotFound");
			}
		</cfscript>
	</cffunction>

	
</cfcomponent>