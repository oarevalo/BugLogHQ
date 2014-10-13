<cfsetting enablecfoutputonly="true">

<cfscript>
	try {

		instance = "";
		status = {
			code = 200,
			text = "OK"
		};
		response = {
			"status" = "OK",
			"id" = ""
		};

		//  This endpoint must respond to both JSON and regular HTTP requests
		requestBody = toString( getHttpRequestData().content );
		if( isJSON(requestBody) ) {
			// json is what we got
			args = deserializeJSON(requestBody);
		} else {
			// This is a regular http request, so let's build a 
			// collection of all incoming URL & Form parameters
			args = duplicate(form);
			structAppend(args, url);
		}

		// at minimum we need a message
		if(!structKeyExists(args, "message")) {
			throw(type="bugLog.invalidFormat", message="Message field is required");
		}

		// set default values
		param name="args.applicationCode" default="Unknown";
		param name="args.dateTime" type="date" default=now();
		param name="args.severityCode" default="ERROR";
		param name="args.hostName" default=cgi.REMOTE_ADDR;

		// log how we got this report
		args.source = ucase(cgi.request_method);

		// See if we this is a named instance of buglog
		if( structKeyExists(request,"bugLogInstance") and len(request.bugLogInstance) ) {
			instance = request.bugLogInstance;
		}

		// log entry
		listener = createObject("component","bugLog.components.listener").init( instance );
		rawEntryBean = listener.logEntry( argumentCollection = args );
		response.id = rawEntryBean.getUUID();


	// Handle exceptions
	} catch("bugLog.invalidFormat" e) {
		status = {code = 400, text = "Bad Request"};
		response["status"] = "Error";
		response["error"] = e.message;

	} catch("bugLog.invalidAPIKey" e) {
		status = {code = 401, text = "Unauthorized"};
		response["status"] = "Error";
		response["error"] = e.message;

	} catch("applicationNotAllowed" e) {
		status = {code = 403, text = "Forbidden"};
		response["status"] = "Error";
		response["error"] = e.message;

	} catch(any e) {
		status = {code = 500, text = "Server Error"};
		response["status"] = "Error";
		response["error"] = e.message;
	}
</cfscript>

<!--- Send Reponse --->
<cfheader statuscode="#status.code#" statustext="#status.text#" />
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJson(response)#</cfoutput>
