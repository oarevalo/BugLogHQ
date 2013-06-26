<cfparam name="request.requestState.versionTag" default="">
<cfparam name="username" default="">

<cfset versionTag = request.requestState.versionTag>
<cfset lstNoPassKeys = "event,view,layout,resetApp,versionTag,_modelsPath,applicationTitle,hostName">
<cfset qs = replaceNoCase(cgi.QUERY_STRING,"event=login","")>

<link href="includes/style.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.tblLogin {
		width:400px;
		margin-top:200px;
		margin-bottom:100px;
	}
	#logo {
		color:red;
		text-decoration:none;
		font-size:22px;
		font-weight:bold;
	}
	#versionTag {
		font-size:10px;
	}
	#resetApp {
		font-size:10px;
		margin-top:15px;
		color:#333;
	}
</style>
<br>

<cfoutput>
	<form name="frmLogin" action="index.cfm?#qs#" method="post">
		<input type="hidden" name="event" value="doLogin">

		<table align="center" border="0" cellpadding="2" cellspacing="0" class="tblLogin">
			<tr>
				<td rowspan="5" style="border-right:1px solid ##ccc;width:150px;" valign="middle" align="center">
					<div id="logo">BugLog<span style="color:black;">HQ</span></div>
					<div id="versionTag">
						Version: <strong>#versionTag#</strong>
					</div>
					<div id="resetApp">
						<a href="index.cfm?resetApp=1" style="color:##333;"
							alt="Resetting the application will force a reload of any configuration settings"
							title="Resetting the application will force a reload of any configuration settings">Reset BugLogHQ</a>
					</div>
				</td>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td width="100" valign="middle" style="font-size:11px;" align="right"><b>Username:</b></td>
				<td valign="middle" colspan="2">
					<input style="font-size:11px;width:100px"
							type="text" name="username" autofocus="autofocus"
							required="yes" message="Your username is required">
				</td>
			</tr>
			<tr>
				<td valign="middle" style="font-size:11px;" align="right"><b>Password:</b></td>
				<td valign="middle">
					<input style="font-size:11px;width:100px"
							type="password" name="password"
							required="yes" message="Your password is required">
				</td>
			</tr>
			<tr><td colspan="2" >&nbsp;</td></tr>
			<tr>
				<td colspan="3" align="center"><input type="submit" value="Login"></td>
			</tr>
		</table>
	</form>
</cfoutput>

