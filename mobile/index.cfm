<!DOCTYPE html> 
<html>
	<head>
		<title>BugLogMini</title>
		<meta name="viewport" content="width=320" />
		<meta name="apple-mobile-web-app-capable" content="yes" />
		<link rel="apple-touch-icon" href="/bugLog/mobile/images/bug_48.png"/>
		<link rel="apple-touch-startup-image" href="/bugLog/mobile/images/startup.png">
		<link href="style.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="main.js"></script>
		<script type="text/javascript">
			<cfoutput>serverInfo.server = "#cgi.SERVER_NAME#<cfif cgi.server_port neq 80>:#cgi.server_port#</cfif>";</cfoutput>
		</script>
	</head>
	<body onload="initApp()" class="main">
		<div id="mainContainer">
			<div id="header">
				<div id="topLinksRight">
					<img src="images/door_open.png" id="app_logoff" align="absmiddle">
					<a href="#" id="app_logoff_text">Log Off</a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<img src="images/arrow_rotate_clockwise.png" id="app_refresh" align="absmiddle"> 
					<a href="#" id="app_refresh_text">Refresh</a>
				</div>
				<a href="#" id="app_main"><img src="images/logo.gif" alt="BugLogMini"></a>
			</div>
			<div id="mainBody">
				<iframe id="UI"
						src=""
						frameborder="0">
				</iframe>
			</div>
		</div>
	</body>	
</html>
