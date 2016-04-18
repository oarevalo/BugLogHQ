component {
	// This component is in charge of evaluating a set of rules

	variables.aRules = [];
	variables.buglogClient = 0;
	variables.bugLogListenerEndpoint = "bugLog.listeners.bugLogListenerWS";

	// constructor
	ruleProcessor function init() {
		variables.aRules = [];
		variables.buglogClient = createObject("component","bugLog.client.bugLogService").init(variables.bugLogListenerEndpoint);
		return this;
	}

	// adds a rule to be processed
	void function addRule(
		required baseRule rule
	) {
		arrayAppend(variables.aRules, arguments.rule);
	}

	// executes all rules for all entry bens in the given array
	void function processRules(
		required array entries
	) {
		// process 'begin' event
		process("queueStart", entries);

		// process rules for each entry
		for(var oEntry in entries) {
			process("rule", oEntry);
			oEntry.flagAsProcessed();
		}

		// process 'end' event
		process("queueEnd", entries);
	}

	// clears all the loaded rules
	void function flushRules() {
		variables.aRules = arrayNew(1);
	}


	/** Private Methods **/

	// internal function to process all rules
	private void function process(
		required string event,
		required any arg
	) {
		var rtn = false;
		var ruleName = "";
		var thisRule = 0;
		
		for(var i=1; i lte arrayLen(variables.aRules); i++) {
			ruleName = "Rule #i#"; // a temporary name just in case the getMetaData() call fails
			thisRule = variables.aRules[i];
			try {
				ruleName = getMetaData(thisRule).name;
							
				// process rule
				switch(arguments.event) {
					case "queueStart":
						rtn = thisRule.processQueueStart(arg);
						break;
					case "rule":
						rtn = thisRule.processRule(arg);
						break;
					case "queueEnd":
						rtn = thisRule.processQueueEnd(arg);
						break;
				}

				// if rule returns false, then that means that no more rules will be processed, so we exit
				if(not rtn) break;

			} catch(any e) {
				// if an error occurs while a rule executes, then write to normal log file
				buglogClient.notifyService("RuleProcessor Error: #e.message#", e);
				writeToCFLog(ruleName & ": " & e.message & e.detail);	
			}
		}
	}

	// writes a message to the internal cf logs
	private void function writeToCFLog(
		required string message		
	) {
		writeLog(type="Info", file="bugLog_ruleProcessor", text="#arguments.message#", application=true); 
		writeDump(var="BugLog::RuleProcessor: #arguments.message#", output="console");
	}

}

