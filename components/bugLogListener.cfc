<cfcomponent displayname="bugLogListener">
	
	<!---
		bugLogListener.cfc
		
		This is the main point of entry into the bugLog API. This component is the one that
		actually processes the bug reports, it adds them to the database and is responsible
		for processing any defined rules.
	
		Created: 2007 - Oscar Arevalo - http://www.oscararevalo.com
	--->

	<cfset variables.startedOn = 0>
	<cfset variables.oDAOFactory = 0>
	<cfset variables.oRuleProcessor = 0>
	<cfset variables.oConfig = 0>

	<cffunction name="init" access="public" returntype="bugLogListener" hint="This is the constructor">
		<cfargument name="config" required="true" type="config">
		<cfscript>
			var cacheTTL = 300;		// timeout in minutes for cache entries
			
			variables.oConfig = arguments.config;		// global configuration
			
			// load DAO Factory
			variables.oDAOFactory = createObject("component","bugLog.components.DAOFactory").init( variables.oConfig );
					
			// load the finder objects
			variables.oAppFinder = createObject("component","bugLog.components.appFinder").init( variables.oDAOFactory.getDAO("application") );
			variables.oHostFinder = createObject("component","bugLog.components.hostFinder").init( variables.oDAOFactory.getDAO("host") );
			variables.oSeverityFinder = createObject("component","bugLog.components.severityFinder").init( variables.oDAOFactory.getDAO("severity") );
			variables.oSourceFinder = createObject("component","bugLog.components.sourceFinder").init( variables.oDAOFactory.getDAO("source") );
			
			// load the rule processor
			variables.oRuleProcessor = createObject("component","bugLog.components.ruleProcessor").init();
			
			// load rules
			loadRules();
			
			// create cache instances
			variables.oAppCache = createObject("component","bugLog.components.lib.cache.cacheService").init(50, cacheTTL, false);
			variables.oHostCache = createObject("component","bugLog.components.lib.cache.cacheService").init(50, cacheTTL, false);
			variables.oSeverityCache = createObject("component","bugLog.components.lib.cache.cacheService").init(5, cacheTTL, false);
			variables.oSourceCache = createObject("component","bugLog.components.lib.cache.cacheService").init(5, cacheTTL, false);		
						
			// record the date at which the service started 
			variables.startedOn = Now();
		</cfscript>
	
		<cfreturn this>
	</cffunction>

	<cffunction name="logEntry" access="public" returntype="void" hint="This method adds a bug report entry into BugLog. Bug reports must be passed as RawEntryBeans">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		
		<cfscript>
			var bean = arguments.entryBean;
			var oEntry = 0;
			var oApp = 0;
			var oHost = 0;
			var oSeverity = 0;
			var oSource = 0;
			var oDF = variables.oDAOFactory;
				
			// extract related objects from bean
			oApp = getApplicationFromBean( bean );
			oHost = getHostFromBean( bean );
			oSeverity = getSeverityFromBean( bean );
			oSource = getSourceFromBean( bean );

			// create entry
			oEntry = createObject("component","bugLog.components.entry").init( oDF.getDAO("entry") );
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
			oEntry.setCreatedOn(now());
		
			// save entry
			oEntry.save();
		
			// process rules
			variables.oRuleProcessor.processRules(bean, oDF.getDataProvider(), variables.oConfig );
		
		</cfscript>
	</cffunction>

	<cffunction name="getStartedOn" access="public" returntype="date" hint="Returns the date and time where this instance of BugLogListener was created">
		<cfreturn variables.startedOn>
	</cffunction>

	<cffunction name="shutDown" access="public" returntype="void" hint="Performs any clean up action required">
		<!--- empty --->
	</cffunction>

	<!---- Private Methods ---->
	
	<cffunction name="getApplicationFromBean" access="private" returntype="app" hint="Uses the information on the rawEntryBean to retrieve the corresponding Application object">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		<cfscript>
			var key = "";
			var bean = arguments.entryBean;
			var oApp = 0;
			var oDF = variables.oDAOFactory;
			
			key = bean.getApplicationCode();
			try {
				// first we try to get it from the cache
				oApp = variables.oAppCache.retrieve( key ); 
			
			} catch(cacheService.itemNotFound e) {
				// entry not in cache, so we get it from DB
				try {
					oApp = variables.oAppFinder.findByCode( key );
	
				} catch(appFinderException.ApplicationCodeNotFound e) {
					// code does not exist, so we need to create it
					oApp = createObject("component","bugLog.components.app").init( oDF.getDAO("application") );
					oApp.setCode( key );
					oApp.setName( key );
					oApp.save();
				}
				
				// store entry in cache
				variables.oAppCache.store( key, oApp );
			}
		</cfscript>
		<cfreturn oApp>
	</cffunction>
		
	<cffunction name="getHostFromBean" access="private" returntype="host" hint="Uses the information on the rawEntryBean to retrieve the corresponding Host object">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		<cfscript>
			var key = "";
			var bean = arguments.entryBean;
			var oHost = 0;
			var oDF = variables.oDAOFactory;
			
			key = bean.getHostName();
			
			try {
				// first we try to get it from the cache
				oHost = variables.oHostCache.retrieve( key ); 
			
			} catch(cacheService.itemNotFound e) {
				// entry not in cache, so we get it from DB
				try {
					oHost = variables.oHostFinder.findByName( key );
	
				} catch(hostFinderException.HostNameNotFound e) {
					// code does not exist, so we need to create it
					oHost = createObject("component","bugLog.components.host").init( oDF.getDAO("host") );
					oHost.setHostName(key);
					oHost.save();
				}

				// store entry in cache
				variables.oHostCache.store( key, oHost );
			}			
		</cfscript>
		<cfreturn oHost>
	</cffunction>
	
	<cffunction name="getSeverityFromBean" access="private" returntype="severity" hint="Uses the information on the rawEntryBean to retrieve the corresponding Severity object">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		<cfscript>
			var key = "";
			var bean = arguments.entryBean;
			var oSeverity = 0;
			var oDF = variables.oDAOFactory;
			
			key = bean.getSeverityCode();
			
			try {
				// first we try to get it from the cache
				oSeverity = variables.oSeverityCache.retrieve( key ); 
			
			} catch(cacheService.itemNotFound e) {
				// entry not in cache, so we get it from DB
				try {
					oSeverity = variables.oSeverityFinder.findByCode( key );
	
				} catch(severityFinderException.codeNotFound e) {
					// code does not exist, so we need to create it
					oSeverity = createObject("component","bugLog.components.severity").init( oDF.getDAO("severity") );
					oSeverity.setCode( key );
					oSeverity.setName( key );
					oSeverity.save();
				}
				
				// store entry in cache
				variables.oSeverityCache.store( key, oSeverity );
			}
		</cfscript>
		<cfreturn oSeverity>
	</cffunction>
	
	<cffunction name="getSourceFromBean" access="private" returntype="source" hint="Uses the information on the rawEntryBean to retrieve the corresponding Source object">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		<cfscript>
			var key = "";
			var bean = arguments.entryBean;
			var oSource = 0;
			var oDF = variables.oDAOFactory;
			
			key = bean.getSourceName();
			
			try {
				// first we try to get it from the cache
				oSource = variables.oSourceCache.retrieve( key ); 
			
			} catch(cacheService.itemNotFound e) {
				// entry not in cache, so we get it from DB
				try {
					oSource = variables.oSourceFinder.findByName( key );
	
				} catch(sourceFinderException.codeNotFound e) {
					// code does not exist, so we need to create it
					oSource = createObject("component","bugLog.components.source").init( oDF.getDAO("source") );
					oSource.setName( key );
					oSource.save();
				}
				
				// store entry in cache
				variables.oSourceCache.store( key, oSource );
			}
		</cfscript>
		<cfreturn oSource>
	</cffunction>		

	<cffunction name="loadRules" access="private" returntype="void" hint="this method loads the rules into the rule processor">
		<cfscript>
			var oRule = 0;
			var oExtensionsService = 0;
			var aRules = arrayNew(1);
			var i = 0;
			var dao = 0;
			
			// get the rule definitions from the extensions service
			dao = variables.oDAOFactory.getDAO("extension");
			oExtensionsService = createObject("component","bugLog.components.extensionsService").init( dao );
			aRules = oExtensionsService.getRules();
			
			// create rule objects and load them into the rule processor
			for(i=1; i lte arrayLen(aRules);i=i+1) {
				
				if(aRules[i].enabled) {
					oRule = createObject("component", aRules[i].component ).init( argumentCollection = aRules[i].config );
	
					// add rule to processor
					variables.oRuleProcessor.addRule(oRule);
				}
			}
		</cfscript>
	</cffunction>


</cfcomponent>