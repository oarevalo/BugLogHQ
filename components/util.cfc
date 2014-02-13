<cfcomponent>

	<cffunction name="init" access="public" returnType="util">
		<cfreturn this />
	</cffunction>

	<cffunction name="getBugEntryHREF" access="public" returntype="string" hint="Returns the URL to a given bug report">
		<cfargument name="entryID" type="numeric" required="true" hint="the id of the bug report">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfargument name="instanceName" type="string" required="false" default="default" hint="the current buglog instance name">
		<cfset var buglogHref = getBugLogHQAppHREF(config, instanceName) />
		<cfset var href = buglogHref & "index.cfm?event=entry&entryID=#arguments.entryID#" />
		<cfreturn href />
	</cffunction>

	<cffunction name="getBaseBugLogHREF" access="public" returntype="string" hint="Returns a web accessible URL to buglog">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfargument name="instanceName" type="string" required="false" default="default" hint="the current buglog instance name">
		<cfargument name="server" type="boolean" required="false" hint="use the serverURL instead if defined" />
		<cfscript>
			var buglogPath = "";
			var externalURL = config.getSetting("general.externalURL");
			var host = getCurrentHost();
			var innerpath = externalURL;
			var external_is_url = false;

			// normalize instance name
			if(instanceName eq "" or instanceName eq "default")
				instanceName = "bugLog";

			// check if we want to use the serverURL instead of the externalURL
			if(arguments.server && len(config.getSetting("general.serverURL","")))
				externalURL = config.getSetting("general.serverURL");

			// check if the externalURL setting points to a full URL
			// if this is the case, then that will be assumed to be the location
			// where the bugLog application is installed 
			if(left(externalURL,4) eq "http") {
				external_is_url = true;
				host = externalURL;
				innerpath = "";
			}
			
			// make sure we have a backslash at the end
			if(right(host,1) neq "/")
				host = host & "/";

			// build the path
			if((innerpath eq "/" or (innerpath eq "" and external_is_url)) and instanceName eq "bugLog") {
				buglogPath = host;
			} else {
				if(innerpath eq "/") {
					buglogPath = host & instanceName;
				} else {
					if(left(innerpath,1) eq "/")
						innerpath = right(innerpath,len(innerpath)-1);

					if(innerpath neq "") {
						if(right(innerpath,1) neq "/")
							innerpath = innerpath & "/";
						if(instanceName eq "bugLog")					
							buglogPath = host & innerpath;
						else
							buglogPath = host & innerpath & instanceName;
					} else {
						buglogPath = host & instanceName;
					}
				}
			}
			
			// make sure we have a backslash at the end
			if(right(buglogPath,1) neq "/")
				buglogPath = buglogPath & "/";

			return buglogPath;
		</cfscript>
	</cffunction>

	<cffunction name="getBugLogHQAssetsHREF" access="public" returntype="string" hint="Returns a web accessible URL to use to obtain buglog HQ assets (images,html,js,etc)">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfset var buglogHref = getBaseBugLogHREF(config) & "hq/" />
		<cfreturn buglogHref>
	</cffunction>

	<cffunction name="getBugLogHQAppHREF" access="public" returntype="string" hint="Returns a web accessible URL to buglog HQ app (only for linking into the app code itself, not assets)">
		<cfargument name="config" type="any" required="true" hint="the main config object">
		<cfargument name="instanceName" type="string" required="false" default="default" hint="the current buglog instance name">
		<cfset var buglogHref = getBaseBugLogHREF(config, instanceName) />
		<cfif instanceName eq "default" or instanceName eq "">
			<cfset buglogHref = buglogHref & "hq/">
		</cfif>
		<cfreturn buglogHref>
	</cffunction>

	<cffunction name="getCurrentHost" access="public" returntype="string" hint="gets the current host based on the CGI scope">
		<cfscript>
			var thisHost = "";
			if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
			thisHost = thisHost & cgi.server_name;
			if(cgi.server_port neq 80 and cgi.server_port neq 443) thisHost = thisHost & ":" & cgi.server_port;
			return thisHost;
		</cfscript>
	</cffunction>

	<cffunction name="getParentPath" access="public" returntype="string" hint="returns the path to the parent folder of a given template">
		<cfargument name="templatePath" type="string" required="true">
		<cfset var path = GetDirectoryFromPath(GetDirectoryFromPath(arguments.templatePath).ReplaceFirst( "[\\\/]{1}$", "" ))>
		<cfif path.endsWith("/") or path.endsWith("\")>
			<cfset path = left(path,len(path)-1)>
		</cfif>
		<cfreturn path>
	</cffunction>

	<cffunction name="dateConvertZ" access="public" returntype="any" hint="Similar to DateConvert, but provides local2zone and zone2local conversion from one time zone to another.">
		<cfargument name="conversionType" type="string" required="true">
		<cfargument name="dateObj" type="date" required="true">
		<cfargument name="zoneInfo" type="string" required="true">
		<cfscript>
		/**
		 * Similar to DateConvert, but provides local2zone and zone2local conversion from one time zone to another.
		 * 
		 * @param conversionType      Conversion type to use.  Options are zone2local (date object is from the specified time zone and this will convert it to local time) and local2zone (date object is based on local server time and this will convert it to the specfied time zone.):   
		 * @param dateObj      Date object you want to convert. 
		 * @param zoneInfo      Standard time zone abbreviation as well as standard plus mod such as PST-8. 
		 * @return Returns a date/time object. 
		 * @author Chris Wigginton (cwigginton@macromedia.com) 
		 * @version 1, November 26, 2001 
		 */
		  var targetZone = "";
		  var targetSpan = 0;
		  var targetDate = "";
		  var utcDate = "";
		  var hourDiff = 0;
		  var minDiff = 0;
		  var zoneModOffSet = 0;
		  var zoneMod = 0;
		    
		  //timeZone object
		  var timeZone = StructNew();
		  timeZone.UTC  =   0;     // Universal Time Coordinate or universal time zone
		  timeZone.GMT  =   0;     // Greenwich Mean Time same as UTC
		  timeZone.BST  =   1;     // British Summer time
		  timeZone.IST  =   1;     // Irish Summer Time
		  timeZone.WET  =   1;     // Western Europe Time
		  timeZone.WEST =   1;     // Western Europe Summer Time
		  timeZone.CET  =   1;     // Central Europe Time
		  timeZone.CEST =   2;     // Central Europe Summer Time
		  timeZone.EET  =   2;     // Eastern Europe Time
		  timeZone.EEST =   3;     // Eastern Europe Summer Time
		  timeZone.MSK  =   3;     // Moscow time
		  timeZone.MSD  =   4;     // Moscow Summer Time
		  timeZone.AST  =  -4;     // Atlantic Standard Time
		  timeZone.ADT  =  -3;     // Atlantic Daylight Time
		  timeZone.EST  =  -5;     // Eastern Standard Time
		  timeZone.EDT  =  -4;     // Eastern Daylight Saving Time
		  timeZone.CST  =  -6;     // Eastern Time
		  timeZone.CDT  =  -5;     // Central Standard Time
		  timeZone.MST  =  -7;     // Mountain Standard Time
		  timeZone.MDT  =  -6;     // Mountain Daylight Saving Time
		  timeZone.PST  =  -8;     // Pacific Standard Time
		  timeZone.HST  = -10;     // Hawaiian Standard Time
		  timeZone.AKST =  -9;     // Alaska Standard Time
		  timeZone.AKDT =  -8;     // Alaska Standard Daylight Saving Time
		  timeZone.AEST =  10;     // Australian Eastern Standard Time
		  timeZone.AEDT =  11;     // Australian Eastern Daylight Time
		  timeZone.ACST = 9.5;     // Australian Central Standard Time
		  timeZone.ACDT = 10.5;    // Australian Central Daylight Time
		  timeZone.AWST =   8;     // Australian Western Standard Time
		    
		  //Check for +- timezone mod such as PST-4
		  zoneModOffSet = FindOneOf("+-", zoneInfo);
		  if(zoneModOffSet) {
		    //Extract out the zoneInfo and zoneMod
		    zoneMod = Val(Right(zoneInfo, Len(zoneInfo) - zoneModOffSet + 1));
		    zoneInfo = Left(zoneInfo, zonemodOffSet - 1);            
		  }
		    
		  targetZone = timeZone[zoneInfo] + zoneMod;
		    
		  // Grab Target Zone Info
		  hourDiff = fix(targetZone);
		  minDiff = (targetZone - hourDiff) * 60; 
		    
		  targetSpan = CreateTimeSpan(0, hourDiff, minDiff, 0);
		
		  if (conversionType IS "local2zone") {
		    // date is local time so convert it to utc first
		    utcDate = DateConvert("Local2Utc", dateObj) ;
		    // Add the target zone difference
		    targetDate = utcDate + targetSpan;
		    return DateFormat(targetDate, "yyyy-mm-dd ") & TimeFormat(targetDate, "HH:mm:ss");
		  }
		  else if (conversionType is "zone2local") {
		    //date is in the target zone so convert it to utc first
		    targetDate = dateObj - targetSpan;
		    //convert it back from utc to local
		    targetDate = DateConvert("Utc2local", targetDate);    
		    return DateFormat(targetDate, "yyyy-mm-dd ") & TimeFormat(targetDate, "HH:mm:ss");
		  }
		  return "'yyyy-mm-dd HH:mm:ss"; // error return
		</cfscript>
	</cffunction>
</cfcomponent>