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
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to create or modify a rule"); setNextEvent("ehExtensions.dspMain");}
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
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to delete a rule"); setNextEvent("ehExtensions.dspMain");}
				getService("app").deleteRule(index);
				setMessage("info","Rule has been removed. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doDisableRule">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to enable or disable a rule"); setNextEvent("ehExtensions.dspMain");}
				getService("app").disableRule(index);
				setMessage("info","Rule has been disabled. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doEnableRule">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to enable or disable a rule"); setNextEvent("ehExtensions.dspMain");}
				getService("app").enableRule(index);
				setMessage("info","Rule has been enabled. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>	
	
</cfcomponent>