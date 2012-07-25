<cfparam name="request.requestState.versionTag" default="">
<cfparam name="request.requestState.instanceName" default="">
<cfset versionTag = request.requestState.versionTag>
<cfset instanceName = request.requestState.instanceName>

<cfoutput>
<div style="width:200px;font-size:9px;margin:0 auto;text-align:center;line-height:15px;">
	<span style="color:red;font-weight:bold;">BugLog</span><strong>HQ</strong> #versionTag#<br>
	<a href="http://www.bugloghq.com/">www.bugLogHQ.com</a>
	<cfif request.requestState.instanceName neq "" and request.requestState.instanceName neq "default">
		(#request.requestState.instanceName#)
	</cfif>
</div>
</cfoutput>