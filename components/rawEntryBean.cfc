<cfcomponent>
	
	<cfscript>
		variables.instance = structNew();
		variables.instance.dateTime = now();
		variables.instance.message = "";
		variables.instance.applicationCode = "";
		variables.instance.sourceID = 0;
		variables.instance.severityCode = "";
		variables.instance.hostName = "";
		variables.instance.exceptionMessage = "";
		variables.instance.exceptionDetails = "";
		variables.instance.CFID = "";
		variables.instance.CFTOKEN = "";
		variables.instance.userAgent = "";
		variables.instance.templatePath = "";
		variables.instance.HTMLReport = "";
		variables.instance.sourceName = "";
		
		function setDateTime(data) {variables.instance.dateTime = arguments.data;}
		function setMessage(data) {variables.instance.message = arguments.data;}
		function setApplicationCode(data) {variables.instance.applicationCode = arguments.data;}
		function setSourceID(data) {variables.instance.sourceID = arguments.data;}
		function setSeverityCode(data) {variables.instance.severityCode = arguments.data;}
		function setHostName(data) {variables.instance.hostName = arguments.data;}
		function setExceptionMessage(data) {variables.instance.exceptionMessage = arguments.data;}
		function setExceptionDetails(data) {variables.instance.exceptionDetails = arguments.data;}
		function setCFID(data) {variables.instance.CFID = arguments.data;}
		function setCFTOKEN(data) {variables.instance.CFTOKEN = arguments.data;}
		function setUserAgent(data) {variables.instance.userAgent = arguments.data;}
		function setTemplatePath(data) {variables.instance.templatePath = arguments.data;}
		function setHTMLReport(data) {variables.instance.HTMLReport = arguments.data;}
		function setSourceName(data) {variables.instance.sourceName = arguments.data;}
		
		function getDateTime() {return variables.instance.dateTime;}
		function getMessage() {return variables.instance.message;}
		function getApplicationCode() {return variables.instance.applicationCode;}
		function getSourceID() {return variables.instance.sourceID;}
		function getSeverityCode() {return variables.instance.severityCode;}
		function getHostName() {return variables.instance.hostName;}
		function getExceptionMessage() {return variables.instance.exceptionMessage;}
		function getExceptionDetails() {return variables.instance.exceptionDetails;}
		function getCFID() {return variables.instance.CFID;}
		function getCFTOKEN() {return variables.instance.CFTOKEN;}
		function getUserAgent() {return variables.instance.userAgent;}
		function getTemplate_Path() {return variables.instance.templatePath;}
		function getHTMLReport() {return variables.instance.HTMLReport;}
		function getSourceName() {return variables.instance.sourceName;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="rawEntryBean">
		<cfreturn this>
	</cffunction>

	<cffunction name="getMemento" access="public" returntype="struct">
		<cfreturn variables.instance>
	</cffunction>

</cfcomponent>