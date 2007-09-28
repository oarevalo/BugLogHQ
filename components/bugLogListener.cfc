<cfcomponent displayname="bugLogListener">

	<cfset variables.startedOn = 0>

	<cffunction name="init" access="public" returntype="bugLogListener">
	
		<cfscript>
			var testRule = 0;
			
			// load the finder objects
			variables.oAppFinder = createObject("component","appFinder").init();
			variables.oHostFinder = createObject("component","hostFinder").init();
			variables.oSeverityFinder = createObject("component","severityFinder").init();
			
			// load the rule processor
			variables.oRuleProcessor = createObject("component","ruleProcessor").init();
			
			// load rules
			loadRules();
			
			// record the date at which the service started 
			variables.startedOn = Now();
		</cfscript>
	
		<cfreturn this>
	</cffunction>

	<cffunction name="logEntry" access="public" returntype="void">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		
		<cfscript>
			var bean = arguments.entryBean;
			var oEntry = createObject("component","entry").init();
			var oApp = 0;
			var oHost = 0;
			var oSeverity = 0;
				
			// get the applicationID
			try {
				oApp = variables.oAppFinder.findByCode(bean.getApplicationCode());

			} catch(appFinderException.ApplicationCodeNotFound e) {
				// code does not exist, so we need to create it
				oApp = createObject("component","app").init();
				oApp.setCode(bean.getApplicationCode());
				oApp.setName(bean.getApplicationCode());
				oApp.save();
			}
			
			
			// get the hostID
			try {
				oHost = variables.oHostFinder.findByName(bean.getHostName());

			} catch(hostFinderException.HostNameNotFound e) {
				// code does not exist, so we need to create it
				oHost = createObject("component","host").init();
				oHost.setHostName(bean.getHostName());
				oHost.save();
			}


			// get the severityID
			try {
				oSeverity = variables.oSeverityFinder.findByCode(bean.getSeverityCode());

			} catch(severityFinderException.codeNotFound e) {
				// code does not exist, so we need to create it
				oSeverity = createObject("component","severity").init();
				oSeverity.setCode(bean.getSeverityCode());
				oSeverity.setName(bean.getSeverityCode());
				oSeverity.save();
			}

			oEntry.setDateTime(bean.getdateTime());
			oEntry.setMessage(bean.getmessage());
			oEntry.setApplicationID(oApp.getApplicationID());
			oEntry.setSourceID(bean.getSourceID());
			oEntry.setSeverityID(oSeverity.getSeverityID());
			oEntry.setHostID(oHost.getHostID());
			oEntry.setExceptionMessage(bean.getexceptionMessage());
			oEntry.setExceptionDetails(bean.getexceptionDetails());
			oEntry.setCFID(bean.getcfid());
			oEntry.setCFTOKEN(bean.getcftoken());
			oEntry.setUserAgent(bean.getuserAgent());
			oEntry.setTemplatePath(bean.gettemplate_Path());
			oEntry.setHTMLReport(bean.getHTMLReport());
		
			oEntry.save();
		
		
			// process rules
			variables.oRuleProcessor.processRules(bean);
		
		</cfscript>
	</cffunction>

	<cffunction name="getStartedOn" access="public" returntype="date">
		<cfreturn variables.startedOn>
	</cffunction>

	<cffunction name="loadRules" access="private" returntype="void" hint="this method loads the rules into the rule processor">
		<cfscript>
			var oRule = 0;
			var oExtensionsService = 0;
			var aRules = arrayNew(1);
			var i = 0;
			
			// get the rule definitions from the extensions service
			oExtensionsService = createObject("component","extensionsService").init();
			aRules = oExtensionsService.getRules();
			
			// create rule objects and load them into the rule processor
			for(i=1; i lte arrayLen(aRules);i=i+1) {

				oRule = createObject("component", aRules[i].component ).init( argumentCollection = aRules[i].config );

				// add rule to processor
				variables.oRuleProcessor.addRule(oRule);
			}
			
		</cfscript>
	</cffunction>

</cfcomponent>