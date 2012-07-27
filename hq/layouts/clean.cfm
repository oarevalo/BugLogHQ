<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<cfset rs = request.requestState>
<cfparam name="rs.applicationTitle" default="#application.applicationName#">
<cfparam name="rs.viewTemplatePath" default="">
<cfparam name="rs.messageTemplatePath" default="">
<cfparam name="rs.assetsPath" default="">
<cfoutput>
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
			<title>#rs.applicationTitle#</title>
			<link href="#rs.assetsPath#style.css" rel="stylesheet" type="text/css">
		</head>
		
		<body>
			<cftry>
				<cfif rs.messageTemplatePath neq "">
					<cfinclude template="#rs.messageTemplatePath#">
				</cfif>

				<cfif rs.viewTemplatePath neq "">
					<cfinclude template="#rs.viewTemplatePath#">
				</cfif>

				<cfcatch type="any">
					<b>#cfcatch.Message#</b><br>
					#cfcatch.Detail#
				</cfcatch>
			</cftry>
		</body>
	</html>
</cfoutput>
