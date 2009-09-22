<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<cfparam name="request.requestState.applicationTitle" default="#application.applicationName#">
<cfparam name="request.requestState.viewTemplatePath" default="">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
		<title><cfoutput>#request.requestState.applicationTitle#</cfoutput></title>
		<link href="style.css" rel="stylesheet" type="text/css">
	</head>
	
	<body>
		<cfoutput>
			<cftry>
				<cfinclude template="../includes/message.cfm">

				<cfif request.requestState.viewTemplatePath neq "">
					<cfinclude template="#request.requestState.viewTemplatePath#">
				</cfif>

				<cfcatch type="any">
					<b>#cfcatch.Message#</b><br>
					#cfcatch.Detail#
				</cfcatch>
			</cftry>
		</cfoutput>
	</body>
</html>
