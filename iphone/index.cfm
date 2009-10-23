<html>
	<head>
		<title>BugLogMini</title>
		<meta name="viewport" content="width=320" />
		<meta name="apple-mobile-web-app-capable" content="yes" />
		<link rel="apple-touch-icon" href="/bugLog/iphone/images/bug_48.png"/>
		<link rel="apple-touch-startup-image" href="/bugLog/iphone/images/startup.png">
		<link href="style.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="main.js"></script>
		<script type="text/javascript">
		    var Exposed = {};
			Exposed.doConnect = doConnect;
			Exposed.doGetSummary = doGetSummary;
			Exposed.doGetListing = doGetListing;
			Exposed.doGetServerInfo = doGetServerInfo;
			Exposed.doSetListingRefreshTimer = doSetListingRefreshTimer;
			Exposed.doGetEntry = doGetEntry;
			Exposed.doOpenURL = doOpenURL;
			<cfoutput>serverInfo.server = "#cgi.SERVER_NAME#";</cfoutput>
		</script>
	</head>
	<body onload="initApp()" class="main">
		<div id="mainContainer">
			<div id="topControls" class="windowMoveHandler">
				<div id="topHeader">
					<img src="images/logo.gif" alt="BugLogMini">
				</div>
			</div>
			<div id="mainBody">
				<div id="mainBodyInner">
					<iframe id="UI"
							src=""
							sandboxRoot="http://www.oscararevalo.com/"
							documentRoot="app-resource:/">
					</iframe>
					<div id="bottomControls">
						<div id="bottomLinksRight">
							<img src="images/door_open.png" id="app_logoff" align="absmiddle">
							<a href="#" id="app_logoff_text">Log Off</a>
							<div id="win_resize"></div>
						</div>
						<div id="bottomLinksLeft" class="windowMoveHandler">
							<a href="/bugLog"><img src="images/house.png" id="app_home" align="absmiddle" border="0"> </a>
							<a href="/bugLog" id="app_home_text">BugLogHQ</a>
							&nbsp;&nbsp;&nbsp;
							<img src="images/arrow_rotate_clockwise.png" id="app_refresh" align="absmiddle"> 
							<a href="#" id="app_refresh_text">Refresh</a>
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>	
</html>
