<!--- check for iphone/ipod browsing --->
<cfif findNoCase("iphone",cgi.HTTP_USER_AGENT) or findNoCase("iphone",cgi.HTTP_USER_AGENT)>
	<cflocation url="iphone/">
<cfelse>
	<cflocation url="hq/">
</cfif>

