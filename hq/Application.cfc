<cfcomponent displayname="Controller">
	
	<cfset this.name = "bugLogHQ"> 
	<cfset this.clientManagement = false> 
	<cfset this.sessionManagement = true> 
	<cfset this.setClientCookies = true>
	<cfset this.setDomainCookies = false>	

	<cfset this.appFrameworkVersion = "1.2">
	<cfset this.defaultEvent = "ehGeneral.dspMain">
	<cfset this.defaultView = "">
	<cfset this.defaultLayout = "Layout.Main">
	<cfset this.topLevelErrorRecipient = "">
	<cfset this.topLevelErrorSender = "">
	<cfset this.restartKey = "cookieMonster">
	<cfset this.configDoc = "config/config.xml.cfm">
	<cfset this.modelsPath = "">

	<cffunction name="onRequestStart">
		<cfparam name="Event" default="#this.defaultEvent#"> <!--- use to determine the action to perform --->
		<cfparam name="View" default="#this.defaultView#"> <!--- use to indicate which view to display --->
		<cfparam name="Layout" default="#this.defaultLayout#"> <!--- use to indicate which layout to use for the view --->
		<cfparam name="resetApp" default="false"> <!--- use to reset the application state --->
		
 		<cfscript>
			// Check that there is always a value for the view param
			if(view eq "" and event eq "") {
				view = this.defaultView;
				event = this.defaultEvent;
			}
			if(layout eq "") layout = this.defaultLayout;

			// create a structure to hold current request state
			reqState = duplicate(form);
			StructAppend(reqState, url);
			reqState.event = event;
			reqState.view = view;
			reqState.layout = layout;
			reqState["_modelsPath"] = this.modelsPath;

			// instantiate the general event handler
			appEventHandler = createObject("component","handlers.ehGeneral").init(reqState);

			// check restartKey
			resetApp = resetApp or (Not structKeyExists(application,"_restartKey") or application["_restartKey"] neq this.restartKey);

			// handle application initialization and re-initialization
			if(Not structKeyExists(application,"_appInited") or resetApp) {

				if(this.configDoc neq "") {
					// load configuration file
					xmlDoc = xmlParse(expandPath(this.configDoc));
	
					// load application settings
					loadApplicationSettings(xmlDoc);
	
					// load application services
					loadApplicationServices(xmlDoc);
				}

				// execute application-specific initialization tasks
				appEventHandler.onApplicationStart();
				
				// flag application as initialized
				application["_appInited"] = true;

				// replace restartKey (this flags current server as restarted)
				application["_restartKey"] = this.restartKey;
			}
			
			// call app's onRequestStart
			appEventHandler.onRequestStart();
			
			if(listLen(event,".") eq 2) {
				// Parse event handler
				eh_cfc = listFirst(event,".");
				eh_method = listLast(event,".");	

				// Instantiate the event handler
				myEventHandler = createObject("component","handlers.#eh_cfc#").init(reqState);
				
				// Call the selected method on the eventhandler, 
				// passing the request and request state structures.
				evaluate("myEventHandler.#eh_method#()");
			}

			// call app's onRequestEnd
			appEventHandler.onRequestEnd();

			// copy requestState structure to request scope so it can be used by the views and layouts
			request.requestState = reqState;
		</cfscript>
	</cffunction>
	
	<cffunction name="onRequest">
		<cfargument name="targetPage" type="String" required="true" />
		<cfinclude template="layouts/#request.requestState.layout#.cfm">
	</cffunction>
	
	<cffunction name="onError" returntype="void" output="true" hint="This method will handle all controller-level exceptions, or any other exceptions not handled by the eventHandler or the view.">
		<cfargument name="Exception" required="true" />
		<cfargument name="EventName" type="String" required="true" />	
		<cfset var error = 0>	
		<cfset var hostName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName()>

		<cfif structKeyExists(arguments.exception, "rootCause")>
			<cfset error = arguments.exception.rootCause>
			<cfif arguments.exception.rootCause.type eq "coldfusion.runtime.AbortException">
				<cfreturn>
			</cfif>
		<cfelse>
			<cfset error = arguments.exception>
		</cfif>
		
		<!--- notify administrator of the error --->
		<cfif this.topLevelErrorRecipient neq "" and this.topLevelErrorSender neq "">
			<cfmail to="#this.topLevelErrorRecipient#" 
					from="#this.topLevelErrorSender#" 
					subject="BUG REPORT: [#this.Name#] [#hostName#] #error.message#" 
					type="html"><cfdump var="#arguments.exception#"></cfmail>	
		</cfif>
						
		<!--- display a user-friendly error screen --->
		<cfinclude template="includes/error.cfm">
	</cffunction>
	
	<!--- Load Application Settings --->
	<cffunction name="loadApplicationSettings" access="private" returntype="void">
		<cfargument name="xmlConfig" type="XML" required="true">
		<cfscript>
			var i = 0;
			var xmlNode = 0;

			// initialize area for settings
			application["_appSettings"] = structNew();
	
			// read application settings
			if(structKeyExists(arguments.xmlConfig.xmlRoot,"settings")) {
				for(i=1;i lte arrayLen(arguments.xmlConfig.xmlRoot.settings.xmlChildren);i=i+1) {
					xmlNode = arguments.xmlConfig.xmlRoot.settings.xmlChildren[i];
					if(xmlNode.xmlName eq "setting") {
						application["_appSettings"][xmlNode.xmlAttributes.name] = xmlNode.xmlAttributes.value;
					}
				}
			}
		</cfscript>
	</cffunction>	

	<!--- Load Application Services --->
	<cffunction name="loadApplicationServices" access="private" returntype="void">
		<cfargument name="xmlConfig" type="XML" required="true">
		<cfscript>
			var i = 0;
			var j = 0;
			var xmlNode = 0;
			var stArguments = structNew();
			var oService = 0;
			
			// initialize area for services
			application["_appServices"] = structNew();

			// read application services
			if(structKeyExists(arguments.xmlConfig.xmlRoot,"services")) {
				for(i=1;i lte arrayLen(arguments.xmlConfig.xmlRoot.services.xmlChildren);i=i+1) {
					xmlNode = arguments.xmlConfig.xmlRoot.services.xmlChildren[i];
					if(xmlNode.xmlName eq "service") {
						stArguments = structNew();
						oService = 0;
	
						// create the argument collection for the init method
						for(j=1;j lte arrayLen(xmlNode.xmlChildren);j=j+1) {
							if( xmlNode.xmlChildren[j].xmlName eq "init-param" ) {
								// check if the parameter value is binded to an application setting
								if(structKeyExists(xmlNode.xmlChildren[j].xmlAttributes,"settingName")) {
									stArguments[ xmlNode.xmlChildren[j].xmlAttributes.name ] = application["_appSettings"][xmlNode.xmlChildren[j].xmlAttributes.settingName];
								} else {
									// append to argument collection
									stArguments[ xmlNode.xmlChildren[j].xmlAttributes.name ] = xmlNode.xmlChildren[j].xmlText;
								}
							}
						}
	
						// instantiate service
						if( (xmlNode.xmlAttributes.class DOES NOT CONTAIN ".") OR ((xmlNode.xmlAttributes.class CONTAINS ".") AND (xmlNode.xmlAttributes.class DOES NOT CONTAIN "/") AND (xmlNode.xmlAttributes.class DOES NOT CONTAIN "\")) ) {
							// class is a regular cfc path
							oService = createObject("component", xmlNode.xmlAttributes.class);
						} else {
							// class is a relative path
							oProxy = createObject("java", "coldfusion.runtime.TemplateProxyFactory");
							oFile = createObject("java", "java.io.File").init( expandPath(xmlNode.xmlAttributes.class) );
							oService = oProxy.resolveFile(getPageContext(), oFile);
						}

						// initialize service
						oService = oService.init(argumentCollection = stArguments);
	
						// add service instance into application scope
						application["_appServices"][xmlNode.xmlAttributes.name] = oService;
					}
				}
			}
		</cfscript>	
	</cffunction>
</cfcomponent>
