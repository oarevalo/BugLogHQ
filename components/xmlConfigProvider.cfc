<cfcomponent>
	<cfset variables.configDoc = "">
	
	<cffunction name="init" access="public" returntype="xmlConfigProvider">
		<cfargument name="configDoc" type="string" required="true">	
		<cfset variables.configDoc = arguments.configDoc>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="load" access="public" returntype="struct">
		<cfscript>
			var cfg = structNew();
			var xmlDoc = xmlParse(expandPath(variables.configDoc));
			var xmlNode = 0;
			var i = 0;
			
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				cfg[xmlNode.xmlAttributes.name] = structNew();
				cfg[xmlNode.xmlAttributes.name].name = xmlNode.xmlAttributes.name;
				cfg[xmlNode.xmlAttributes.name].value = xmlNode.xmlText;
			}
			
			return cfg;
		</cfscript>
	</cffunction>

	<cffunction name="save" access="public" returntype="void">
		<cfargument name="configStruct" type="struct" required="true">
		<cfset var xmlDoc = xmlNew()>
		<cfset var cfg = arguments.configStruct>
		<cfset var xmlNode = 0>
		<cfset var formatter = createObject("component","xmlStringFormatter").init()>
		<cfset var keyList = listSort(structKeyList(cfg),"textnocase")>
		
		<cfscript>
			xmlDoc.xmlRoot = xmlELemNew(xmlDoc,"config");
			
			for(i=1;i lte listLen(keyList);i=i+1) {
				key = listGetAt(keyList,i);
				xmlNode = xmlElemNew(xmlDoc,"setting");
				xmlNode.xmlAttributes["name"] = cfg[key].name;
				xmlNode.xmlText = cfg[key].value;
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			}
		</cfscript>
		
		<cffile action="write" file="#expandPath(variables.configDoc)#" output="#formatter.makePretty(xmlDoc.xmlRoot)#">
	</cffunction>
	
</cfcomponent>