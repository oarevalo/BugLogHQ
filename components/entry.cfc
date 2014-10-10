<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.instance.ID = 0;
		variables.instance.mydateTime = now();
		variables.instance.message = "";
		variables.instance.applicationID = 0;
		variables.instance.sourceID = 0;
		variables.instance.severityID = 0;
		variables.instance.hostID = 0;
		variables.instance.exceptionMessage = "";
		variables.instance.exceptionDetails = "";
		variables.instance.CFID = "";
		variables.instance.CFTOKEN = "";
		variables.instance.userAgent = "";
		variables.instance.templatePath = "";
		variables.instance.HTMLReport = "";
		variables.instance.createdOn = now();
		variables.instance.domainId = 0;
		
		function setEntryID(data) {variables.instance.ID = arguments.data;}
		function setDateTime(data) {variables.instance.mydateTime = arguments.data;}
		function setMessage(data) {variables.instance.message = left(arguments.data,500);}
		function setApplicationID(data) {variables.instance.applicationID = arguments.data;}
		function setSourceID(data) {variables.instance.sourceID = arguments.data;}
		function setSeverityID(data) {variables.instance.severityID = arguments.data;}
		function setHostID(data) {variables.instance.hostID = arguments.data;}
		function setExceptionMessage(data) {variables.instance.exceptionMessage = left(arguments.data,500);}
		function setExceptionDetails(data) {variables.instance.exceptionDetails = left(arguments.data,5000);}
		function setCFID(data) {variables.instance.CFID = left(arguments.data,255);}
		function setCFTOKEN(data) {variables.instance.CFTOKEN = left(arguments.data,255);}
		function setUserAgent(data) {variables.instance.userAgent = left(arguments.data,500);}
		function setTemplatePath(data) {variables.instance.templatePath = left(arguments.data,500);}
		function setHTMLReport(data) {variables.instance.HTMLReport = arguments.data;}
		function setCreatedOn(data) {variables.instance.createdOn = arguments.data;}
		function setDomainId(data) {variables.instance.domainId = arguments.data;}
		
		function getEntryID() {return variables.instance.ID;}
		function getDateTime() {return variables.instance.mydateTime;}
		function getMessage() {return variables.instance.message;}
		function getApplicationID() {return variables.instance.applicationID;}
		function getSourceID() {return variables.instance.sourceID;}
		function getSeverityID() {return variables.instance.severityID;}
		function getHostID() {return variables.instance.hostID;}
		function getExceptionMessage() {return variables.instance.exceptionMessage;}
		function getExceptionDetails() {return variables.instance.exceptionDetails;}
		function getCFID() {return variables.instance.CFID;}
		function getCFTOKEN() {return variables.instance.CFTOKEN;}
		function getUserAgent() {return variables.instance.userAgent;}
		function getTemplate_Path() {return variables.instance.templatePath;}
		function getHTMLReport() {return variables.instance.HTMLReport;}
		function getCreatedOn() {return variables.instance.createdOn;}
		function getDomainId() {return variables.instance.domainId;}

		function getID() {return variables.instance.ID;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="entry">
		<cfargument name="dao" type="bugLog.components.db.entryDAO" required="true">
		<cfset variables.oDAO = arguments.dao>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(argumentCollection = variables.instance)>
		<cfset variables.instance.ID = rtn>
	</cffunction>

	<cffunction name="getApplication" access="public" returntype="app" hint="Returns the application object">
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var oApplicationDAO = createObject("component","bugLog.components.db.applicationDAO").init( oDataProvider )>
		<cfreturn createObject("component","bugLog.components.appFinder").init( oApplicationDAO ).findByID(variables.instance.applicationID)>
	</cffunction>

	<cffunction name="getHost" access="public" returntype="host" hint="Returns the host object">
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var oHostDAO = createObject("component","bugLog.components.db.hostDAO").init( oDataProvider )>
		<cfreturn createObject("component","bugLog.components.hostFinder").init( oHostDAO ).findByID(variables.instance.hostID)>
	</cffunction>

	<cffunction name="getSource" access="public" returntype="source" hint="Returns the source object">
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var oSourceDAO = createObject("component","bugLog.components.db.sourceDAO").init( oDataProvider )>
		<cfreturn createObject("component","bugLog.components.sourceFinder").init( oSourceDAO ).findByID(variables.instance.sourceID)>
	</cffunction>

	<cffunction name="getSeverity" access="public" returntype="severity" hint="Returns the severity object">
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var oSeverityDAO = createObject("component","bugLog.components.db.severityDAO").init( oDataProvider )>
		<cfreturn createObject("component","bugLog.components.severityFinder").init( oSeverityDAO ).findByID(variables.instance.severityID)>
	</cffunction>
	
	<cffunction name="getDomain" access="public" returntype="domain" hint="Returns the domain object">
		<cfset var oDataProvider = variables.oDAO.getDataProvider()>
		<cfset var oDomainDAO = createObject("component","bugLog.components.db.domainDAO").init( oDataProvider )>
		<cfreturn createObject("component","bugLog.components.domainFinder").init( oDomainDAO ).findByID(variables.instance.domainId)>
	</cffunction>
	
</cfcomponent>