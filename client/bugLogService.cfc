<cfcomponent>
	<cfset variables.bugEmailSender = "">
	<cfset variables.bugEmailRecipients = "">
	<cfset variables.bugLogListener = "">
	<cfset variables.oBugLogListener = 0>
	<cfset variables.protocol = "">
	<cfset variables.useListener = true>
	<cfset variables.defaultSeverityCode = "ERROR">
	<cfset variables.apikey = "">
	
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
		
		<!--- make sure we have required members --->
		<cfparam name="arguments.exception.message" default="">
		<cfparam name="arguments.exception.detail" default="">

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
			<cfif variables.useListener>
				<cfif variables.protocol eq "REST">
					<!--- send bug via a REST interface --->
					<cfhttp method="post" throwonerror="false" timeout="0" url="#variables.bugLogListener#">
						<cfhttpparam type="formfield" name="dateTime" value="#Now()#">
						<cfhttpparam type="formfield" name="message" value="#arguments.message#">
						<cfhttpparam type="formfield" name="applicationCode" value="#variables.appName#">
						<cfhttpparam type="formfield" name="severityCode" value="#arguments.severityCode#">
						<cfhttpparam type="formfield" name="hostName" value="#variables.hostName#">
						<cfhttpparam type="formfield" name="exceptionMessage" value="#arguments.exception.message#">
						<cfhttpparam type="formfield" name="exceptionDetails" value="#arguments.exception.detail#">
						<cfhttpparam type="formfield" name="CFID" value="#tmpCFID#">
						<cfhttpparam type="formfield" name="CFTOKEN" value="#tmpCFTOKEN#">
						<cfhttpparam type="formfield" name="userAgent" value="#cgi.HTTP_USER_AGENT#">
						<cfhttpparam type="formfield" name="templatePath" value="#GetBaseTemplatePath()#">
						<cfhttpparam type="formfield" name="HTMLReport" value="#longMessage#">
						<cfhttpparam type="formfield" name="APIKey" value="#variables.apikey#">
					</cfhttp>
					<cfif NOT find( 200 , cfhttp.StatusCode )>
						<cfthrow message="Invalid HTTP Response Received" detail="#cfhttp.FileContent#" />
					</cfif>
				<cfelse>
					<!--- send bug via a webservice (SOAP) --->
					<cfset variables.oBugLogListener.logEntry(Now(), 
																sanitizeForXML(arguments.message), 
																variables.appName, 
																arguments.severityCode,
																variables.hostName,
																sanitizeForXML(arguments.exception.message),
																sanitizeForXML(arguments.exception.detail),
																tmpCFID,
																tmpCFTOKEN,
																cgi.HTTP_USER_AGENT,
																GetBaseTemplatePath(),
																sanitizeForXML(longMessage),
																variables.apikey )>
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

			<h3>Exception Info</h3>
			<cfset stEx = structNew()>
			<cfloop collection="#arguments.exception#" item="key">
				<cfif not listFindNoCase("message,detail,tagcontext,type",key)>
					<cfset stEx[key] = arguments.exception[key]>
				</cfif>
			</cfloop>
			<cfdump var="#stEx#">
			<br />
			
			<h3>Additional Info</h3>
			<cfif isSimpleValue(arguments.ExtraInfo)>
				#arguments.ExtraInfo#
			<cfelse>
				<cfdump var="#arguments.ExtraInfo#">
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
	
</cfcomponent>