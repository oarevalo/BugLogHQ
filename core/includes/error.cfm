<!--- This template displays a standard error message --->

<!--- This indicates how to find the images within the HTML --->
<cfset IMAGES_ROOT = "core/images">
<cfif isDefined("request.requestState._coreImagesPath")>
	<cfset IMAGES_ROOT = request.requestState._coreImagesPath>
</cfif>

<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
		<title>Application Error</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<style type="text/css">
			body,td,th {
				font-family: Arial, Helvetica, sans-serif;
				font-size: 12px;
				color: ##333;
				background-image:none;
			}
			p {
				margin-bottom:10px;
				line-height:20px;
			}
			.tblDump {
				width:600px;
				border-collapse:collapse;
				border:1px solid silver;
			}
			.tblDump td, .tblDump th {
				padding:4px;
				line-height:18px;
			}
			.tblDump th {
				background-color:##ccc;
				text-align:left;
			}			
		</style>
	</head>
			   
	<body bgcolor="##F5F5F5" leftmargin="0" topmargin="0" rightmargin="0" marginheight="0" marginwidth="0">
		<table align="center" style="width:500px;" >
			<tr>
				<td style="font-size:12px;line-height:120%;padding:10px;">
					<img src="#IMAGES_ROOT#/error_sm.gif" align="left" alt="">	
					<div style="margin:5px;font-size:13px;font-weight:bold;">
						Oops, we ran into a bit of a problem!
					</div>
					<p>
						Our system administrator has been notified about this issue 
						and we'll fix any problems promptly.
					</p><br>
					<br />
					<div style="border:1px solid silver;background-color:##ffffe1;padding:10px;">
						<strong>The following is the information returned:</strong><br><br />
						#error.message#<br>
						#error.detail#
					</div>
					<p align="center">
						<a href="javascript:history.back()"><strong>click Here</strong></a>, to return to the previous page.
					</p>
	
		           <div style="border-top:3px solid ##ccc;margin-top:20px;">
				</td>
			</tr>
		</table>

		<br><br>
		<table align="center" class="tblDump" border="1">
			<tr>
				<td colspan="2" style="line-height:24px;">
					<b><u>Diagnostic Information:</u></b>
				</td>
			</tr>
			<tr>
				<th>Message:</th>
				<td>#error.message#</td>
			</tr>
			<tr>
				<th>Type:</th>
				<td>#error.type#</td>
			</tr>
			<tr>
				<th>Details:</th>
				<td>#error.detail#</td>
			</tr>
			<cfif isDefined("error.tagContext")>
				<tr valign="top">
					<th>Tag Context:</th>
					<td>
						<cfloop from="1" to="#arrayLen(error.tagContext)#" index="i">
							&bull; #error.tagContext[i].template# (line #error.tagContext[i].line#)<br>
						</cfloop>
					</td>
				</tr>
			</cfif>
		</table>
	</body>
	</html>
</cfoutput>
