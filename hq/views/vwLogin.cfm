<cfparam name="request.requestState.versionTag" default="">
<cfparam name="username" default="">

<cfset versionTag = request.requestState.versionTag>
<cfset lstNoPassKeys = "event,view,layout,resetApp,versionTag,_modelsPath,applicationTitle,hostName">
<cfset qs = replaceNoCase(cgi.QUERY_STRING,"event=ehGeneral.dspLogin","")>

<link href="includes/style.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.tblLogin {
		width:400px;
		margin-top:200px;
		margin-bottom:100px;
	}
</style>
<br>

<cfoutput>
	<form name="frmLogin" action="index.cfm?#qs#" method="post">
		<input type="hidden" name="event" value="ehGeneral.doLogin">
		
		<table align="center" border="0" cellpadding="2" cellspacing="0" class="tblLogin">
			<tr>
				<td rowspan="5" style="border-right:1px solid ##ccc;width:150px;" valign="middle" align="center">
					<span style="color:red;text-decoration:none;font-size:20px;">BugLog<span style="color:black;">HQ</span></span>
					<div style="margin-top:5px;text-align:center;font-size:9px;">#versionTag#</div>
				</td>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td width="100" valign="middle" style="font-size:11px;" align="right"><b>Username:</b></td>
				<td valign="middle" colspan="2">
					<input style="font-size:11px;width:100px" 
							type="text" name="username" 
							required="yes" message="Your email address is required">
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

