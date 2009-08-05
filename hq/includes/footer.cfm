<cfparam name="request.requestState.versionTag" default="">
<cfset versionTag = request.requestState.versionTag>

<div style="width:200px;font-size:9px;margin:0 auto;text-align:center;line-height:15px;">
	<span style="color:red;font-weight:bold;">BugLog</span><strong>HQ</strong> <cfoutput>#versionTag#</cfoutput><br>
	<a href="http://www.bugloghq.com/">www.bugLogHQ.com</a>
</div>