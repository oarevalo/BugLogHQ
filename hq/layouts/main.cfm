<!DOCTYPE html>
<cfsilent>
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
	<!--- common helper functions --->
	<cfinclude template="../includes/udf.cfm">
</cfsilent>

<cfoutput>
	<html lang="en">
		<head>
			<meta charset="utf-8">
			<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
			<title>#htmlTitle#</title>
			<link rel="stylesheet" href="#rs.assetsPath#/includes/bootstrap/css/bootstrap.min.css" type="text/css" />
			<link rel="stylesheet" href="#rs.assetsPath#/includes/bootstrap/css/bootstrap-responsive.min.css" type="text/css" />
			<link rel="stylesheet" href="#rs.assetsPath#/includes/style.css" type="text/css">
			<script type="text/javascript" src="#rs.assetsPath#/includes/jquery-1.8.0.min.js"></script>
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
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

					<cfif rs.viewTemplatePath neq "">
						<cftry>
							<cfinclude template="#rs.viewTemplatePath#">
							<cfcatch type="any">
								<cfset rs.bugTracker.notifyService(cfcatch.message, cfcatch)>
								<cfrethrow>
							</cfcatch>
						</cftry>
					</cfif>
				</div>
			</div>
			<div id="footer">
				<cfinclude template="../includes/footer.cfm">
			</div>
			<script type="text/javascript" src="#rs.assetsPath#/includes/bootstrap/js/bootstrap.min.js"></script>
			<script type="text/javascript" src="#rs.assetsPath#/includes/main.js"></script>
		</body>
	</html>
</cfoutput>