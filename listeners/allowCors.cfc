<!--- Credit to https://gist.github.com/zefer/601076 --->
<cfcomponent>
    <cffunction name="allowCrossDomainAccess" returnType="void" access="public">

        <cfset var stHeaders = getHttpRequestData().headers />

        <cfif structKeyExists( stHeaders, "Origin" ) and cgi.request_method eq "OPTIONS">

            <cfheader name="Access-Control-Allow-Origin" value="*" />
            <cfheader name="Access-Control-Allow-Methods" value="GET, POST, OPTIONS, ACCEPT" />
            <cfheader name="Access-Control-Allow-Headers" value="Origin, Content-Type, Accept" />
            <cfheader name="Access-Control-Max-Age" value="1728000" />
            <cfheader name="Access-Control-Allow-Credentials" value="false" />

            <!---
            Respond with these headers - the browser will cache these 'permissions'
            and immediately follow-up with the original request
            --->
            <cfcontent type="text/plain" reset="true" />
            <cfabort />

            <cfelseif listFindNoCase("GET,POST", cgi.request_method)>

            <!---
            Simple GET requests:
            When the request is GET or POST, and no custom headers are sent, then no preflight check is required.
            The browser accepts the response providing we allow it to with the Access-Control-Allow-Origin header
            We allow any host to do simple x-domain GET requests
            --->
            <cfheader name="Access-Control-Allow-Origin" value="*" />

        </cfif>

    </cffunction>
</cfcomponent>