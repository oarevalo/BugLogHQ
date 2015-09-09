<cfset pathToTests = "/bugLog/test/spec" />
<cfset root = expandPath("/")>

<cfdirectory action="list" directory="#expandPath(pathToTests)#" name="tests" recurse="true"  listinfo="all" type="all" />

<!--- Output the results --->  
<cfoutput>
    <h1>BugLogHQ Test Suite</h1>

    <cfloop query="tests">
        <cfif tests.type eq "dir">
            <br /><b>#tests.name#</b> <br />

        <cfelseif listLast(tests.name,".") eq "cfc">
            <cfset tmp = replaceNoCase(tests.directory,root,"") />
            <cfset href = "/#tmp#/#tests.name#?method=runRemote" />
            <li><a href="#href#">#listFirst(tests.name,".")#</a></li>
        </cfif>
    </cfloop>

</cfoutput>
