<!--- Tests

	This page links to test pages for both client and server components of bugLog

--->


<html>
	<head>
		<style type="text/css">
			body {
				font-size:14px;
				font-family: "trebuchet MS", Arial, Helvetica, "Sans Serif";
				line-height:18px;
				margin:20px;
			}
			td {
				font-size:12px;
			}
		</style>
	</head>
	<body>
		<h1><span style="color:red;">BugLog</span>HQ: Tests</h1>

		<p>
			This page links to test pages for both client and server components of bugLog
		</p>
		
		<table>
			<tr valign="top">
				<td width="100"><a href="client.cfm">Client.cfm</a></td>
				<td>
					This template tests the client portion of bugLogHQ. It also serves as a sample
					of how to use the buglog client.<br><br>
					
					This template accepts the following URL parameters:<br>
					<li><strong>protocol:</strong> determines which buglog listener to use. values are cfc, soap and rest</li>
					<li><strong>severity:</strong> type of error to send. Values are ERROR, FATAL, CRITICAL and INFO</li>
					<li><strong>reset:</strong> unloads the buglog client from memory after the test</li>
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr valign="top">
				<td width="100"><a href="service.cfm">Service.cfm</a></td>
				<td>
					This template tests the server portion of bugLogHQ. If the service is running, it restarts it
					and then calls the bugLog API using a sample bug report.<br><br>
				</td>
			</tr>
		</table>

	</body>
</html>

