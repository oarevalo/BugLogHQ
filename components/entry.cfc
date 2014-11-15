component output="false" {

	variables.oDAO = 0;

	variables.instance = {
		ID = 0,
		mydateTime = now(),
		message = "",
		applicationID = 0,
		sourceID = 0,
		severityID = 0,
		hostID = 0,
		exceptionMessage = "",
		exceptionDetails = "",
		CFID = "",
		CFTOKEN = "",
		userAgent = "",
		templatePath = "",
		HTMLReport = "",
		createdOn = now(),
		UUID = ""
	};
		
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
	function setUUID(data) {variables.instance.UUID = arguments.data;}

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
	function getUUID() {return variables.instance.UUID;}

	function getID() {return variables.instance.ID;}

	entry function init(
		required bugLog.components.db.entryDAO dao
	) {
		variables.oDAO = arguments.dao;
		return this;
	}
	
	void function save(){
		variables.instance.ID = variables.oDAO.save(argumentCollection = variables.instance);
	}

	// Returns the application object
	app function getApplication() {
		var dp = variables.oDAO.getDataProvider();
		var dao = createObject("component","bugLog.components.db.applicationDAO").init( dp );
		return createObject("component","bugLog.components.appFinder")
				.init( dao )
				.findByID(variables.instance.applicationID);
	}

	// Returns the host object
	host function getHost() {
		var dp = variables.oDAO.getDataProvider();
		var dao = createObject("component","bugLog.components.db.hostDAO").init( dp );
		return createObject("component","bugLog.components.hostFinder")
				.init( dao )
				.findByID(variables.instance.hostID);
	}

	// Returns the source object
	source function getSource() {
		var dp = variables.oDAO.getDataProvider();
		var dao = createObject("component","bugLog.components.db.sourceDAO").init( dp );
		return createObject("component","bugLog.components.sourceFinder")
				.init( dao )
				.findByID(variables.instance.sourceID);
	}

	// Returns the severity object
	severity function getSeverity() {
		var dp = variables.oDAO.getDataProvider();
		var dao = createObject("component","bugLog.components.db.severityDAO").init( dp );
		return createObject("component","bugLog.components.severityFinder")
				.init( dao )
				.findByID(variables.instance.severityID);
	}

}
