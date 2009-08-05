
<cfparam name="request.requestState.event" default="">
<cfset event = request.requestState.event>
<cfset eventPkg = listFirst(event,".")>

<div style="font-size:12px;">
	[ <a href="index.cfm?event=ehGeneral.dspMain" <cfif event eq "ehGeneral.dspMain">style="font-weight:bold;"</cfif>>Summary</a> ] 
	&nbsp;&nbsp;&nbsp;
	[ <a href="index.cfm?event=ehGeneral.dspLog" <cfif event eq "ehGeneral.dspLog">style="font-weight:bold;"</cfif>>Detail</a> ] 
	&nbsp;&nbsp;&nbsp;
	[ <a href="index.cfm?event=ehStats.dspMain" <cfif eventPkg eq "ehStats">style="font-weight:bold;"</cfif>>Stats</a> ]
	&nbsp;&nbsp;&nbsp;
	[ <a href="index.cfm?event=ehExtensions.dspMain" <cfif eventPkg eq "ehExtensions">style="font-weight:bold;"</cfif>>Rules</a> ]
	&nbsp;&nbsp;&nbsp;
	[ <a href="index.cfm?event=ehAdmin.dspMain" <cfif eventPkg eq "ehAdmin">style="font-weight:bold;"</cfif>>Manage</a> ]
	&nbsp;&nbsp;&nbsp;
	[ <img alt="RSS" width="16" height="16" src="images/icons/feed-icon16x16.gif" border="0" align="absmiddle"/> <a href="index.cfm?event=ehGeneral.dspRSS" <cfif event eq "ehGeneral.dspRSS">style="font-weight:bold;"</cfif>>RSS</a> ]
</div>