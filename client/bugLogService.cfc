<cfcomponent>
	<cfset variables.bugEmailSender = "">
	<cfset variables.bugEmailRecipients = "">
	<cfset variables.bugLogListener = "">
	<cfset variables.oBugLogListener = 0>
	<cfset variables.protocol = "">
	<cfset variables.useListener = true>
	<cfset variables.defaultSeverityCode = "ERROR">
	<cfset variables.apikey = "">
	<cfset variables.postToRESTasJSON = false> 
	<cfset variables.userAgent = "bugloghq-coldfusion-client">
	<cfset variables.checkpointsKey = "__buglog_checkpoints__">
	
	<!--- Handle cases in which the application scope is not defined (Fix contributed by Morgan Dennithorne) --->
	<cfif isDefined("application.applicationName")>
		<cfset variables.appName = replace(application.applicationName," ","","all") />
	<cfelse>
		<cfset variables.appName = "undefined" />
	</cfif>
			
	<cfset variables.escapePattern = createObject('java','java.util.regex.Pattern').compile("[^\u0009\u000a\u000d\u0020-\ud7ff\ud800\udc00\ue000-\ufffd\u100000-\u10ffff]") /> 

	
	<cffunction name="init" returntype="bugLogService" access="public" hint="Constructor" output="false">
		<cfargument name="bugLogListener" type="string" required="true">
		<cfargument name="bugEmailRecipients" type="string" required="false" default="">
		<cfargument name="bugEmailSender" type="string" required="false" default="">
		<cfargument name="hostname" type="string" required="false" default="">
		<cfargument name="apikey" type="string" required="false" default="">
		
		<cfscript>
			var wsParams = structNew();
			wsParams.refreshWsdl = true;
			wsParams.timeout = 30;

			// trim spaces
			arguments.bugLogListener = trim(arguments.bugLogListener);
			arguments.bugEmailRecipients = trim(arguments.bugEmailRecipients);
			arguments.bugEmailSender = trim(arguments.bugEmailSender);
			arguments.hostname = trim(arguments.hostname);
			arguments.apikey = trim(arguments.apikey);
			
			// determine the protocol based on the bugLogListener location 
			// this will tell us how to locate and talk to the listener
			if(left(arguments.bugLogListener,4) eq "http" and right(arguments.bugLogListener,5) eq "?WSDL") 
				variables.protocol = "SOAP";

			if(left(arguments.bugLogListener,4) eq "http" and right(arguments.bugLogListener,4) eq ".cfm") 
				variables.protocol = "REST";

			if(left(arguments.bugLogListener,4) neq "http") 
				variables.protocol = "CFC";

			// store settings
			variables.bugLogListener = arguments.bugLogListener;
			variables.bugEmailSender = arguments.bugEmailSender;
			variables.bugEmailRecipients = arguments.bugEmailRecipients;
			variables.apikey = arguments.apikey;
			
			if(arguments.bugEmailSender eq "" and arguments.bugEmailRecipients neq "")
				arguments.bugEmailSender = listFirst(arguments.bugEmailRecipients);

			// figure out an appropriate hostname
			if(arguments.hostname neq "") {
				variables.hostName = arguments.hostname;
			} else {
				// get the hostname via reverse lookup
				try {
					variables.hostName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
				} catch(any e) {
					// the reverse lookup can sometimes fail depending on the network configuration
					variables.hostName = CGI.SERVER_NAME;
				}
			}

			// Instantiate appropriate reference to listener		
			switch(variables.protocol) {
				case "SOAP":
					try {
						if(val(left(server.coldfusion.productVersion,1)) lte 7 or structKeyExists(server,"railo"))
							variables.oBugLogListener = createObject("webservice", variables.bugLogListener);
						else
							variables.oBugLogListener = createObject("webservice", variables.bugLogListener, wsParams);
						
					} catch(any e) {
						if(variables.bugEmailRecipients neq "") sendEmail("",e.detail,e.message);
						variables.useListener = false;
					}
					break;
					
				case "CFC":
					try {
						variables.oBugLogListener = createObject("component", variables.bugLogListener);
					} catch(any e) {
						if(variables.bugEmailRecipients neq "") sendEmail("",e.detail,e.message);
						variables.useListener = false;
					}
					break;
				
				case "REST":
					variables.oBugLogListener = 0;	// no reference needed
					break;
					
				default:
					throwError("The location provided for the bugLogListener is invalid.");	
			}
		</cfscript>
		<cfreturn this>
	</cffunction>

	<cffunction name="notifyService" access="public" returntype="void" hint="Use this method to tell the bugTrackerService that an error has ocurred" output="false"> 
		<cfargument name="message" type="string" required="true">
		<cfargument name="exception" type="any" required="false" default="#structNew()#">
		<cfargument name="ExtraInfo" type="any" required="false" default="">
		<cfargument name="severityCode" type="string" required="false" default="#variables.defaultSeverityCode#">

		<cfset var shortMessage = "">
		<cfset var longMessage = "">
		<cfset var tmpCFID = "">
		<cfset var tmpCFTOKEN = "">
		<cfset var data = {}>
		
		<!--- make sure we have required members --->
		<cfparam name="arguments.exception.message" default="">
		<cfparam name="arguments.exception.detail" default="">
		
		<!--- if we are tracking checkpoints, then add the buglog call as the last checkpoint --->
		<cfif arrayLen(getCheckpoints())>
			<cfset checkpoint("bugLog.notifyService() called")>
		</cfif>

		<!--- compose short and full messages --->
		<cfset shortMessage = composeShortMessage(arguments.message, arguments.exception, arguments.extraInfo)>
		<cfset longMessage = composeFullMessage(arguments.message, arguments.exception, arguments.extraInfo)>
		
		<!--- check if there are valid CFID/CFTOKEN values available --->
		<cfif isDefined("cfid")>
			<cfset tmpCFID = cfid>
		</cfif>
		<cfif isDefined("cftoken")>
			<cfset tmpCFTOKEN = cftoken>
		</cfif>		
		
		<!--- submit error --->
		<cftry>
			<cfset data = {
						"dateTime" = Now(),
						"message" = arguments.message,
						"applicationCode" = variables.appName,
						"severityCode" = arguments.severityCode,
						"hostName" = variables.hostName,
						"exceptionMessage" = arguments.exception.message,
						"exceptionDetails" = arguments.exception.detail,
						"CFID" = tmpCFID,
						"CFTOKEN" = tmpCFTOKEN,
						"userAgent" = cgi.HTTP_USER_AGENT,
						"templatePath" = getBaseTemplatePath(),
						"HTMLReport" = longMessage,
						"APIKey" = variables.apiKey
					}>

			<cfif variables.useListener>
				<cfif variables.protocol eq "REST">
					<!--- send bug via a REST interface --->
					<cfhttp method="post" throwonerror="false" timeout="10" url="#variables.bugLogListener#" charset="UTF-8" useragent="#variables.userAgent#">
						<cfif variables.postToRESTasJSON>
							<cfhttpparam type="header" name="Content-Type" value="application/json">
							<cfhttpparam type="body" value="#serializeJson(data)#">
						<cfelse>
							<cfloop list="#structKeyList(data)#" index="key">
								<cfhttpparam type="formfield" name="#key#" value="#data[key]#">
							</cfloop>
						</cfif>
					</cfhttp>
					<cfif NOT find( 200 , cfhttp.StatusCode )>
						<cfthrow message="Invalid HTTP Response Received" detail="#cfhttp.FileContent#" />
					</cfif>
				<cfelse>
					<!--- send bug via a webservice (SOAP) --->
					<cfset variables.oBugLogListener.logEntry(data.dateTime, 
																sanitizeForXML(data.message), 
																data.applicationCode, 
																data.severityCode,
																data.hostName,
																sanitizeForXML(data.exceptionMessage),
																sanitizeForXML(data.exceptionDetails),
																data.CFID,
																data.CFTOKEN,
																data.userAgent,
																data.templatePath,
																sanitizeForXML(data.HTMLReport),
																data.apikey)>
				</cfif>
			<cfelse>
				<cfif variables.bugEmailRecipients neq "">
					<cfset sendEmail(arguments.message, longMessage, "BugLog listener not available")>
				</cfif>
			</cfif>

			<cfcatch type="any">
				<!--- an error ocurred, if there is an email address stored, then send details to that email, otherwise rethrow --->
				<cfif variables.bugEmailRecipients neq "">
					<cfset sendEmail(arguments.message, longMessage, cfcatch.message & cfcatch.detail)>
				<cfelse>
					<cfrethrow> 
				</cfif>
			</cfcatch>		
		</cftry>
		
		<!--- add entry to coldfusion log --->	
		<cflog type="error" 
			   text="#shortMessage#" 
			   file="#variables.appName#_BugTrackingErrors">

	</cffunction>

	<cffunction name="sendEmail" access="private" hint="Sends the actual email message" returntype="void">
		<cfargument name="message" type="string" required="true">
		<cfargument name="longMessage" type="string" required="true">
		<cfargument name="otherError" type="string" required="true">

		<cfmail to="#variables.bugEmailRecipients#" 
				from="#variables.bugEmailSender#" 
				subject="BUG REPORT: [#variables.appName#] [#variables.hostName#] #arguments.message#" 
				type="html">
			<div style="margin:5px;border:1px solid silver;background-color:##ebebeb;font-family:arial;font-size:12px;padding:5px;">
				This email is sent because the buglog server could not be contacted. The error was:
				#arguments.otherError#
			</div>
			#arguments.longMessage#
		</cfmail>		
	</cffunction>

	<cffunction name="composeShortMessage" access="private" returntype="string" output="false">
		<cfargument name="message" type="string" required="true">
		<cfargument name="exception" type="any" required="false" default="#structNew()#">
		<cfargument name="ExtraInfo" type="any" required="no" default="">
		<cfscript>
			var aBuffer = arrayNew(1);
			var e = arguments.exception;
			
			arrayAppend(aBuffer, arguments.message);
			if(e.message neq arguments.message) arrayAppend(aBuffer, ". Message: " & e.message);
			if(e.detail neq "")					arrayAppend(aBuffer, ". Details: " & e.detail);
			
			return arrayToList(aBuffer, "");
		</cfscript>
	</cffunction>

	<cffunction name="composeFullMessage" access="private" returntype="string" output="true">
		<cfargument name="message" type="string" required="true">
		<cfargument name="exception" type="any" required="false" default="#structNew()#">
		<cfargument name="ExtraInfo" type="any" required="no" default="">

		<cfscript>
			var tmpHTML = "";
			var i = 0;
			var aTags = arrayNew(1);
			var qryTagContext = queryNew("template,line");
			var tmpURL = "";
			
			if(structKeyExists(arguments.exception,"tagContext")) {
				aTags = duplicate(arguments.exception.tagContext);
				for(i=1;i lte arrayLen(aTags);i=i+1) {
					QueryAddRow(qryTagContext);
					QuerySetCell(qryTagContext, "template", htmlEditFormat(aTags[i].template));				
					QuerySetCell(qryTagContext, "line", aTags[i].line);				
				}
			}

			// reconstruct full URL
			tmpURL = getPageContext().getRequest().getRequestURL();
			if(cgi.QUERY_STRING neq "")
				tmpURL = tmpURL & "?" & cgi.QUERY_STRING;
		</cfscript>
		

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
			<h3>Exception Summary</h3>
			<table style="font-size:11px;font-family:arial;">
				<tr>
					<td><b>Application:</b></td>
						<td>#HtmlEditFormat(variables.appName)#</td>
				</tr>
				<tr>
					<td><b>Host:</b></td>
					<td>#HtmlEditFormat(variables.hostName)#</td>
				</tr>
				<tr>
					<td><b>URL:</b></td>
					<td><a href="#tmpURL#" target="_blank">#tmpURL#</a></td>
				</tr>
				<tr>
					<td><b>Server Date/Time:</b></td>
					<td>#lsDateFormat(now())# #lsTimeFormat(now())#</td>
				</tr>
				<tr>
					<td><b>Message:</b></td>
							<td>#HtmlEditFormat(arguments.exception.message)#</td>
				</tr>
				<cfif structKeyExists(arguments.exception,"type")>
					<tr>
						<td><b>Type:</b></td>
						<td>#HtmlEditFormat(arguments.exception.type)#</td>
					</tr>
				</cfif>
				<tr>
					<td><b>Detail:</b></td>
							<td>#HtmlEditFormat(arguments.exception.detail)#</td>
				</tr>
				<cfif arrayLen(aTags) gt 0>
					<tr valign="top">
						<td><b>Tag Context:</b></td>
						<td>
							<cfloop query="qryTagContext">
								<li>#qryTagContext.template# [#qryTagContext.line#]</li>
							</cfloop>
						</td>
					</tr>
				</cfif>
				<tr>
					<td><b>Script Name (CGI):</b></td>
					<td>#HtmlEditFormat(cgi.SCRIPT_NAME)#</td>
				</tr>
				<tr>
					<td><b>User Agent:</b></td>
					<td>#HtmlEditFormat(cgi.HTTP_USER_AGENT)#</td>
				</tr>
				<tr>
					<td><b>Referrer:</b></td>
					<td>#HtmlEditFormat(cgi.HTTP_REFERER)#</td>
				</tr>
				<tr>
					<td><b>Query String:</b></td>
					<td>#HtmlEditFormat(cgi.QUERY_STRING)#</td>
				</tr>
				<tr>
					<td><b>Request Method:</b></td>
					<td>#HtmlEditFormat(cgi.REQUEST_METHOD)#</td>
				</tr>
				<tr valign="top">
					<td><strong>Coldfusion ID:</strong></td>
					<td>
						<cftry>
							[SESSION] &nbsp;&nbsp;&nbsp;&nbsp;
							CFID = #session.cfid#;
							CFTOKEN = #session.cftoken#
							JSessionID=#session.sessionID#
							<cfcatch type="any">
								<span style="color:red;">#HtmlEditFormat(cfcatch.message)#</span>
							</cfcatch>
						</cftry><br>
						
						<cftry>
							[CLIENT] &nbsp;&nbsp;&nbsp;&nbsp;
							CFID = #client.cfid#;
							CFTOKEN = #client.cftoken#
							<cfcatch type="any">
								<span style="color:red;">#HtmlEditFormat(cfcatch.message)#</span>
							</cfcatch>
						</cftry><br>
						
						<cftry>
							[COOKIES] &nbsp;&nbsp;&nbsp;&nbsp;
							CFID = #cookie.cfid#;
							CFTOKEN = #cookie.cftoken#
							<cfcatch type="any">
								<span style="color:red;">#HtmlEditFormat(cfcatch.message)#</span>
							</cfcatch>
						</cftry><br>
						
						<cftry>
							[J2EE SESSION] &nbsp;&nbsp;
							JSessionID = #session.JSessionID#;
							<cfcatch type="any">
								<span style="color:red;">#HtmlEditFormat(cfcatch.message)#</span>
							</cfcatch>
						</cftry>
					</td>
				</tr>					
			</table>
			<br />
			
			<h3>Exception Info</h3>
			<table style="font-size:11px;font-family:arial;">
				<cfloop collection="#arguments.exception#" item="key">
					<cfif not listFindNoCase("message,detail,tagcontext,type",key)>
						<tr valign="top">
							<td><b>#key#:</b></td>
							<td>
								<cfif isSimpleValue(arguments.exception[key])>
									#arguments.exception[key]#
								<cfelse>
									<cfdump var="#arguments.exception[key]#">
								</cfif>
							</td>
						</tr>
					</cfif>
				</cfloop>
			</table>
			<br />
			
			<cfif not isSimpleValue(arguments.ExtraInfo) or arguments.ExtraInfo neq "">
				<h3>Additional Info</h3>
				<cfif isSimpleValue(arguments.ExtraInfo)>
					#arguments.ExtraInfo#
				<cfelse>
					<cfdump var="#arguments.ExtraInfo#">
				</cfif>
			</cfif>
			
			<cfset var checkpoints = getCheckpoints()>
			<cfif arrayLen(checkpoints)>
				<br />
				<h3>Checkpoints</h3>
				<table border="1" cellspacing="0" cellpadding="3">
					<tr>
						<th>##</th>
						<th>Checkpoint</th>
						<th>Delta (ms)</th>
						<th>Elapsed (ms)</th>
					</tr>
					<cfset var prevTs = 0>
					<cfloop from="1" to="#arrayLen(checkpoints)#" index="i">
						<tr <cfif i mod 2>style="background-color:##ebebeb;"</cfif>>
							<td style="text-align:right;">#i#.</td>
							<td>#checkpoints[i].cp#</td>
							<td style="text-align:right;"><cfif i gt 1>#checkpoints[i].ts-prevTs#<cfelse>-</cfif></td>
							<td style="text-align:right;"><cfif i gt 1>#checkpoints[i].ts-checkpoints[1].ts#<cfelse>-</cfif></td>
						</tr>
						<cfset prevTs = checkpoints[i].ts>
					</cfloop>
				</table>
			</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>

	<cffunction name="throwError" access="private" returntype="void" hint="facade for cfthrow">
		<cfargument name="message" type="String" required="true">
		<cfthrow message="#arguments.message#">
	</cffunction>
	
	<cffunction name="sanitizeForXML" access="private" returnType="string" hint="sanitizes a string to make it safe for xml">
		<cfargument name="inString" type="string" required="true" />
		<cfset var matcher = variables.escapePattern.matcher(inString) />
		<cfset var buffer = createObject('java','java.lang.StringBuffer').init('') />
		<cfloop condition="matcher.find()">
			<cfset matcher.appendReplacement(buffer,"") />
		</cfloop>		
		<cfset matcher.appendTail(buffer) />
		<cfreturn buffer.toString() />
	</cffunction>
	
	<cffunction name="checkpoint" access="public" returntype="void" hint="marks a checkpoint in the current request">
		<cfargument name="checkpoint" type="string" required="true">
		<cfscript>
			var checkpoints = getCheckpoints();
			var item = {
				ts = getTickCount(),
				cp = arguments.checkpoint
			};
			arrayAppend(checkpoints, item);
		</cfscript>
	</cffunction>
	
	<cffunction name="getCheckpoints" access="public" returntype="array" hint="returns the checkpoints saved for the current request">
		<cfif not structKeyExists(request,checkpointsKey)>
			<cfset request[checkpointsKey] = arrayNew(1)>
		</cfif>
		<cfreturn request[checkpointsKey]>
	</cffunction>
	
</cfcomponent>