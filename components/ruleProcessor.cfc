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

	// Process all rules with a given entry bean
	void function processRules(
		required entry entry
	) {
		_processRules("processRule", arguments);
	}

	// This method gets called BEFORE each processing of the queue
	void function processQueueStart(
		required array queue
	) {
		_processRules("processQueueStart", arguments);
	}

	// This method gets called AFTER each processing of the queue
	void function processQueueEnd(
		required array queue
	) {
		_processRules("processQueueEnd", arguments);
	}

	// clears all the loaded rules
	void function flushRules() {
		variables.aRules = arrayNew(1);
	}


	/** Private Methods **/

	// internal function to process all rules
	private void function _processRules(
		required string method,
		required struct args
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
				rtn = invokeMethod(thisRule, arguments.method, args);

				// if rule returns false, then that means that no more rules will be processed, so we exit
				if(not rtn) break;

			} catch(any e) {
				// if an error occurs while a rule executes, then write to normal log file
				buglogClient.notifyService("RuleProcessor Error: #e.message#", e);
				writeToCFLog(ruleName & ": " & e.message & e.detail);	
			}
		}
	}

	// dynamically calls a method on a rule instance
	private boolean function invokeMethod(
		required any instance,
		required string method,
		required struct args
	) {
		local.rtn = arguments.instance[arguments.method](argumentCollection = arguments.args);
		return structKeyExists(local,"rtn") ? local.rtn : true;
	}

	// writes a message to the internal cf logs
	private void function writeToCFLog(
		required string message		
	) {
		writeLog(type="Info", file="bugLog_ruleProcessor", text="#arguments.message#", application=true); 
		writeDump(var="BugLog::RuleProcessor: #arguments.message#", output="console");
	}

}

