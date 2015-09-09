import bugLog.components.rules.*;

component accessors=true {
	// This component is in charge of evaluating a set of rules

	property name="logger";

	variables.rules = [];

	// constructor
	ruleProcessor function init() {
		variables.rules = [];
		return this;
	}

	// adds a rule to be processed
	void function addRule(
		required Rule rule
	) {
		arrayAppend(variables.rules, rule);
	}

	// executes all rules for all entry bens in the given array
	void function processRules(
		required array entries
	) {
		// process per-entry rules
		// (ensure each entry is processed only once)
		for(var oEntry in entries) {
			if( !oEntry.getIsProcessed() ) {
				processMessageRules(oEntry);
				oEntry.setIsProcessed(true);
				oEntry.save();
			}
		}

		// process aggregate rules
		processAggregateRules();
	}

	// clears all the loaded rules
	void function flushRules() {
		variables.rules = arrayNew(1);
	}

	// returns all rules 
	array function getRules() {
		return variables.rules;
	}


	/** Private Methods **/

	// internal function to process all rules
	private void function processMessageRules(
		required any entry
	) {
		var rtn = {};

		for(var thisRule in variables.rules) {

			// check that we only process rules with 
			// scope of the appropriate type
			if(!thisRule.appliesTo("message")) {
				continue;
			}

			// ensure that we dont process an entry that has
			// already been matched (in case this is a retry)
			var matches = logger.getMatchedRuleIDs(entry);
			if( arrayContains(matches, thisRule.getID()) ) {
				continue;
			}

			// process rule
			rtn = thisRule.process(entry);

			// keep a log of when rules get triggered
			if(rtn.matched) {
				logger.matched(thisRule, entry);
			}

			// check if we should continue to the next rule
			if(!rtn.next) {
				break;
			}
		}
	}

	private void function processAggregateRules() {
		var rtn = {};

		for(var thisRule in variables.rules) {

			// check that we only process rules with 
			// scope of the appropriate type
			if(!thisRule.appliesTo("aggregate")) {
				continue;
			}

			// process rule
			rtn = thisRule.process();

			// keep a log of when rules get triggered
			if(rtn.matched) {
				logger.matched(thisRule);
			}

		}
	}
}

