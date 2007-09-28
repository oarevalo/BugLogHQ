<cfcomponent displayName="extensionsService" hint="This component provides interaction with the extensions mechanism for buglog">
	
	<!--- this is the location of where the extensions are defined --->
	<cfset variables.configDocHREF = "/bugLog/extensions/extensions.xml">
	
	<!--- this is the path to the extensions components --->
	<cfset variables.extensionsPath = "bugLog.extensions.">
	
	
	<cffunction name="init" access="public" returnType="extensionsService">
		
		<cfscript>
			// load the config doc			
			xmlDoc = expandPath(variables.configDocHREF);
	
			// read and parse the different types of extensions
			variables.aRules = parseRules(xmlDoc);
		</cfscript>
						
		<cfreturn this>
	</cffunction>

	<cffunction name="getRules" access="public" returntype="array">
		<cfreturn variables.aRules>
	</cffunction>

	<cffunction name="parseRules" access="private" returntype="Array">
		<cfargument name="xmlDoc" type="xML" required="true">
		
		<cfscript>
			var aNodes = 0;
			var i = 0; var j = 0;
			var st = structNew();
			var xmlNode = 0; var xmlChildNode = 0;
			var aReturn = arrayNew(1);
			
			// get rule definitions
			aNodes = xmlSearch(arguments.xmlDoc, "//rules/rule");
		
			for(i=1;i lte arrayLen(aNodes);i=i+1) {
				xmlNode = aNodes[i];
				
				// build rule info node
				st = structNew();
				st.component = variables.extensionsPath & "rules." & xmlNode.xmlAttributes.name;
				st.config = structNew();
				
				// each child of a rule tag becomes an argument for the rule constructor
				// this is how each rule instance is configured
				for(j=1;j lte arrayLen(xmlNode.xmlChildren);j=j+1) {
					xmlChildNode = xmlNode.xmlChildren[j];
					st.config[xmlChildNode.xmlName] = xmlChildNode.xmlText;
				}				
				
				// append info struct to returning array
				arrayAppend(aReturn, duplicate(st));
			}
			
			return aReturn;
		</cfscript>		
	</cffunction>

</cfcomponent>