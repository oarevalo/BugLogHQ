<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<cfparam name="request.requestState.applicationTitle" default="#application.applicationName#">
<cfparam name="request.requestState.viewTemplatePath" default="">
<cfoutput>
	<html>
		<head>
			<title>#request.requestState.applicationTitle#</title>
			<link href="style.css" rel="stylesheet" type="text/css">
		</head>
		<body>
			<div id="header">
				<cfinclude template="../includes/header.cfm">
			</div>
			<div id="mainBody">
				<div id="content">
					<cfinclude template="../includes/message.cfm">

					<table style="width:90%;font-size:11px;" align="center">
						<tr>	
							<td>
								<cfif request.requestState.viewTemplatePath neq "">
									<cfinclude template="#request.requestState.viewTemplatePath#">
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





