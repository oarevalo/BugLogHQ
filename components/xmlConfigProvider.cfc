<cfcomponent>
	<cfset variables.configDoc = "">
	<cfset variables.configKey = "">
	
	<!--- If we define the config key on a file in the config dir, then this is the filename we will look for --->
	<cfset variables.configKeyFilename = "serverkey.txt">

	<!--- If we defined the config key on the servlet context, then this is the parameter name --->
	<cfset variables.configKeyParameter = "serverkey">
	
	<cffunction name="init" access="public" returntype="xmlConfigProvider">
		<cfargument name="configDoc" type="string" required="true">	
		<cfargument name="configKey" type="string" required="false" default="">	
		<cfset var tempKey = "">
		<cfset variables.configDoc = arguments.configDoc>
		<cfset variables.configKey = arguments.configKey>

		<cfif variables.configKey neq "">
			<!--- check if the given key points to an existing file, if so then the file contents will be used as the key --->
			<cfif fileExists(variables.configKey)>
				<cfset variables.configKey = fileRead(variables.configKey,"utf-8")>
			<cfelseif fileExists(expandPath(variables.configKey))>
				<cfset variables.configKey = fileRead(expandPath(variables.configKey),"utf-8")>
			</cfif>
		<cfelseif fileExists(expandPath(getDirectoryfrompath(variables.configDoc) & variables.configKeyFilename))>
			<!--- this line checks the existence of a default text file containing the config key (must be on same directory as config file) --->
			<cfset variables.configKey = fileRead(expandPath(expandPath(getDirectoryfrompath(variables.configDoc) & variables.configKeyFilename)),"utf-8")>
		<cfelse>
			<!--- we will try also to see if the server key has been provided by the servlet context (yes, we are getting funky!) --->
		 	<cftry>
			 	<cfset tempKey = getPageContext().getServletContext().getInitParameter(variables.configKeyParameter) />
			 	<cfif isDefined("tempKey") and len(tempKey) gt 0>
					<cfset variables.configKey = tempKey />
				</cfif>
				<cfcatch type="any"><!--- key not defined ---></cfcatch>
			</cftry>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="load" access="public" returntype="struct">
		<cfscript>
			var cfg = structNew();
			var xmlDoc = xmlParse(expandPath(variables.configDoc));
			var xmlNode = 0;
			var xmlNodes = 0;
			var xmlChildNode = 0;
			var i = 0;
			var j = 0;
			
			// load general settings
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlName eq "setting") {
					cfg[xmlNode.xmlAttributes.name] = structNew();
					cfg[xmlNode.xmlAttributes.name].name = xmlNode.xmlAttributes.name;
					cfg[xmlNode.xmlAttributes.name].value = xmlNode.xmlText;
				}
			}
			
			// if there is a configkey defined, override general settings with then environment-specific settings
			if(variables.configKey neq "") {
				for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
					if(xmlNode.xmlName eq "envSettings") {
						for(j=1;j lte arrayLen(xmlNode.xmlChildren);j=j+1) {
							xmlChildNode = xmlNode.xmlChildren[j];
							cfg[xmlChildNode.xmlAttributes.name] = structNew();
							cfg[xmlChildNode.xmlAttributes.name].name = xmlChildNode.xmlAttributes.name;
							cfg[xmlChildNode.xmlAttributes.name].value = xmlChildNode.xmlText;
						}
					}
				}
			}

			return cfg;
		</cfscript>
	</cffunction>

	<cffunction name="save" access="public" returntype="void">
		<cfargument name="configStruct" type="struct" required="true">
		<cfscript>
			var xmlDoc = xmlParse(expandPath(variables.configDoc));
			var cfg = arguments.configStruct;
			var xmlNode = 0;
			var xmlNodes = 0;
			var i = 0;
			var childIndex = 0;
			var formatter = createObject("component","xmlStringFormatter").init();
			var keyList = listSort(structKeyList(cfg),"textnocase");
			var key = "";
		
			if(variables.configKey eq "") {
				for(i=1;i lte listLen(keyList);i=i+1) {
					key = listGetAt(keyList,i);

					xmlNodes = xmlSearch(xmlDoc,"/config/setting[@name='#cfg[key].name#']");
					if(arrayLen(xmlNodes)) {
						xmlNodes[1].xmlText = cfg[key].value;
					} else {
						xmlNode = xmlElemNew(xmlDoc,"setting");
						xmlNode.xmlAttributes["name"] = cfg[key].name;
						xmlNode.xmlText = cfg[key].value;
						arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
					}
				}
			} else {
				for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
					xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
					if(xmlNode.xmlName eq "envSettings" and xmlNode.xmlAttributes.name eq variables.configKey) {
						childIndex = i;
						break;
					}
				}
				
				if(childIndex gt 0) {
					for(i=1;i lte listLen(keyList);i=i+1) {
						key = listGetAt(keyList,i);
						xmlNodes = xmlSearch(xmlDoc,"/config/envSettings[@name='#variables.configKey#']/setting[@name='#cfg[key].name#']");
						if(arrayLen(xmlNodes)) {
							xmlNodes[1].xmlText = cfg[key].value;
						} else {
							xmlNodes = xmlSearch(xmlDoc,"/config/setting[@name='#cfg[key].name#']");
							if(!arrayLen(xmlNodes) or xmlNodes[1].xmlText neq cfg[key].value) {
								xmlNode = xmlElemNew(xmlDoc,"setting");
								xmlNode.xmlAttributes["name"] = cfg[key].name;
								xmlNode.xmlText = cfg[key].value;
								arrayAppend(xmlDoc.xmlRoot.xmlChildren[childIndex].xmlChildren, xmlNode);
							}
						}
					}
				}
			}

			fileWrite(expandPath(variables.configDoc), formatter.makePretty(xmlDoc.xmlRoot), "utf-8");
		</cfscript>
	</cffunction>
	
	<cffunction name="getConfigKey" access="public" returntype="string">
		<cfreturn  variables.configKey />
	</cffunction>
	
</cfcomponent>