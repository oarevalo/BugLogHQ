
<cfparam name="request.requestState.event" default="">
<cfset event = request.requestState.event>
<cfset eventPkg = listFirst(event,".")>

<cfoutput>
<div style="font-size:12px;">
	[ <a href="index.cfm?event=dashboard" <cfif event eq "dashboard" or event eq "dashboard">style="font-weight:bold;"</cfif>>Dashboard</a> ]
	&nbsp;&nbsp;&nbsp;
	[ <a href="index.cfm?event=main" <cfif event eq "main" or event eq "main">style="font-weight:bold;"</cfif>>Summary</a> ] 
	&nbsp;&nbsp;&nbsp;
	[ <a href="index.cfm?event=log" <cfif event eq "log" or event eq "log">style="font-weight:bold;"</cfif>>Detail</a> ] 
	&nbsp;&nbsp;&nbsp;
	[ <a href="index.cfm?event=extensions.main" <cfif eventPkg eq "extensions">style="font-weight:bold;"</cfif>>Rules</a> ]
	&nbsp;&nbsp;&nbsp;
	[ <img alt="RSS" width="16" height="16" src="#rs.assetsPath#images/icons/feed-icon16x16.gif" border="0" align="absmiddle"/> <a href="index.cfm?event=rss" <cfif event eq "rss">style="font-weight:bold;"</cfif>>RSS</a> ]
</div>
</cfoutput>
