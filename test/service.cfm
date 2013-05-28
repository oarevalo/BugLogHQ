<!--- service.cfm

	This template tests the server portion of bugLogHQ. If the service is running, it restarts it
	and then calls the bugLog API using a sample bug report

--->

<!--- get server name --->
<cfset hostName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName()>

<!--- get handle to service controller object --->
<cfset oService = createObject("component","bugLog.components.service").init(true)>

<html>
	<head>
		<style type="text/css">
			body {
				font-size:12px;
				font-family: "trebuchet MS", Arial, Helvetica, "Sans Serif";
				line-height:18px;
				margin:20px;
			}
		</style>
	</head>
	<body>
		<h1><span style="color:red;">BugLog</span>HQ: Test Service</h1>

		<!--- restart service --->
		<cfif oService.isRunning()>
			Stoping service...<br>
			<cfset oService.stop()>
		</cfif>
		Starting service...<br>
		<cfset oService.start()>


		<!--- get service --->
		Getting service instance...<br>
		<cfset oBugLogListener = oService.getService()>
		
		Creating and populating rawEntryBean....<br>
		<cfscript>
			// create entry bean
			oRawEntry = createObject("component","bugLog.components.rawEntryBean").init();
			oRawEntry.setDateTime( now() );
			oRawEntry.setMessage( "this is a test" );
			oRawEntry.setApplicationCode( "TEST" );
			oRawEntry.setSourceName( "Direct" );
			oRawEntry.setSeverityCode( "ERROR" );
			oRawEntry.setHostName( hostName );
			oRawEntry.setExceptionMessage("This is a test");
			oRawEntry.setExceptionDetails("");
			oRawEntry.setCFID("11111");
			oRawEntry.setCFTOKEN("22222");
			oRawEntry.setUserAgent( "" );
			oRawEntry.setTemplatePath( "" );
			oRawEntry.setHTMLReport( "" );
		</cfscript>
		
		<!--- log entry --->
		Logging entry... <br>
		<cfset oBugLogListener.logEntry(oRawEntry)>
		
		<br>
		Done.

		<br><br>
		<a href="index.cfm">Return</a>
	</body>
</html>
		

