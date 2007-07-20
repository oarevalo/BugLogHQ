<cfcomponent>
	
	<cfscript>
		variables.dateTime = now();
		variables.message = "";
		variables.applicationCode = "";
		variables.sourceID = 0;
		variables.severityCode = "";
		variables.hostName = "";
		variables.exceptionMessage = "";
		variables.exceptionDetails = "";
		variables.CFID = "";
		variables.CFTOKEN = "";
		variables.userAgent = "";
		variables.templatePath = "";
		variables.HTMLReport = "";
		
		function setDateTime(data) {variables.dateTime = arguments.data;}
		function setMessage(data) {variables.message = arguments.data;}
		function setApplicationCode(data) {variables.applicationCode = arguments.data;}
		function setSourceID(data) {variables.sourceID = arguments.data;}
		function setSeverityCode(data) {variables.severityCode = arguments.data;}
		function setHostName(data) {variables.hostName = arguments.data;}
		function setExceptionMessage(data) {variables.exceptionMessage = arguments.data;}
		function setExceptionDetails(data) {variables.exceptionDetails = arguments.data;}
		function setCFID(data) {variables.CFID = arguments.data;}
		function setCFTOKEN(data) {variables.CFTOKEN = arguments.data;}
		function setUserAgent(data) {variables.userAgent = arguments.data;}
		function setTemplatePath(data) {variables.templatePath = arguments.data;}
		function setHTMLReport(data) {variables.HTMLReport = arguments.data;}
		
		function getDateTime() {return variables.dateTime;}
		function getMessage() {return variables.message;}
		function getApplicationCode() {return variables.applicationCode;}
		function getSourceID() {return variables.sourceID;}
		function getSeverityCode() {return variables.severityCode;}
		function getHostName() {return variables.hostName;}
		function getExceptionMessage() {return variables.exceptionMessage;}
		function getExceptionDetails() {return variables.exceptionDetails;}
		function getCFID() {return variables.CFID;}
		function getCFTOKEN() {return variables.CFTOKEN;}
		function getUserAgent() {return variables.userAgent;}
		function getTemplate_Path() {return variables.templatePath;}
		function getHTMLReport() {return variables.HTMLReport;}
	</cfscript>
	
	<cffunction name="init" access="public" returnType="rawEntryBean">
		<cfreturn this>
	</cffunction>


</cfcomponent>