<cfparam name="request.requestState.hostName" default="">
<cfparam name="request.requestState.configKey" default="">
<cfparam name="request.requestState.applicationTitle" default="#application.applicationName#">

<cfoutput>
	<div class="clearfix">
		<div id="header-left">
			<a href="index.cfm"><img src="#rs.assetsPath#images/bug.png" align="absmiddle" width="32" height="32"></a>
			<a href="index.cfm" style=""><h1>BugLog<span>HQ</span></h1></a>
		</div>
		<div id="header-right">
			#lsDateFormat(now())#
			<cfif request.requestState.hostName neq "">
					&nbsp;&nbsp;|&nbsp;&nbsp;
					#request.requestState.hostName#
					<cfif request.requestState.configKey neq "">
						(#request.requestState.configKey#)
					</cfif>
			</cfif>
			<cfif structKeyExists(request.requestState,"currentUser")>
				&nbsp;&nbsp;|&nbsp;&nbsp;
				<a href="?event=admin.main">Settings</a>
				&nbsp;&nbsp;|&nbsp;&nbsp;
				#request.requestState.currentUser.getUsername()#
				( <a href="?event=doLogoff">Log off</a> )
			</cfif>
		</div>
	</div>
</cfoutput>
		