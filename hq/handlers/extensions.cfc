<cfcomponent extends="eventHandler">

	<cfset variables.extensionsXMLPath = "/bugLog/config/extensions-config.xml.cfm">

	<cffunction name="main" access="public" returntype="void">
		<cfscript>
			var appService = getService("app");
			
			try {
				panel = getValue("panel","rules");

				switch(panel) {
					case "rules":
						aActiveRules = appService.getActiveRules();
						setValue("aActiveRules", aActiveRules);
						break;
					case "history":
						qryHistory = appService.getExtensionsLog(user=getValue("currentUser"));
						setValue("qryHistory", qryHistory);
						break;
				}

				aRules = appService.getRules();
	
				setValue("hasExtensionsXMLFile", fileExists(expandPath(variables.extensionsXMLPath)));
				setValue("aRules", aRules);
				setValue("pageTitle", "Rules");
				setValue("panel", panel);
	
				setView("extensions");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("main");
			}
		</cfscript>
	</cffunction>

	<cffunction name="rule" access="public" returntype="void">
		<cfscript>
			var id = val(getValue("id"));
			var ruleName = getValue("ruleName","");
			var app = getService("app");
			var user = getValue("currentUser");

			try {
				if(id eq 0 and ruleName eq "") throw(type="validation", message="Please select a valid rule type");
				
				stRule = app.getRuleInfo(ruleName);
	
				setValue("qryApplications", app.getApplications(user));
				setValue("qryHosts", app.getHosts());
				setValue("qrySeverities", app.getSeverities());

				if(getValue("currentUser").getEmail() neq "")
					setValue("defaultEmail", getValue("currentUser").getEmail());
				else
					setValue("defaultEmail", app.getConfig().getSetting("general.adminEmail",""));

				setValue("stRule", stRule);
				setValue("id", id);
				setValue("ruleName", ruleName);
				if(id eq 0 ){
					setValue("sendEmailAlert", true);
					setValue("sendSlackAlert", false);
				}

				if(id gt 0) {
					setValue("aActiveRule", app.getRule(id,user));
				}

				setValue("pageTitle", "Rules > Add/Edit Rule");
				setView("extensions/edit");

			} catch(notAuthorized e) {
				setMessage("warning",e.message);
				setNextEvent("extensions.main");

			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("extensions.main");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("extensions.main");
			}
		</cfscript>
	</cffunction>

	<cffunction name="rulesLog" access="public" returntype="void">
		<cfscript>
			var logcontents = "";
			var logsdir = getValue("logsdir");
			var logpath = "";

			if(logsdir eq "") {
				if(structKeyExists(cookie,"logsdir"))
					logsdir = cookie.logsdir;
				else {
					logsdir = Server.ColdFusion.RootDir & "/logs/";
					writeCookie("logsdir",logsdir,180);
				}
			} else {
				writeCookie("logsdir",logsdir,180);
			}

			logpath = logsdir & "bugLog_ruleProcessor.log";

			if(fileExists(logpath))
				logcontents = fileRead(logpath,"utf-8");
			else 
				setMessage("warning","Cannot find rule Processor log file. Make sure you enter the correct path to your logs directory. It may also be that the log has not been created yet. The log file is automatically created once a rule is fired.");

			setValue("logcontents", logcontents);
			setValue("logsdir", logsdir);
			setValue("pageTitle", "Rules > View Log");
			setView("rulesLog");
		</cfscript>
	</cffunction>
		
	<cffunction name="doSaveRule" access="public" returntype="void">
		<cfscript>
			var args = {};
			var lstIgnoreFields = "event,fieldnames,btnSave";
			
			try {
				for(fld in form) {
					if(!listFindNoCase(lstIgnoreFields,fld)) {
						if(structKeyExists(form,fld & "_other")) {
							if(form[fld] eq "__OTHER__")
								args[fld] = form[fld & "_other"];
							else
								args[fld] = form[fld];
						} else if(listLast(fld,"_") eq "other" and structKeyExists(form,listDeleteAt(fld,listLen(fld,"_"),"_"))){
							// this is the 'other' field, ignore it
						} else {
							args[fld] = form[fld];
						}
					}
				}
				args.user = getValue("currentUser");
				getService("app").saveRule(argumentCollection = args);
				setMessage("info","Rule saved.");
			
			} catch(notAuthorized e) {
				setMessage("warning",e.message);
				
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("extensions.main");
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteRule" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var id = val(getValue("id"));
			
			try {
				getService("app").deleteRule(id, user);
				setMessage("info","Rule has been removed.");
			
			} catch(notAuthorized e) {
				setMessage("warning",e.message);
				
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("extensions.main");
		</cfscript>
	</cffunction>

	<cffunction name="doDisableRule" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var id = val(getValue("id"));
			
			try {
				getService("app").disableRule(id, user);
				setMessage("info","Rule has been disabled.");
			
			} catch(notAuthorized e) {
				setMessage("warning",e.message);
				
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("extensions.main");
		</cfscript>
	</cffunction>

	<cffunction name="doEnableRule" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var id = val(getValue("id"));
			
			try {
				getService("app").enableRule(id, user);
				setMessage("info","Rule has been enabled.");
			
			} catch(notAuthorized e) {
				setMessage("warning",e.message);
				
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("extensions.main");
		</cfscript>
	</cffunction>	

	<cffunction name="doMigrateExtensionsXML" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to do this"); setNextEvent("extensions.main");}
				if(!fileExists(expandPath(variables.extensionsXMLPath))) {
					setMessage("warning","The file '#variables.extensionsXMLPath#' could not be found.");
					setNextEvent("extensions.main");
				}
	
				// read file
				xmlDoc = xmlParse(expandPath(variables.extensionsXMLPath));

				// get rule definitions
				aNodes = xmlSearch(xmlDoc, "//rules/rule");
			
				for(i=1;i lte arrayLen(aNodes);i=i+1) {
					xmlNode = aNodes[i];
					
					// build rule info node
					st = structNew();
					st.ruleName = xmlNode.xmlAttributes.name;
					st.description = xmlNode.xmlText;
					st.enabled = true;
	
					// check the enabled/disabled flag; if not specified all rules are enabled by default
					if(structKeyExists(xmlNode.xmlAttributes,"enabled") and isBoolean(xmlNode.xmlAttributes.enabled) and not xmlNode.xmlAttributes.enabled)
						st.enabled = false;
					
					// each child of a rule tag becomes an argument for the rule constructor
					// this is how each rule instance is configured
					for(j=1;j lte arrayLen(xmlNode.xmlChildren);j=j+1) {
						xmlChildNode = xmlNode.xmlChildren[j];
						st[xmlChildNode.xmlName] = xmlChildNode.xmlText;
					}				
					
					getService("app").saveRule(argumentCollection = st);
				}
							
				// now delete file
				fileDelete(expandPath(variables.extensionsXMLPath));

				setMessage("info","Rules have been migrated.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("extensions.main");
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteExtensionsXML" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to do this"); setNextEvent("extensions.main");}
				if(fileExists(expandPath(variables.extensionsXMLPath))) {
					fileDelete(expandPath(variables.extensionsXMLPath));
				}
				setMessage("info","The extensions XML file has been deleted.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("extensions.main");
		</cfscript>
	</cffunction>

	<cffunction name="writeCookie" access="private">
		<cfargument name="name" type="string">
		<cfargument name="value" type="string">
		<cfargument name="expires" type="string">
		<cfcookie name="#arguments.name#" value="#arguments.value#" expires="#arguments.expires#">
	</cffunction>
		
</cfcomponent>