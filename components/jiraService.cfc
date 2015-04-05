<cfcomponent>
    
    <cfset variables.instance = {
                                    endpoint = "",
                                    username = "",
                                    password = ""
                                }>
                                
    <cffunction name="init" access="public" returntype="jiraService">
        <cfargument name="endpoint" required="true" type="string">
        <cfargument name="username" required="true" type="string">
        <cfargument name="password" required="true" type="string">
        <cfset variables.instance.endpoint = arguments.endpoint>
        <cfset variables.instance.username = arguments.username>
        <cfset variables.instance.password = arguments.password>
        <cfscript>
            if(left(variables.instance.endpoint,1) eq "/") {
                if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
                thisHost = thisHost & cgi.server_name;
                if(cgi.server_port neq 80) thisHost = thisHost & ":" & cgi.server_port;
                variables.instance.endpoint = thisHost & variables.instance.endpoint;
            }
        </cfscript>
        <cfreturn this>
    </cffunction>

    <cffunction name="getProjects" access="public" returntype="array">
        <cfset var response  = makeRequest("get", "/project/") />
        <cfset var data = deserializejson(response.fileContent)>
        <cfreturn data>
    </cffunction>

    <cffunction name="getProject" access="public" returntype="struct">
        <cfargument name="projectKey" type="string" required="true">
        <cfset var response  = makeRequest("get", "/project/#projectKey#/") />
        <cfset var data = deserializejson(response.fileContent)>
        <cfreturn data>
    </cffunction>

    <cffunction name="getIssueTypes" access="public" returntype="array">
        <cfargument name="projectKey" type="string" required="false" default="">
        <cfset var response  = {}>
        <cfset var data  = []>
        <cfif arguments.projectKey neq "">
            <cfset data = getProject(arguments.projectKey).issueTypes>
        <cfelse>
            <cfset response  = makeRequest("get", "/issuetype/") />
            <cfset data = deserializejson(response.fileContent)>
        </cfif>
        <cfreturn data>
    </cffunction>
    
    <cffunction name="createIssue" access="public" returntype="struct">
        <cfargument name="project" type="string" required="true">
        <cfargument name="issueType" type="string" required="true">
        <cfargument name="summary" type="string" required="true">
        <cfargument name="description" type="string" required="true">
        <cfset var issue ={
                        "fields"= {
                            "project" = {
                                "key" = arguments.project
                            },
                            "summary" = arguments.summary,
                            "description" = arguments.description,
                            "issuetype" = {
                                "id" = arguments.issueType
                            }
                        }
                    }>

        <cfset var response  = makeRequest(
                                method = "post", 
                                uri = "/issue/",
                                throwonerror = false,
                                body = issue
                            ) />
        <cfif !structKeyExists(response,"Statuscode") or left(response.Statuscode,1) neq "2">
            <cfthrow message="Issue could not be created" detail="#response.fileContent#">
        </cfif>

        <cfreturn deserializejson(response.fileContent)>
    </cffunction>

    <cffunction name="makeRequest" access="private" returntype="struct">
        <cfargument name="method" type="string" required="true">
        <cfargument name="uri" type="string" required="true">
        <cfargument name="throwonerror" type="boolean" required="false" default="true">
        <cfargument name="body" type="any" required="false">
            <cfset var response  = {}>
            <cfhttp url="#variables.instance.endpoint##uri#" 
                        result="response"
                        method="#method#" 
                        throwonerror="#throwonerror#">
                <cfif len(variables.instance.username)>
                    <cfhttpparam
                            type="header"
                            name="Authorization"
                            value="Basic #toBase64( variables.instance.username & ":" & variables.instance.password )#"
                        />
                </cfif>
                <cfif method eq "post">
                    <cfhttpparam type="header" name="Content-Type" value="application/json">
                    <cfhttpparam type="body"  value="#serializeJson(body)#">
                </cfif>
            </cfhttp>
            <cfreturn response />   
    </cffunction>

</cfcomponent>
