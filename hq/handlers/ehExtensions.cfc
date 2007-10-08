<cfcomponent extends="eventHandler">

	<cffunction name="dspMain">
		<cfscript>
			aRules = getService("app").getRules();
			aActiveRules = getService("app").getActiveRules();

			setValue("aRules", aRules);
			setValue("aActiveRules", aActiveRules);

			setView("vwExtensions");
		</cfscript>
	</cffunction>

	<cffunction name="dspRule">
		<cfscript>
			index = getValue("index",0);
			ruleName = getValue("ruleName","");
			if(ruleName eq "") throw("Please select a valid rule type");
			
			stRule = getService("app").getRuleInfo(ruleName);

			setValue("stRule", stRule);
			setValue("index", index);
			setValue("ruleName", ruleName);
			
			if(index gt 0) {
				aActiveRules = getService("app").getActiveRules();
				setValue("aActiveRule", aActiveRules[index]);
			}
			
			setView("vwRule");
		</cfscript>
	</cffunction>
	
	<cffunction name="doSaveRule">
		<cfscript>
			try {
				getService("app").saveRule(argumentCollection = form);
				setMessage("info","Rule saved. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteRule">
		<cfscript>
			try {
				getService("app").deleteRule(index);
				setMessage("info","Rule has been removed. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

</cfcomponent>