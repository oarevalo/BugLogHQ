<cfcomponent displayname="Controller">
	
	<!--- Application settings --->
	<cfset this.name = "bugLogHQ"> 
	<cfset this.clientManagement = false> 
	<cfset this.sessionManagement = true> 
	<cfset this.setClientCookies = true>
	<cfset this.setDomainCookies = false>	

	<!--- Framework settings --->
	<cfset this.appFrameworkVersion = "1.3">
	<cfset this.defaultEvent = "ehGeneral.dspMain">
	<cfset this.defaultLayout = "Layout.Main">
	<cfset this.topLevelErrorRecipient = "">
	<cfset this.topLevelErrorSender = "">
	<cfset this.restartKey = "cookieMonster">
	<cfset this.configDoc = "config.xml.cfm">
	<cfset this.modulesPath = "">
	<cfset this.emailErrors = false>

	<!--- Define mappings and custom tag paths --->
	<cfset this.customTagPaths = getDirectoryFromPath(getcurrenttemplatepath()) & "customTags">
	<cfset this.mappings["/config"] = getDirectoryFromPath(getcurrenttemplatepath()) & "config">
	<cfset this.mappings["/handlers"] = getDirectoryFromPath(getcurrenttemplatepath()) & "handlers">
	<cfset this.mappings["/layouts"] = getDirectoryFromPath(getcurrenttemplatepath()) & "layouts">
	<cfset this.mappings["/views"] = getDirectoryFromPath(getcurrenttemplatepath()) & "views">

	<cffunction name="onRequestStart">
		<cfparam name="Event" default=""> <!--- use to determine the action to perform --->
		<cfparam name="resetApp" default="false"> <!--- use to reset the application state --->
 		<cfscript>
			// Check that there is always a value for the event param
			if(event eq "") event = this.defaultEvent;

			// Check application reset conditions
			resetApp = resetApp or (Not structKeyExists(application,"_restartKey") or application["_restartKey"] neq this.restartKey);

			// create a structure to hold current request state
			reqState = duplicate(form);
			StructAppend(reqState, url);
			
			// set initial values in reqState
			reqState.event = event;
			reqState.layout = this.defaultLayout;
			reqState.view = "";
			reqState.module = "";

			// instantiate the general event handler
			appEventHandler = createObject("component", "handlers.ehGeneral").init(reqState);

			// handle application initialization and re-initialization
			if(Not structKeyExists(application,"_appInited") or resetApp) 
				startApplication(appEventHandler);
			
			// call app's onRequestStart
			appEventHandler.onRequestStart();
			
			// execute requested event
			runEventHandler(reqState);

			// call app's onRequestEnd
			appEventHandler.onRequestEnd();

			// define path to the view template
			reqState.viewTemplatePath = getViewTemplatePath(reqState);

			// copy requestState structure to request scope so it can be used by the views and layouts
			request.requestState = reqState;
		</cfscript>
	</cffunction>
	
	<cffunction name="onRequest">
		<cfargument name="targetPage" type="String" required="true" />
		<cfif request.requestState.layout neq "">
			<cfinclude template="/layouts/#request.requestState.layout#.cfm">
		<cfelse>
			<cfinclude template="#targetPage#">
		</cfif>
	</cffunction>
	
	<cffunction name="onError" returntype="void" output="true" hint="This method will handle all controller-level exceptions, or any other exceptions not handled by the eventHandler or the view.">
		<cfargument name="Exception" required="true" />
		<cfargument name="EventName" type="String" required="true" />	
		<cfset var error = arguments.exception>	
		<cfset var hostName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName()>

		<cfif structKeyExists(arguments.exception, "rootCause")>
			<cfset error = arguments.exception.rootCause>
			<cfif arguments.exception.rootCause.type eq "coldfusion.runtime.AbortException">
				<cfreturn>
			</cfif>
		</cfif>
		
		<!--- notify administrator of the error --->
		<cfif this.emailErrors and this.topLevelErrorRecipient neq "">
			<cfmail to="#this.topLevelErrorRecipient#" 
					from="#this.topLevelErrorSender#" 
					subject="BUG REPORT: [#this.Name#] [#hostName#] #error.message#" 
					type="html"><cfdump var="#arguments.exception#"></cfmail>	
		</cfif>
						
		<!--- display a user-friendly error screen --->
		<cfinclude template="includes/error.cfm">
		
		<!--- stop execution --->
		<cfabort>
	</cffunction>
	
	
	<!--- Do application startup --->
	<cffunction name="startApplication" access="private" returntype="void" hint="This method handles the application startup tasks">
		<cfargument name="appHandler" type="any" required="true">
		<cfset var xmlDoc = 0>

		<cflock name="frAppStart_#this.name#" type="exclusive" timeout="10">
			<cfscript>
				if(this.configDoc neq "") {
					// load configuration file
					xmlDoc = xmlParse(expandPath("/config/" & this.configDoc));
	
					// load application settings
					loadApplicationSettings(xmlDoc);
	
					// load application services
					loadApplicationServices(xmlDoc);
				}
	
				// execute application-specific initialization tasks
				arguments.appHandler.onApplicationStart();
				
				// flag application as initialized
				application["_appInited"] = true;
	
				// replace restartKey (this flags current server as restarted)
				application["_restartKey"] = this.restartKey;
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Execute Event Handler --->
	<cffunction name="runEventHandler" access="private" returntype="void" hint="This method is in charge of executing the requested event">
		<cfargument name="reqState" type="struct" required="true">
		<cfscript>
			var oEventHandler = 0;
			var eh_cfc = ""; var eh_path = "";
			var rq = arguments.reqState;
			var mp = "";

			if(listLen(rq.event,".") gte 2 and listLen(rq.event,".") lte 3) {
				
				// convert modulesPath to a valid dot notation
				mp = replace(this.modulesPath,"/",".","ALL");
				if(left(mp,1) eq ".") mp = right(mp,len(mp)-1);
				if(right(mp,1) neq ".") mp = mp & ".";
				
				// Parse event handler
				if(listLen(rq.event,".") eq 2) {
					eh_cfc = listFirst(rq.event,".");
					eh_path = "handlers.";
					
				} else if(listLen(rq.event,".") eq 3) {
					rq.module = listFirst(rq.event,".");
					eh_cfc = listGetAt(rq.event,2,".");
					eh_path = mp & rq.module & ".handlers.";
				}
				
				// Instantiate the event handler
				oEventHandler = createObject("component", eh_path & eh_cfc).init(rq);
			
				// Call the selected method on the eventhandler
				evaluate("oEventHandler." & listLast(rq.event,".") & "()");
			}		
		</cfscript>
	</cffunction>
	
	<!--- Load Application Settings --->
	<cffunction name="loadApplicationSettings" access="private" returntype="void" hint="Sets the application settings declared on the config document">
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
	<cffunction name="loadApplicationServices" access="private" returntype="void" hint="Loads instances of the application services declared on the config document">
		<cfargument name="xmlConfig" type="XML" required="true">
		<cfscript>
			var i = 0; var j = 0;
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

								} else if(structKeyExists(xmlNode.xmlChildren[j].xmlAttributes,"serviceName")) {
									stArguments[ xmlNode.xmlChildren[j].xmlAttributes.name ] = application["_appServices"][xmlNode.xmlChildren[j].xmlAttributes.serviceName];

								} else {
									// append to argument collection
									stArguments[ xmlNode.xmlChildren[j].xmlAttributes.name ] = xmlNode.xmlChildren[j].xmlText;
								}
							}
						}
	
						// instantiate service
						oService = createObject("component", xmlNode.xmlAttributes.class);

						// initialize service
						oService.init(argumentCollection = stArguments);
	
						// add service instance into application scope
						application["_appServices"][xmlNode.xmlAttributes.name] = oService;
					}
				}
			}
		</cfscript>	
	</cffunction>

	<!--- Compose Path To View Template --->
	<cffunction name="getViewTemplatePath" access="private" returntype="string" hint="Returns the full path to the template corresponding to the requested view">
		<cfargument name="reqState" type="struct" required="true">
		<cfscript>
			var basePath = "";
			var viewPath = "";
			
			if(arguments.reqState.view neq "") {
				if(arguments.reqState.module neq "")
					basePath = this.modulesPath & "/" & arguments.reqState.module;
				viewPath = basePath & "/views/" & arguments.reqState.view & ".cfm";
			}
			
			return viewPath;
		</cfscript>
	</cffunction>

</cfcomponent>
