<cfcomponent extends="dataProvider">
	<cfset variables.dataProviderType = "xml">
	
	<cffunction name="get" access="public" returntype="query">
		<cfargument name="id" type="any" required="true">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfscript>
			var xmlDoc = readXMLDoc(arguments._mapTableInfo, arguments._mapColumns);
			var aNodes = xmlSearch(xmlDoc,"//record[@ID='#arguments.id#']");
			var lstFields = structKeyList(arguments._mapColumns);
			var aFields = listToArray(lstFields);
			var qry = 0;
			var i = 0;
			var fld = "";
			var pkName = arguments._mapTableInfo.pkName;
			
			qry = queryNew(listAppend(lstFields,pkName));
			
			if(arrayLen(aNodes) gt 0) {
				queryAddRow(qry,1);
				querySetCell(qry,pkName,aNodes[1].xmlAttributes.ID);
				for(i=1;i lte arrayLen(aFields);i=i+1) {
					fld = aFields[i];
					if(structKeyExists(aNodes[1],fld))
						querySetCell(qry,fld,aNodes[1][fld].xmlText);
					else
						querySetCell(qry,fld,"");
				}
			}	
			
			return qry;		
		</cfscript>
	</cffunction>

	<cffunction name="getAll" returntype="query" access="public">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfscript>
			var xmlDoc = readXMLDoc(arguments._mapTableInfo, arguments._mapColumns);
			var lstFields = structKeyList(arguments._mapColumns);
			var pkName = arguments._mapTableInfo.PKName;
			var qry = QueryNew(listAppend(lstFields, pkName));
			var aFields = listToArray(lstFields);
			var i = 0;
			var j = 0;
			var xmlNode = 0;

			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				queryAddRow(qry);
				querySetCell(qry, pkName, xmlNode.xmlAttributes.id);

				for(j=1;j lte arrayLen(aFields);j=j+1) {

					if(structKeyExists(xmlNode, aFields[j])) {
						querySetCell(qry, aFields[j], xmlNode[aFields[j]].xmlText);
					}

				}			
			}
			
			return qry;
		</cfscript>
	</cffunction>
	
	<cffunction name="delete" returntype="void" access="public">
		<cfargument name="ID" type="any" required="true">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		
		<cfscript>
			var i = 0;
			var xmlNode = 0;
			var xmlDoc = readXMLDoc(arguments._mapTableInfo, arguments._mapColumns);
			
			for(i=1;i lte arrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlAttributes.ID eq arguments.ID) {
					arrayDeleteAt(xmlDoc.xmlRoot.xmlChildren, i);
					break;
				}
			}
			
			writeXMLDoc(arguments._mapTableInfo, xmlDoc);
		</cfscript>
	</cffunction>
	
	<cffunction name="save" returntype="any" access="public">
		<cfargument name="ID" type="any" required="true">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		
		<cfscript>
			var stTblColumns = arguments._mapColumns;
			var stTableInfo = arguments._mapTableInfo;
			var stColumns = structNew();
			var arg = "";
			var theID = arguments.id;
			var pkName = arguments._mapTableInfo.PKName;
			var xmlDoc = readXMLDoc(arguments._mapTableInfo, arguments._mapColumns);

			structDelete(arguments, pkName, false);
			structDelete(arguments, "_mapTableInfo", false);
			structDelete(arguments, "_mapColumns", false);
			
			for(arg in arguments) {
				if(structKeyExists(stTblColumns,arg)) {
					stColumns[arg] = duplicate(stTblColumns[arg]);
					stColumns[arg].value = arguments[arg];
				} 
			}			

			if(val(theID) eq 0) {
				st = _insertRow(stTableInfo, stColumns, xmlDoc);
				theID = st.ID;
				xmlDoc = st.xmlDoc;
			} else
				xmlDoc = _updateRow(theID, stColumns, xmlDoc);

	
			writeXMLDoc(stTableInfo, xmlDoc);
	
			return theID;
		</cfscript>
	</cffunction>

	<cffunction name="search" returntype="query" access="public">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfset var qry = getAll(arguments._mapTableInfo, arguments._mapColumns)>		
		<cfset var key = "">
		<cfset var stColumns = arguments._mapColumns>
	
		<cfquery name="qry" dbtype="query">
			SELECT *
			FROM qry
			WHERE (1=1)
				<cfloop collection="#arguments#" item="key">
					<cfif structKeyExists(stColumns,key)>
						and cast(#key# as varchar) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments[key]#">
					</cfif>
				</cfloop>
		</cfquery>

		<cfreturn qry>
	</cffunction>

	<cffunction name="exec" returntype="query" access="public">
		<cfargument name="sql" type="string" required="true">
		<cfthrow message="Exec is not supported in XMLDataProvider">
	</cffunction>

	<!---- Private Methods ---->	
	<cffunction name="readXMLDoc" access="private" returntype="xml">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		
		<cfset var xmlDoc = xmlNew()>
		<cfset var tableName = arguments._mapTableInfo.tableName>
		<cfset var xmlDocURL = variables.oConfigBean.getDataRoot() & "/" & tableName & ".xml">
		
		<cfif fileExists(expandPath(xmlDocURL))>
			<cflock name="#hash(xmlDocURL)#" type="exclusive" timeout="10">
				<cfset xmlDoc = xmlParse(expandPath(xmlDocURL))>
			</cflock>
		<cfelse>
			<cfset xmlDoc.xmlRoot = xmlElemNew(xmlDoc,"data")>
		</cfif>

		<cfreturn xmlDoc>
	</cffunction>

	<cffunction name="writeXMLDoc" access="private" returntype="void">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="xmlDoc" type="xml" required="true">
		<cfset var tableName = arguments._mapTableInfo.tableName>
		<cfset var xmlDocURL = variables.oConfigBean.getDataRoot() & "/" & tableName & ".xml">
		<cflock name="#hash(xmlDocURL)#" type="exclusive" timeout="10">
			<cffile action="write" file="#expandPath(xmlDocURL)#" output="#toString(arguments.xmlDoc)#">
		</cflock>
	</cffunction>
	

	<cffunction name="_insertRow" access="private" returntype="struct">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="columns" required="true" type="struct">
		<cfargument name="xmlDoc" type="xml" required="true">

		<cfscript>
			var xmlNode = 0;
			var lstFields = structKeyList(arguments.columns);
			var aFields = listToArray(lstFields);
			var ID = 1;
			var stRet = structNew();
			var lockName = "xmlDataProvider_insert_#arguments._mapTableInfo.tableName#";
		</cfscript>

		<cflock name="#lockName#" type="exclusive" timeout="10">
			<cfscript>
				// check if we have a current sequence number
				if(structKeyExists(arguments.xmlDoc.xmlRoot.xmlAttributes,"current_seq")) {
					ID = val(arguments.xmlDoc.xmlRoot.xmlAttributes.current_seq) + 1;
				}
				
				// update sequence number
				arguments.xmlDoc.xmlRoot.xmlAttributes["current_seq"] = ID;

				// create new node
				xmlNode = xmlElemNew(arguments.xmlDoc,"record");
				xmlNode.xmlAttributes["ID"] = ID;
	
				for(i=1;i lte arrayLen(aFields);i=i+1) {
					xmlFieldNode = xmlElemNew(arguments.xmlDoc, aFields[i]);

					col = arguments.columns[aFields[i]];
					if(col.cfsqltype eq "cf_sql_timestamp" or col.cfsqltype eq "cf_sql_date")
						col.value = dateFormat(col.value,"mm/dd/yyyy") & " " & timeFormat(col.value,"HH:mm:ss");
					xmlFieldNode.xmlText = col.value;
					arrayAppend(xmlNode.xmlChildren, xmlFieldNode);
				}
	
				arrayAppend(arguments.xmlDoc.xmlRoot.xmlChildren, xmlNode);
			</cfscript>
		</cflock>		

		<cfset stRet.ID = ID>
		<cfset stRet.xmlDoc = arguments.xmlDoc>			
		
		<cfreturn stRet>
	</cffunction>			

	<cffunction name="_updateRow" access="private">
		<cfargument name="id" type="any" required="true">
		<cfargument name="columns" required="true" type="struct">
		<cfargument name="xmlDoc" type="xml" required="true">
		
		<cfscript>
			var xmlNode = 0;
			var lstFields = structKeyList(arguments.columns);
			var aFields = listToArray(lstFields);
			
			for(i=1;i lte arrayLen(arguments.xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = arguments.xmlDoc.xmlRoot.xmlChildren[i];
				if(xmlNode.xmlAttributes.ID eq arguments.ID) {
					for(i=1;i lte arrayLen(aFields);i=i+1) {
						xmlNode[aFields[i]].xmlText = arguments.columns[aFields[i]].value;
					}
					break;
				}
			}
			
			return arguments.xmlDoc;
		</cfscript>
	</cffunction>			
				
</cfcomponent>
