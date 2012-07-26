<cfcomponent hint="i am a very simple unit test driver">
	
	<cfset variables.testIndex = 1>
	
	<cffunction name="init" access="public" returntype="testDriver">
		<cfreturn this />
	</cffunction>

	<cffunction name="evaluateTest" access="public" returntype="struct">
		<cfargument name="testStruct" type="struct" required="true">
		<cfparam name="arguments.testStruct.name" default="Unnamed Test">
		<cfparam name="arguments.testStruct.target" default="">
		<cfparam name="arguments.testStruct.actual">
		<cfparam name="arguments.testStruct.expected">
		<cfparam name="arguments.testStruct.onSuccess" default="">
		<cfparam name="arguments.testStruct.onFailure" default="Expected value is different than actual value">
		<cfset var t = arguments.testStruct>
		<cfset var response = {}>
		<cfset var response.success = t.actual eq t.expected>
		<cfif response.success>
			<cfset response.html = "<div class='test success'>"
											& "<label>Test ###variables.testIndex#: ""#t.name#"" Success!</label><br>"
											& "<block>#t.onSuccess#</block>" 
											& "</div>">
		<cfelse>
			<cfset response.html = "<div class='test failure'>"
											& "<label>Test ###variables.testIndex#: ""#t.name#"" Failed!</label><br>"
											& "<block>#t.onFailure#</block><br>"
											& "<b>Expected:</b>" & dumpToHTML(t.expected)
											& "<b>Actual:</b>" & dumpToHTML(t.actual)
											& "</div>">
		</cfif>
		<cfset variables.testIndex++>
		<cfreturn response>
	</cffunction>
	
	<cffunction name="evaluateScenario" access="public" returntype="struct">
		<cfargument name="name" type="string" required="true" default="Unnamed scenario">
		<cfargument name="tests" type="array" required="true">
		<cfset var response = {results = [], html = ""}>
		<cfset var html = "">
		<cfset var successes = 0>
		<cfset var tmp = "">
		<cfset var test = "">
		<cfloop array="#tests#" index="test">
			<cfset tmp = evaluateTest(test)>
			<cfset html &= tmp.html>
			<cfset arrayAppend(response.results, tmp)>
			<cfif tmp.success>
				<cfset successes++>
			</cfif>
		</cfloop>
		<cfset var failures = arrayLen(tests)-successes>
		<cfset response.html = "<div class='scenario'>"
											& "<label>Scenario: #name# (#arrayLen(tests)# tests)</label>"
											& (failures gt 0?" <span class='failure'><label>#arrayLen(tests)-successes# failed</label></span>":"")
											& "<div class='scenario-tests'>"
											& html
											& "</div>"
											& "</div>">
		<cfreturn response>
	</cffunction>
	
	

	<cffunction name="dumpToHTML" access="private" returntype="string">
		<cfargument name="data" type="any" required="true">
		<cfset var tmp = "">
		<cfif isSimpleValue(data)>
			<cfreturn "<pre>#data#</pre>">
		<cfelse>
			<cfsavecontent variable="tmp"><cfdump var="#data#"></cfsavecontent>
		</cfif>
		<cfreturn tmp>
	</cffunction>

</cfcomponent>