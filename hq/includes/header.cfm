<cfparam name="request.requestState.hostName" default="">
<cfparam name="request.requestState.applicationTitle" default="#application.applicationName#">

<cfoutput>
<table width="100%">
	<tr>
		<td>
			<div style="line-height:20px;font-weight:bold;">
				<a href="index.cfm"><img src="#rs.assetsPath#images/bug.png" align="absmiddle"></a>
				<a href="index.cfm" style="color:red;text-decoration:none;font-size:20px;">BugLog<span style="color:black;">HQ</span></a>
			</div>
		</td> 
		<td align="right" style="padding-right:10px;">
			<span style="font-size:10px;font-weight:bold;border-bottom:1px dotted ##333;padding-bottom:8px;">
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
					<a href="?event=ehAdmin.dspMain">Settings</a>
					&nbsp;&nbsp;|&nbsp;&nbsp;
					#request.requestState.currentUser.getUsername()#
					( <a href="?event=ehGeneral.doLogoff">Log off</a> )
				</cfif>
			</span>
		</td>
	</tr>
</table>
</cfoutput>
		