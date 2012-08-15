<!DOCTYPE html>
<cfset rs = request.requestState>
<cfparam name="rs.applicationTitle" default="#application.applicationName#">
<cfparam name="rs.viewTemplatePath" default="">
<cfparam name="rs.messageTemplatePath" default="">
<cfparam name="rs.assetsPath" default="">
<cfoutput>
	<html lang="en">
		<head>
			<meta charset="utf-8">
			<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
			<title>#rs.applicationTitle#</title>
			<link rel="stylesheet" href="#rs.assetsPath#/includes/bootstrap/css/bootstrap.min.css" type="text/css" />
			<link rel="stylesheet" href="#rs.assetsPath#/includes/bootstrap/css/bootstrap-responsive.min.css" type="text/css" />
			<link rel="stylesheet" href="#rs.assetsPath#/includes/style.css" type="text/css">
			<script type="text/javascript" src="#rs.assetsPath#/includes/jquery-1.8.0.min.js"></script>
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
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
			<script type="text/javascript" src="#rs.assetsPath#/includes/bootstrap/js/bootstrap.min.js"></script>
			<script type="text/javascript" src="#rs.assetsPath#/includes/main.js"></script>
		</body>
	</html>
</cfoutput>
