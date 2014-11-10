component output="false" {

	/*
		BugLogListener.cfc

		This is the main point of entry into the bugLog API. This component is the one that
		actually processes the bug reports, it adds them to the database and is responsible
		for processing any defined rules.

		Created: 2007 - Oscar Arevalo - http://www.oscararevalo.com
	*/

	variables.startedOn = 0;
	variables.oDAOFactory = 0;
	variables.oRuleProcessor = 0;
	variables.oConfig = 0;
	variables.msgLog = arrayNew(1);
	variables.maxLogSize = 10;
	variables.instanceName = "";
	variables.autoCreateDefault = true;
	variables.queue = 0;
	variables.schedulerIntervalSecs = 0;

	// this is a simple protection to avoid calling processqueue() too easily. This is NOT the apiKey setting
	variables.key = "123456knowthybugs654321"; 

	// timeout in minutes for cache entries
	variables.CACHE_TTL = 300;


	// Constructor
	bugLogListener function init(
		required config config,
		required string instanceName
	) {

		variables.oConfig = arguments.config;		// global configuration
		variables.instanceName = arguments.instanceName;

		logMessage("Starting BugLogListener (#instanceName#) service...");

		// load settings
		variables.maxLogSize = arguments.config.getSetting("service.maxLogSize");

		// load DAO Factory
		variables.oDAOFactory = createObject("component","bugLog.components.DAOFactory").init( variables.oConfig );

		// load the finder objects
		variables.oAppFinder = createObject("component","bugLog.components.appFinder").init( variables.oDAOFactory.getDAO("application") );
		variables.oHostFinder = createObject("component","bugLog.components.hostFinder").init( variables.oDAOFactory.getDAO("host") );
		variables.oSeverityFinder = createObject("component","bugLog.components.severityFinder").init( variables.oDAOFactory.getDAO("severity") );
		variables.oSourceFinder = createObject("component","bugLog.components.sourceFinder").init( variables.oDAOFactory.getDAO("source") );
		variables.oUserFinder = createObject("component","bugLog.components.userFinder").init( variables.oDAOFactory.getDAO("user") );

		// load the rule processor
		variables.oRuleProcessor = createObject("component","bugLog.components.ruleProcessor").init();

		// create cache instances
		variables.oAppCache = createObject("component","bugLog.components.lib.cache.cacheService").init(50, variables.CACHE_TTL, false);
		variables.oHostCache = createObject("component","bugLog.components.lib.cache.cacheService").init(50, variables.CACHE_TTL, false);
		variables.oSeverityCache = createObject("component","bugLog.components.lib.cache.cacheService").init(10, variables.CACHE_TTL, false);
		variables.oSourceCache = createObject("component","bugLog.components.lib.cache.cacheService").init(5, variables.CACHE_TTL, false);
		variables.oUserCache = createObject("component","bugLog.components.lib.cache.cacheService").init(50, variables.CACHE_TTL, false);

		// load scheduler
		variables.scheduler = createObject("component","bugLog.components.schedulerService").init( variables.oConfig, variables.instanceName );

		// load the mailer service
		variables.mailerService = createObject("component","bugLog.components.MailerService").init( variables.oConfig );

		// configure the incoming queue
		configureQueue();

		// load rules
		loadRules();

		// configure history purging
		configureHistoryPurging();

		// configure the digest sender
		configureDigest();

		// record the date at which the service started
		variables.startedOn = Now();

		logMessage("BugLogListener Service (#instanceName#) Started");

		return this;
	}

	// This method adds a bug report entry to the incoming queue. Bug reports must be passed as RawEntryBeans
	void function logEntry(
		required rawEntryBean entryBean
	) {
		try {
			variables.queue.add( arguments.entryBean );			
		} catch(bugLog.queueFull) {
			logMessage("Queue full! Discarding entry.");
		}
	}

	// This method adds a bug report entry into BugLog. Bug reports must be passed as RawEntryBeans
	void function addEntry(
		required rawEntryBean entryBean
	) {
		var bean = arguments.entryBean;
		var oDF = variables.oDAOFactory;

		// get autocreate settings
		var autoCreateApp = allowAutoCreate("application");
		var autoCreateHost = allowAutoCreate("host");
		var autoCreateSeverity = allowAutoCreate("severity");
		var autoCreateSource = allowAutoCreate("source");

		// extract related objects from bean
		var oApp = getApplicationFromBean( bean, autoCreateApp );
		var oHost = getHostFromBean( bean, autoCreateHost );
		var oSeverity = getSeverityFromBean( bean, autoCreateSeverity );
		var oSource = getSourceFromBean( bean, autoCreateSource );

		// create entry
		var oEntry = createObject("component","bugLog.components.entry").init( oDF.getDAO("entry") );
		oEntry.setDateTime(bean.getdateTime());
		oEntry.setMessage(bean.getmessage());
		oEntry.setApplicationID(oApp.getApplicationID());
		oEntry.setSourceID(oSource.getSourceID());
		oEntry.setSeverityID(oSeverity.getSeverityID());
		oEntry.setHostID(oHost.getHostID());
		oEntry.setExceptionMessage(bean.getexceptionMessage());
		oEntry.setExceptionDetails(bean.getexceptionDetails());
		oEntry.setCFID(bean.getcfid());
		oEntry.setCFTOKEN(bean.getcftoken());
		oEntry.setUserAgent(bean.getuserAgent());
		oEntry.setTemplatePath(bean.gettemplate_Path());
		oEntry.setHTMLReport(bean.getHTMLReport());
		oEntry.setCreatedOn(bean.getReceivedOn());
		oEntry.setUUID(bean.getUUID());

		// save entry
		oEntry.save();

		// process rules
		variables.oRuleProcessor.processRules(bean, oEntry);
	}

	// Processes all entries on the queue
	numeric function processQueue(
		required string key
	) {
		var i = 0;
		var errorQueue = arrayNew(1);
		var count = 0;
		var dp = variables.oDAOFactory.getDataProvider();
		
		if(arguments.key neq variables.key) {
			logMessage("Invalid key received. Exiting.");
			return 0;
		}
		
		// get a snapshot of the queue as of right now
		var myQueue = variables.queue.flush();
		variables.oRuleProcessor.processQueueStart(myQueue, dp, variables.oConfig );
		if(arrayLen(myQueue) gt 0) {
			logMessage("Processing queue. Queue size: #arrayLen(myQueue)#");
			for(var i=1;i lte arrayLen(myQueue);i++) {
				try {
					addEntry(myQueue[i]);
					count++;
				} catch(any e) {
					// log error and save entry in another queue
					arrayAppend(errorQueue,myQueue[i]);
					logMessage("ERROR: #cfcatch.message# #cfcatch.detail#. Original message in entry: '#myQueue[i].getMessage()#'");
				}
			}
		}
		variables.oRuleProcessor.processQueueEnd(myQueue, dp, variables.oConfig );
			
		// add back all entries on the error queue to the main queue
		if(arrayLen(errorQueue)) {
			for(var i=1;i lte arrayLen(errorQueue);i++) {
				logEntry(errorQueue[i]);
			}
			logMessage("Failed to add #arrayLen(errorQueue)# entries. Returned failed entries to main queue. To clear up queue and discard this entries reset the listener.");
		}

		return count;
	}
	
	// Performs any clean up action required
	void function shutDown() {
		logMessage("Stopping BugLogListener (#instanceName#) service...");
		logMessage("Stopping ProcessQueue scheduled task...");
		scheduler.removeTask("bugLogProcessQueue");
		logMessage("Processing remaining elements in queue...");
		processQueue(variables.key);
		logMessage("BugLogListener service (#instanceName#) stopped.");
	}

	// this method appends an entry to the messages log as well as displays the message on the console
	void function logMessage(
		required string msg
	) {
		var System = CreateObject('java','java.lang.System');
		var txt = timeFormat(now(), 'HH:mm:ss') & ": " & msg;
		System.out.println("BugLogListener: " & txt);
		lock name="bugLogListener_logMessage" type="exclusive" timeout="10" {
			if(arrayLen(variables.msgLog) gt variables.maxLogSize) {
				arrayDeleteAt(variables.msgLog, ArrayLen(variables.msgLog));
			}
			arrayPrepend(variables.msgLog,txt);
		}
	}

	// Validates that a bug report is valid, if not throws an error. 
	// This validates API key (if needed) and auto-create settings
	boolean function validate(
		required rawEntryBean entryBean,
		required string apiKey
	) {
		// validate API
		if(getConfig().getSetting("service.requireAPIKey",false)) {
			if(arguments.apiKey eq "") {
				throw(message="Invalid API Key", type="bugLog.invalidAPIKey");
			}
			var masterKey = getConfig().getSetting("service.APIKey");
			if(arguments.apiKey neq masterKey) {
				var user = getUserByAPIKey(arguments.apiKey);
				if(!user.getIsAdmin() and arrayLen(user.getAllowedApplications())) {
					// key is good, but since the user is a non-admin
					// we need to validate the user can post bugs to the requested
					// application.
					var app = getApplicationFromBean( entryBean, false );
					if(!user.isApplicationAllowed(app)) {
						throw(message="Application not allowed",type="applicationNotAllowed");
					}
				}
			}
		}

		// validate application
		if(!allowAutoCreate("application")) {
			getApplicationFromBean( entryBean, false );
		}

		// validate host
		if(!allowAutoCreate("host")) {
			getHostFromBean( entryBean, false );
		}

		// validte severity
		if(!allowAutoCreate("severity")) {
			getSeverityFromBean( entryBean, false );
		}

		// validate source
		if(!allowAutoCreate("source")) {
			getSourceFromBean( entryBean, false );
		}

		return true;
	}

	// Reloads all rules
	void function reloadRules() {
		loadRules();
	}

	// Return the contents of the queue for inspection
	array function getEntryQueue() {
		return variables.queue.getAll();
	}

	// Getter functions
	config function getConfig() {return variables.oConfig;}
	string function getInstanceName() {return variables.instanceName;}
	array function getMessageLog() {return variables.msgLog;}
	string function getKey() {return variables.key;}
	date function getStartedOn() {return variables.startedOn;}



	/*****   Private Methods   ******/

	// Uses the information on the rawEntryBean to retrieve the corresponding Application object
	private app function getApplicationFromBean(
		required rawEntryBean entryBean,
		boolean createIfNeeded = false
	) {
		var bean = arguments.entryBean;
		var oApp = 0;
		var oDF = variables.oDAOFactory;

		var key = bean.getApplicationCode();
		try {
			// first we try to get it from the cache
			oApp = variables.oAppCache.retrieve( key );

		} catch(cacheService.itemNotFound e) {
			// entry not in cache, so we get it from DB
			try {
				oApp = variables.oAppFinder.findByCode( key );

			} catch(appFinderException.ApplicationCodeNotFound e) {
				// code does not exist, so we need to create it (if autocreate enabled)
				if(!arguments.createIfNeeded) throw(message="Invalid Application",type="invalidApplication");
				oApp = createObject("component","bugLog.components.app").init( oDF.getDAO("application") );
				oApp.setCode( key );
				oApp.setName( key );
				oApp.save();
			}

			// store entry in cache
			variables.oAppCache.store( key, oApp );
		}

		return oApp;
	}

	// Uses the information on the rawEntryBean to retrieve the corresponding Host object
	private host function getHostFromBean(
		required rawEntryBean entryBean,
		boolean createIfNeeded = false
	) {
		var bean = arguments.entryBean;
		var oHost = 0;
		var oDF = variables.oDAOFactory;

		var key = bean.getHostName();

		try {
			// first we try to get it from the cache
			oHost = variables.oHostCache.retrieve( key );

		} catch(cacheService.itemNotFound e) {
			// entry not in cache, so we get it from DB
			try {
				oHost = variables.oHostFinder.findByName( key );

			} catch(hostFinderException.HostNameNotFound e) {
				// code does not exist, so we need to create it (if autocreate enabled)
				if(!arguments.createIfNeeded) throw(message="Invalid Host",type="invalidHost");
				oHost = createObject("component","bugLog.components.host").init( oDF.getDAO("host") );
				oHost.setHostName(key);
				oHost.save();
			}

			// store entry in cache
			variables.oHostCache.store( key, oHost );
		}

		return oHost;
	}

	// Uses the information on the rawEntryBean to retrieve the corresponding Severity object
	private severity function getSeverityFromBean(
		required rawEntryBean entryBean,
		boolean createIfNeeded = false
	) {
		var bean = arguments.entryBean;
		var oSeverity = 0;
		var oDF = variables.oDAOFactory;

		var key = bean.getSeverityCode();

		try {
			// first we try to get it from the cache
			oSeverity = variables.oSeverityCache.retrieve( key );

		} catch(cacheService.itemNotFound e) {
			// entry not in cache, so we get it from DB
			try {
				oSeverity = variables.oSeverityFinder.findByCode( key );

			} catch(severityFinderException.codeNotFound e) {
				// code does not exist, so we need to create it (if autocreate enabled)
				if(!arguments.createIfNeeded) throw(message="Invalid Severity",type="invalidSeverity");
				oSeverity = createObject("component","bugLog.components.severity").init( oDF.getDAO("severity") );
				oSeverity.setCode( key );
				oSeverity.setName( key );
				oSeverity.save();
			}

			// store entry in cache
			variables.oSeverityCache.store( key, oSeverity );
		}

		return oSeverity;
	}

	// Finds a user object using by its API Key
	private user function getUserByAPIKey(
		required string apiKey
	) {
		var oUser = 0;

		try {
			// first we try to get it from the cache
			oUser = variables.oUserCache.retrieve( apiKey );

		} catch(cacheService.itemNotFound e) {
			// entry not in cache, so we get it from DB
			try {
				oUser = variables.oUserFinder.findByAPIKey( apiKey );

				var qryUserApps = oDAOFactory.getDAO("userApplication").search(userID = oUser.getUserID());
				var apps = oAppFinder.findByIDList(valueList(qryUserApps.applicationID));
				oUser.setAllowedApplications(apps);

			} catch(userFinderException.usernameNotFound e) {
				// code does not exist, so we need to create it (if autocreate enabled)
				throw(message="Invalid API Key",type="bugLog.invalidAPIKey");
			}

			// store entry in cache
			variables.oUserCache.store( key, oUser );
		}

		return oUser;
	}

	// Uses the information on the rawEntryBean to retrieve the corresponding Source object
	private source function getSourceFromBean(
		required rawEntryBean entryBean,
		boolean createIfNeeded = false
	) {
		var bean = arguments.entryBean;
		var oSource = 0;
		var oDF = variables.oDAOFactory;

		var key = bean.getSourceName();

		try {
			// first we try to get it from the cache
			oSource = variables.oSourceCache.retrieve( key );

		} catch(cacheService.itemNotFound e) {
			// entry not in cache, so we get it from DB
			try {
				oSource = variables.oSourceFinder.findByName( key );

			} catch(sourceFinderException.codeNotFound e) {
				// code does not exist, so we need to create it (if autocreate enabled)
				if(!arguments.createIfNeeded) throw(message="Invalid Source",type="invalidSource");
				oSource = createObject("component","bugLog.components.source").init( oDF.getDAO("source") );
				oSource.setName( key );
				oSource.save();
			}

			// store entry in cache
			variables.oSourceCache.store( key, oSource );
		}

		return oSource;
	}

	// This method loads the rules into the rule processor
	private void function loadRules() {
		var oRule = 0;
		var thisRule = 0;

		// clear all existing rules
		variables.oRuleProcessor.flushRules();

		// get the rule definitions from the extensions service
		var dao = variables.oDAOFactory.getDAO("extension");
		var oExtensionsService = createObject("component","bugLog.components.extensionsService").init( dao );
		var aRules = oExtensionsService.getRules();

		// create rule objects and load them into the rule processor
		for(var i=1; i lte arrayLen(aRules);i=i+1) {
			thisRule = aRules[i];

			if(thisRule.enabled) {
				oRule =
					thisRule.instance
					.setListener(this)
					.setDAOFactory( variables.oDAOFactory )
					.setMailerService( variables.mailerService );

				// add rule to processor
				variables.oRuleProcessor.addRule(oRule);
			}
		}
	}

	private boolean function allowAutoCreate(
		required string entityType
	) {
		var setting = "autocreate." & arguments.entityType;
		return getConfig().getSetting(setting, variables.autoCreateDefault);
	}

	private void function configureHistoryPurging() {
		var enabled = getConfig().getSetting("purging.enabled");
		if( enabled ) {
			scheduler.setupTask("bugLogPurgeHistory",
								"util/purgeHistory.cfm",
								"03:00",
								"daily");
		} else {
			scheduler.removeTask("bugLogPurgeHistory");
		}
	}

	private void function configureDigest() {
		var enabled = oConfig.getSetting("digest.enabled");
		var interval = oConfig.getSetting("digest.schedulerIntervalHours");
		var startTime = oConfig.getSetting("digest.schedulerStartTime");

		if( enabled ) {
			scheduler.setupTask("bugLogSendDigest",
								"util/sendDigest.cfm",
								startTime,
								interval*3600);
		} else {
			scheduler.removeTask("bugLogSendDigest");
		}
	}

	private void function configureQueue() {
		// setup queueing service
		var queueClass = oConfig.getSetting("service.queueClass");
		variables.queue = createObject("component",queueClass).init(oConfig, instanceName);

		// create a task to process the queue periodically
		var schedulerIntervalSecs = oConfig.getSetting("service.schedulerIntervalSecs");
		scheduler.setupTask("bugLogProcessQueue", 
								"util/processQueue.cfm",
								"00:00",
								schedulerIntervalSecs,
								[{name="key",value=variables.KEY}]);
	}

}

