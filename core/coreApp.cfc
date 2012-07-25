<cfcomponent>
	<!---
		'Core' framework (v 1.4.2) 
		by Oscar Arevalo (oarevalo@gmail.com - http://www.oscararevalo.com)

		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at
		
		    http://www.apache.org/licenses/LICENSE-2.0
		
		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.
	--->

	<!-------- Configurable Framework Settings ------------->
	<cfset this.mainHandler = "">
	<cfset this.defaultEvent = "">
	<cfset this.defaultLayout = "">
	<cfset this.errorHandler = "">
	<cfset this.restartKey = "">
	<cfset this.configDoc = "">

	<cfset this.dirs.core = "core">
	<cfset this.dirs.handlers = "">
	<cfset this.dirs.layouts = "">
	<cfset this.dirs.views = "">
	<cfset this.dirs.modules = "">

	<cfset this.paths.app = getDirectoryFromPath(cgi.script_name)>
	<cfset this.paths.core = "">
	<cfset this.paths.coreImages = "">
	<cfset this.paths.error = "">
	<cfset this.paths.message = "">
	<cfset this.paths.handlers = "">
	<cfset this.paths.layouts = "">
	<cfset this.paths.views = "">
	<cfset this.paths.modules = "">
	<cfset this.paths.config = "">
	<!------------------------------------------------------>

	<!------- Application scope keys --------->
	<cfset this.app_key = "_core">
	<cfset this.APP_KEYS.SERVICES = "services">
	<cfset this.APP_KEYS.SETTINGS = "settings">
	<cfset this.APP_KEYS.PATHS = "paths">
	<!---------------------------------------->

	<cffunction name="onRequestStart" access="public" hint="This contains the actual front controller logic">
		<cfset var appEventHandler = 0>
		<cfset var reqState = structNew()>
		
		<cfparam name="event" default=""> <!--- use to determine the action to perform --->
		<cfparam name="resetApp" default="false"> <!--- use to reset the application state --->
		
 		<cfscript>
			// Check that there is always a value for the event param
			if(event eq "") event = this.defaultEvent;

			// Check application reset conditions
			resetApp = resetApp 
						or not structKeyExists(application,this.app_key) 
						or not structKeyExists(application[this.app_key],"initFlag")
						or (
							structKeyExists(application[this.app_key],"initFlag")
							and application[this.app_key].initFlag neq this.restartKey
						);

			// make sure all paths are in good shape
			normalizePaths();

			// create a structure to hold current request state
			reqState = duplicate(form);
			StructAppend(reqState, url);

			// add reference to requestState structure to request scope so it can be used by views and layouts
			request.requestState = reqState;
			
			// set initial values in reqState
			reqState.event = event;
			reqState.layout = this.defaultLayout;
			reqState.view = "";
			reqState.module = "";
			reqState._coreImagesPath = this.paths.coreImages;
			
			// Handle request lifecycle (this is different depending on whether there is a main handler or not)
			if(this.mainHandler neq "") {
				// instantiate the general event handler
				appEventHandler = createObject("component", this.paths.handlers & this.mainHandler).init(reqState);
				if(resetApp) startApplication(appEventHandler);		// handle application initialization and re-initialization
				if(structKeyExists(appEventHandler,"onRequestStart")) appEventHandler.onRequestStart();
				runEventHandler(reqState);							// execute requested event
				if(structKeyExists(appEventHandler,"onRequestEnd")) appEventHandler.onRequestEnd();

			} else {
				if(resetApp) startApplication();
				runEventHandler(reqState);
			}

			// define paths to the view and template
			reqState.viewTemplatePath = getViewTemplatePath(reqState);
			reqState.layoutTemplatePath = getLayoutTemplatePath(reqState);
			reqState.messageTemplatePath = this.paths.message;
		</cfscript>
	</cffunction>
	
	<cffunction name="onError" returntype="void" output="true" hint="This method will handle all controller-level exceptions, or any other exceptions not handled by the eventHandler or the view.">
		<cfargument name="Exception" required="true" />
		<cfargument name="EventName" type="String" required="true" />	
		<cfscript>
			var error = arguments.exception;
			var rs = structNew();

			if(structKeyExists(arguments.exception, "rootCause")) {
				error = arguments.exception.rootCause;
				if(arguments.exception.rootCause.type eq "coldfusion.runtime.AbortException") {
					return;
				}
			}
			
			if(this.errorHandler neq "") {
				if(structKeyExists(request,"requestState")) rs = request.requestState;
				rs.exception = error;
				runEventHandler(rs, this.errorHandler);
				rs.viewTemplatePath = getViewTemplatePath(rs);
				rs.layoutTemplatePath = getLayoutTemplatePath(rs);
				rs.messageTemplatePath = this.paths.message;
				return;
			}
		</cfscript>
		
		<!--- display a user-friendly error screen --->
		<cfif this.paths.error neq "">
			<cfinclude template="#this.paths.error#">
		</cfif>

		<cfabort>
	</cffunction>
	
	
	<!--- Do application startup --->
	<cffunction name="startApplication" access="private" returntype="void" hint="This method handles the application startup tasks">
		<cfargument name="appHandler" type="any" required="false" default="">
		<cfset var xmlDoc = 0>

		<cflock name="frAppStart_#application.applicationName#" type="exclusive" timeout="10">
			<cfscript>
				application[this.app_key] = structNew();
				
				if(this.paths.config neq "") {
					// load configuration file
					xmlDoc = xmlParse(expandPath(this.paths.config));
	
					// load application settings
					loadApplicationSettings(xmlDoc);
	
					// load application services
					loadApplicationServices(xmlDoc);
				}

				// store resolved paths in app scope
				application[this.app_key][this.APP_KEYS.PATHS] = this.paths;
	
				// execute application-specific initialization tasks
				if(isObject(arguments.appHandler) and structKeyExists(arguments.appHandler,"onApplicationStart")) 
					arguments.appHandler.onApplicationStart();
				
				// flag application as initialized using restartKey value
				application[this.app_key].initFlag = this.restartKey;
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Execute Event Handler --->
	<cffunction name="runEventHandler" access="public" returntype="void" hint="This method is in charge of executing the requested event">
		<cfargument name="reqState" type="struct" required="true">
		<cfargument name="overrideEvent" type="string" required="false" default="">
		<cfscript>
			var oEventHandler = 0; var event = "";
			var eh_cfc = ""; var eh_path = ""; var eh_method = "";
						
			if(structKeyExists(arguments.reqState,"event")) event = arguments.reqState.event;
			if(arguments.overrideEvent neq "") event = arguments.overrideEvent;

			switch(listLen(event,".")) {
				case 1:
					eh_path = this.paths.handlers;
					eh_cfc = this.mainHandler;
					eh_method = event;
					break;
				case 2:
					eh_path = this.paths.handlers;
					eh_cfc = listFirst(event,".");
					eh_method = listLast(event,".");
					break;
				case 3:
					arguments.reqState.module = listFirst(event,".");
					eh_path = this.paths.modulesDot & arguments.reqState.module & ".handlers.";
					eh_cfc = listGetAt(event,2,".");
					eh_method = listLast(event,".");
					break;
			}
		</cfscript>
		<cfif eh_cfc neq "">
			<!--- Call the selected method on the eventhandler --->
			<cfset oEventHandler = createObject("component", eh_path & eh_cfc).init(arguments.reqState)>
			<cfinvoke component="#oEventHandler#" method="#eh_method#">
		</cfif>
	</cffunction>
	
	<!--- Load Application Settings --->
	<cffunction name="loadApplicationSettings" access="private" returntype="void" hint="Sets the application settings declared on the config document">
		<cfargument name="xmlConfig" type="XML" required="true">
		<cfscript>
			var i = 0;
			var xmlNode = 0;

			// initialize area for settings
			application[this.app_key][this.APP_KEYS.SETTINGS] = structNew();
	
			// read application settings
			if(structKeyExists(arguments.xmlConfig.xmlRoot,"settings")) {
				for(i=1;i lte arrayLen(arguments.xmlConfig.xmlRoot.settings.xmlChildren);i=i+1) {
					xmlNode = arguments.xmlConfig.xmlRoot.settings.xmlChildren[i];
					if(xmlNode.xmlName eq "setting") {
						if(xmlNode.xmlAttributes.value eq "$APP_PATH") xmlNode.xmlAttributes.value = this.paths.app;
						application[this.app_key][this.APP_KEYS.SETTINGS][xmlNode.xmlAttributes.name] = xmlNode.xmlAttributes.value;
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
			application[this.app_key][this.APP_KEYS.SERVICES] = structNew();

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
									stArguments[ xmlNode.xmlChildren[j].xmlAttributes.name ] = application[this.app_key][this.APP_KEYS.SETTINGS][xmlNode.xmlChildren[j].xmlAttributes.settingName];

								} else if(structKeyExists(xmlNode.xmlChildren[j].xmlAttributes,"serviceName")) {
									stArguments[ xmlNode.xmlChildren[j].xmlAttributes.name ] = application[this.app_key][this.APP_KEYS.SERVICES][xmlNode.xmlChildren[j].xmlAttributes.serviceName];

								} else {
									// append to argument collection
									if(trim(xmlNode.xmlChildren[j].xmlText) eq "$APP_PATH") xmlNode.xmlChildren[j].xmlText = this.paths.app;
									stArguments[ xmlNode.xmlChildren[j].xmlAttributes.name ] = trim(xmlNode.xmlChildren[j].xmlText);
								}
							}
						}
	
						// instantiate service
						oService = createObject("component", xmlNode.xmlAttributes.class);

						// initialize service
						oService.init(argumentCollection = stArguments);
	
						// add service instance into application scope
						application[this.app_key][this.APP_KEYS.SERVICES][xmlNode.xmlAttributes.name] = oService;
					}
				}
			}
		</cfscript>	
	</cffunction>

	<!--- Compose Path To View Template --->
	<cffunction name="getViewTemplatePath" access="private" returntype="string" hint="Returns the full path to the template corresponding to the requested view">
		<cfargument name="reqState" type="struct" required="true">
		<cfscript>
			var viewPath = "";
			
			if(arguments.reqState.view neq "") {
				if(arguments.reqState.module neq "") {
					viewPath = this.paths.modules & arguments.reqState.module & "/views/" & arguments.reqState.view & ".cfm";
				} else {
					viewPath = this.paths.views & arguments.reqState.view & ".cfm";
				}
			}
			
			return viewPath;
		</cfscript>
	</cffunction>

	<!--- Compose Path To Layout Template --->
	<cffunction name="getLayoutTemplatePath" access="private" returntype="string" hint="Returns the full path to the template corresponding to the requested layout">
		<cfargument name="reqState" type="struct" required="true">
		<cfscript>
			var layoutPath = "";
			
			if(arguments.reqState.layout neq "") {
				layoutPath = this.paths.layouts & request.requestState.layout & ".cfm";
			}
			
			return layoutPath;
		</cfscript>
	</cffunction>

	<!--- Normalize all paths --->
	<cffunction name="normalizePaths" access="private" returntype="void" hint="Modify all paths so that they are in a canonical form and ready to use">
		<cfscript>
			// base application path
			if(right(this.paths.app,1) neq "/") this.paths.app = this.paths.app & "/";

			// core-related paths
			if(this.paths.core eq "") this.paths.core = this.paths.app & this.dirs.core;
			if(this.paths.coreImages eq "") this.paths.coreImages = this.paths.core & "/images";
			if(this.paths.error eq "") this.paths.error = this.paths.core & "/includes/error.cfm";
			if(this.paths.message eq "") this.paths.message = this.paths.core & "/includes/message.cfm";

			// application elements paths
			if(this.paths.handlers eq "") this.paths.handlers = this.paths.app & this.dirs.handlers;
			if(this.paths.layouts eq "") this.paths.layouts = this.paths.app & this.dirs.layouts;
			if(this.paths.views eq "") this.paths.views = this.paths.app & this.dirs.views;
			if(this.paths.modules eq "") this.paths.modules = this.paths.app & this.dirs.modules;
			if(this.paths.config eq "" and this.configDoc neq "") this.paths.config = this.paths.app & this.configDoc;
			
			// make sure all paths end with a trailing slash
			if(this.paths.modules neq "" and right(this.paths.modules,1) neq "/") this.paths.modules = this.paths.modules & "/";
			if(this.paths.layouts neq "" and right(this.paths.layouts,1) neq "/") this.paths.layouts = this.paths.layouts & "/";
			if(this.paths.views neq "" and right(this.paths.views,1) neq "/") this.paths.views = this.paths.views & "/";

			// make sure the handlers path is in dot notation
			this.paths.handlers = replace(this.paths.handlers,"/",".","all");
			if(this.paths.handlers eq ".") this.paths.handlers = "";
			if(this.paths.handlers neq "") {
				if(left(this.paths.handlers,1) eq ".") this.paths.handlers = right(this.paths.handlers,len(this.paths.handlers)-1);
				if(right(this.paths.handlers,1) neq ".") this.paths.handlers = this.paths.handlers & "."; 
			}

			// convert modules path to a valid dot notation
			this.paths.modulesDot = replace(this.paths.modules,"/",".","ALL");
			if(this.paths.modulesDot eq ".") this.paths.modulesDot = "";
			if(this.paths.modulesDot neq "") {
				if(left(this.paths.modulesDot,1) eq ".") this.paths.modulesDot = right(this.paths.modulesDot,len(this.paths.modulesDot)-1);
				if(right(this.paths.modulesDot,1) neq ".") this.paths.modulesDot = this.paths.modulesDot & "."; 
			}
		</cfscript>
	</cffunction>

</cfcomponent>
