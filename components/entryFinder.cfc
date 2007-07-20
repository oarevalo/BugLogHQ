<cfcomponent>
	
	<cffunction name="init" returntype="entryFinder" access="public">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("entry")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="findByID" returnType="entry" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfscript>
			var qry = variables.oDAO.get(arguments.id);
			var o = 0;
			
			if(qry.recordCount gt 0) {
				o = createObject("component","entry").init();
				o.setEntryID(qry.entryID);
				o.setDateTime(qry.dateTime);
				o.setMessage(qry.message);
				o.setApplicationID(qry.ApplicationID);
				o.setSourceID(qry.SourceID);
				o.setSeverityID(qry.SeverityID);
				o.setHostID(qry.HostID);
				o.setExceptionMessage(qry.exceptionMessage);
				o.setExceptionDetails(qry.exceptionDetails);
				o.setCFID(qry.cfid);
				o.setCFTOKEN(qry.cftoken);
				o.setUserAgent(qry.userAgent);
				o.setTemplatePath(qry.templatePath);
				o.setHTMLReport(qry.HTMLReport);
				return o;
			} else {
				throw("ID not found","entryFinderException.IDNotFound");
			}
		</cfscript>
	</cffunction>

	<cffunction name="search" returnType="query" access="public">
		<cfargument name="searchTerm" type="string" required="true">
		<cfargument name="applicationID" type="numeric" required="false" default="0">
		<cfargument name="hostID" type="numeric" required="false" default="0">
		<cfargument name="severityID" type="numeric" required="false" default="0">
		<cfargument name="startDate" type="date" required="false" default="1/1/1800">
		<cfargument name="endDate" type="date" required="false" default="1/1/3000">
		<cfargument name="search_cfid" type="string" required="false" default="">
		<cfargument name="search_cftoken" type="string" required="false" default="">
		<cfreturn variables.oDAO.search(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="throw" access="private" returntype="void">
		<cfargument name="message" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfthrow message="#arguments.message#" type="#arguments.type#">
	</cffunction>
	
</cfcomponent>