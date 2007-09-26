<cfcomponent>
	
	<cfscript>
		variables.oDAO = 0;
		variables.instance.EntryID = 0;
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
		
		function setEntryID(data) {variables.instance.EntryID = arguments.data;}
		function setDateTime(data) {variables.instance.mydateTime = arguments.data;}
		function setMessage(data) {variables.instance.message = arguments.data;}
		function setApplicationID(data) {variables.instance.applicationID = arguments.data;}
		function setSourceID(data) {variables.instance.sourceID = arguments.data;}
		function setSeverityID(data) {variables.instance.severityID = arguments.data;}
		function setHostID(data) {variables.instance.hostID = arguments.data;}
		function setExceptionMessage(data) {variables.instance.exceptionMessage = arguments.data;}
		function setExceptionDetails(data) {variables.instance.exceptionDetails = arguments.data;}
		function setCFID(data) {variables.instance.CFID = arguments.data;}
		function setCFTOKEN(data) {variables.instance.CFTOKEN = arguments.data;}
		function setUserAgent(data) {variables.instance.userAgent = arguments.data;}
		function setTemplatePath(data) {variables.instance.templatePath = arguments.data;}
		function setHTMLReport(data) {variables.instance.HTMLReport = arguments.data;}
		
		function getEntryID() {return variables.instance.EntryID;}
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
	</cfscript>
	
	<cffunction name="init" access="public" returnType="entry">
		<cfset variables.oDAO = createObject("component","bugLog.components.db.DAOFactory").getDAO("entry")>
		<cfreturn this>
	</cffunction>

	<cffunction name="save" access="public">
		<cfset var rtn = 0>
		<cfset rtn = variables.oDAO.save(argumentCollection = variables.instance)>
		<cfset variables.EntryID = rtn>
	</cffunction>

	<cffunction name="getApplication" access="public" returntype="app" hint="Returns the application object">
		<cfreturn createObject("component","appFinder").init().findByID(variables.instance.applicationID)>
	</cffunction>

	<cffunction name="getHost" access="public" returntype="host" hint="Returns the host object">
		<cfreturn createObject("component","hostFinder").init().findByID(variables.instance.hostID)>
	</cffunction>

	<cffunction name="getSource" access="public" returntype="source" hint="Returns the source object">
		<cfreturn createObject("component","sourceFinder").init().findByID(variables.instance.sourceID)>
	</cffunction>

	<cffunction name="getSeverity" access="public" returntype="severity" hint="Returns the severity object">
		<cfreturn createObject("component","severityFinder").init().findByID(variables.instance.severityID)>
	</cffunction>
	
</cfcomponent>