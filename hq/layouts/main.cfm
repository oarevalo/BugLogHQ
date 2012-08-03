<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<cfset rs = request.requestState>
<cfparam name="rs.applicationTitle" default="#application.applicationName#">
<cfparam name="rs.pageTitle" default="">
<cfparam name="rs.viewTemplatePath" default="">
<cfparam name="rs.messageTemplatePath" default="">
<cfparam name="rs.assetsPath" default="">
<cfset htmlTitle = rs.applicationTitle>
<cfif rs.pageTitle neq "">
	<cfset htmlTitle = rs.applicationTitle & " :: " & rs.pageTitle>
</cfif>
<cfoutput>
	<html>
		<head>
			<title>#htmlTitle#</title>
			<link href="#rs.assetsPath#style.css" rel="stylesheet" type="text/css">
		</head>
		<body>
			<div id="header">
				<cfinclude template="../includes/header.cfm">
			</div>
			<div id="mainBody">
				<div id="content">
					<cfif rs.messageTemplatePath neq "">
						<cfinclude template="#rs.messageTemplatePath#">
					</cfif>

					<table style="width:90%;font-size:11px;" align="center">
						<tr>	
							<td>
								<cfif rs.viewTemplatePath neq "">
									<cfinclude template="#rs.viewTemplatePath#">
								</cfif>
							</td>
						</tr>
					</table>
				</div>
				<cfinclude template="../includes/footer.cfm">
			</div>
		</body>
	</html>
</cfoutput>