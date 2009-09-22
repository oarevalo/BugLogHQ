<cfcomponent>
	
	<cfset variables.instance = structNew()>
	<cfset variables.instance.encoding = "UTF-8">

	<cffunction name="init" access="public" returntype="xmlStringFormatter">
		<cfargument name="encoding" type="string" required="false" default="">
		<cfif arguments.encoding neq "">
			<cfset variables.instance.encoding = arguments.encoding>
		</cfif>
		<cfreturn this>
	</cffunction>
		
	<cffunction name="makePretty" returntype="string" hint="formats an XML object for display">
		<cfargument name="xmlNode" type="any">
		<cfargument name="depth" type="numeric" required="false" default="0">
	
		<cfset var tmpHTML = "">
		<cfset var n = "">
		<cfset var crlf = chr(13) & chr(10)>
		<cfset var tab = chr(9)>
		<cfset var indent = "">
	
		<cfif arguments.depth gt 0>
			<!--- calculate the proper indentation for the current depth --->
			<cfset indent = repeatString(tab, arguments.depth)>	
		<cfelse>
			<!--- this is the first iteration of the function, so start the output with the xml declaration --->
			<cfset tmpHTML = "<?xml version=""1.0"" encoding=""#variables.instance.encoding#""?>" & crlf>
		</cfif>
	
		<!--- output the current node name --->
		<cfset tmpHTML = tmpHTML & indent & "<" & arguments.xmlNode.xmlName>
		
		<!--- output node attributes --->
		<cfloop collection="#arguments.xmlNode.xmlAttributes#" item="attr">
			<cfset tmpHTML = tmpHTML & " " & attr & "=""" & arguments.xmlNode.xmlAttributes[attr] & """">
		</cfloop>
	
		<!--- check if there are any children nodes and/or any internal text for the tag, if not then
			use shorthand form for closing the tag --->
		<cfif arrayLen(arguments.xmlNode.xmlChildren) gt 0 or arguments.xmlNode.xmlText neq "">
		
			<cfif arrayLen(arguments.xmlNode.xmlChildren) eq 0>
				<!--- if no children, then display node text on the same line to avoid introducing any whitespace --->
				<cfset tmpHTML = tmpHTML & ">" & trim(arguments.xmlNode.xmlText) & "</" & arguments.xmlNode.xmlName & ">" & crlf>
			<cfelse>
				<!--- close node --->
				<cfset tmpHTML = tmpHTML & ">" & crlf>
		
				<!--- recursively output each of the children nodes --->
				<cfloop from="1" to="#arrayLen(arguments.xmlNode.xmlChildren)#" index="i">
					<cfset n = arguments.xmlNode.xmlChildren[i]>
					<cfset tmpHTML = tmpHTML & makePretty(n, arguments.depth+1)>
				</cfloop>
			
				<!--- output any text for this node --->
				<cfif len(trim(arguments.xmlNode.xmlText)) gt 0>
					<cfset tmpHTML = tmpHTML & indent & tab & trim(arguments.xmlNode.xmlText) & crlf>
				</cfif>
		
				<!--- close the node --->
				<cfset tmpHTML = tmpHTML & indent & "</" & arguments.xmlNode.xmlName & ">" & crlf>
					
			</cfif>
		<cfelse>
			<!--- close the node (shorthand) --->
			<cfset tmpHTML = tmpHTML & " />" & crlf>
		</cfif>
	
		<cfreturn tmpHTML>
	</cffunction>

</cfcomponent>