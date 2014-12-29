component output="false" {

	variables.oDAO = 0;

	variables.instance = {
		ID = 0,
		mydateTime = now(),
		message = "",
		applicationID = 0,
		applicationCode = "",
		sourceID = 0,
		severityID = 0,
		severityCode = "",
		hostID = 0,
		hostName = "",
		exceptionMessage = "",
		exceptionDetails = "",
		CFID = "",
		CFTOKEN = "",
		userAgent = "",
		templatePath = "",
		HTMLReport = "",
		createdOn = now(),
		updatedOn = now(),
		UUID = "",
		isProcessed = 0
	};
		
	function setEntryID(data) {variables.instance.ID = arguments.data; return this;}
	function setDateTime(data) {variables.instance.mydateTime = arguments.data; return this;}
	function setMessage(data) {variables.instance.message = left(arguments.data,500); return this;}
	function setApplicationID(data) {variables.instance.applicationID = arguments.data; return this;}
	function setSourceID(data) {variables.instance.sourceID = arguments.data; return this;}
	function setSeverityID(data) {variables.instance.severityID = arguments.data; return this;}
	function setHostID(data) {variables.instance.hostID = arguments.data; return this;}
	function setExceptionMessage(data) {variables.instance.exceptionMessage = left(arguments.data,500); return this;}
	function setExceptionDetails(data) {variables.instance.exceptionDetails = left(arguments.data,5000); return this;}
	function setCFID(data) {variables.instance.CFID = left(arguments.data,255); return this;}
	function setCFTOKEN(data) {variables.instance.CFTOKEN = left(arguments.data,255); return this;}
	function setUserAgent(data) {variables.instance.userAgent = left(arguments.data,500); return this;}
	function setTemplatePath(data) {variables.instance.templatePath = left(arguments.data,500); return this;}
	function setHTMLReport(data) {variables.instance.HTMLReport = arguments.data; return this;}
	function setCreatedOn(data) {variables.instance.createdOn = arguments.data; return this;}
	function setUpdatedOn(data) {variables.instance.updatedOn = arguments.data; return this;}
	function setIsProcessed(data) {variables.instance.isProcessed = arguments.data; return this;}
	function setUUID(data) {variables.instance.UUID = arguments.data; return this;}
	function setApplicationCode(data) {variables.instance.applicationCode = arguments.data; return this;}
	function setSeverityCode(data) {variables.instance.severityCode = arguments.data; return this;}
	function setHostName(data) {variables.instance.hostName = arguments.data; return this;}

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
	function getUpdatedOn() {return variables.instance.updatedOn;}
	function getIsProcessed() {return variables.instance.isProcessed;}
	function getUUID() {return variables.instance.UUID;}
	function getApplicationCode() {return variables.instance.applicationCode;}
	function getSeverityCode() {return variables.instance.severityCode;}
	function getHostName() {return variables.instance.hostName;}

	function getID() {return variables.instance.ID;}

	entry function init(
		required bugLog.components.db.entryDAO dao
	) {
		variables.oDAO = arguments.dao;
		return this;
	}
	
	void function save(){
		variables.instance.updatedOn = Now();
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

	struct function getMemento() {
		return variables.instance;
	}

	entry function setMemento(
		required struct data
	) {
		variables.instance = duplicate(arguments.data);
		return this;
	}

}
