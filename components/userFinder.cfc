<cfcomponent>
	
	<cffunction name="init" returntype="userFinder" access="public">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("user")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="findByID" returnType="user" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","user").init();
				o.setUserID(qry.userID);
				o.setUsername(qry.username);
				o.setPassword(qry.password);
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
				o = createObject("component","user").init();
				o.setUserID(qry.userID);
				o.setUsername(qry.username);
				o.setPassword(qry.password);
				return o;
			} else {
				throw("Username not found","userFinderException.usernameNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="throw" access="private" returntype="void">
		<cfargument name="message" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>
	
</cfcomponent>