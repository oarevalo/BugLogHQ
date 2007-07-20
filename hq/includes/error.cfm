<cfsetting enablecfoutputonly="true">
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Unexpected Error</title>
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
	</style>
</head>
		   
<body bgcolor="##F5F5F5" leftmargin="0" topmargin="0" rightmargin="0" marginheight="0" marginwidth="0">
	<table align="center" style="width:500px;" >
		<tr>
			<td style="font-size:12px;line-height:120%;padding:10px;">
				<img src="images/error_sm.gif" align="left">	
				<div style="margin:5px;font-size:13px;font-weight:bold;">
					Oops, we ran into a bit of a problem!
				</div>
				<p>
					Our system administrator has been notified about this issue 
					and we'll fix any problems promptly.
				</p><br>
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
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false">