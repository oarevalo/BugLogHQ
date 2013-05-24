<cfcomponent name="general" extends="eventHandler">

	<cffunction name="main" access="public" returntype="void">
		<cfscript>
			try {
				oService = getService("app").getServiceLoader();
				aMsgLog = oService.getService().getMessageLog();
				aQueue = oService.getService().getEntryQueue();
				
				// set values
				setValue("aMsgLog", aMsgLog);
				setValue("aQueue", aQueue);
				setValue("pageTitle", "Service Monitor");
				
				setView("serviceMonitor");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("main");
			}
		</cfscript>	
	</cffunction>

	<cffunction name="doProcessQueue" access="public" returntype="void">
		<cfscript>
			var oListener = 0;
			var oService = 0;
			var rtn = 0;

			try {
				oService = getService("app").getServiceLoader();
				oListener = oService.getService();
				rtn = oListener.processQueue( oListener.getKey() );
				setMessage("info","Queue processed (#rtn#)");
				setNextEvent("serviceMonitor.main");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("serviceMonitor.main");
			}
		</cfscript>	
	</cffunction>
		
</cfcomponent>