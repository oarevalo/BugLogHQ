<cfsetting requesttimeout="999999"> 

<cfparam name="url.key" type="string" default="">
<cfparam name="url.instance" type="string" default="">

<cfscript>
    bugLogClient = createObject("component", "bugLog.client.bugLogService").init("bugLog.listeners.bugLogListenerWS");

    try {
        // Handle service initialization if necessary
        oService = createObject("component", "bugLog.components.service").init( instanceName = url.instance );

        // process pending queue
        if(oService.isRunning()) {
            oBugLogListener = oService.getService();
            
            // process all new incoming bug reports
            oBugLogListener.processQueue( url.key );

            // process rules for newly added reports
            oBugLogListener.processRules( url.key );
         }
    
    } catch(any e) {
        // report the error
        bugLogClient.notifyService(e.message, e);
    }
</cfscript>
