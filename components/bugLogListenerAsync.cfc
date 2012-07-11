<cfcomponent extends="bugLogListener" hint="This listener modified the standard listener so that it processes all bug in an asynchronous manner">
	
	<cfset variables.queue = arrayNew(1)>
	<cfset variables.maxQueueSize = 0>
	<cfset variables.schedulerIntervalSecs = 0>
	<cfset variables.key = "123456knowthybugs654321"> <!--- this is a simple protection to avoid calling processqueue() too easily. This is NOT the apiKey setting --->
	
	<cffunction name="init" access="public" returntype="bugLogListenerAsync" hint="This is the constructor">
		<cfargument name="config" required="true" type="config">
		<cfscript>
			// initialize variables and read settings
			variables.queue = arrayNew(1);
			variables.msgLog = arrayNew(1);
			variables.maxQueueSize = arguments.config.getSetting("service.maxQueueSize");
			variables.schedulerIntervalSecs = arguments.config.getSetting("service.schedulerIntervalSecs");

			// do the normal initialization
			super.init( arguments.config );

			// start scheduler
			startScheduler();
						
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="logEntry" access="public" returntype="void" hint="This method adds a bug report entry into BugLog. Bug reports must be passed as RawEntryBeans">
		<cfargument name="entryBean" type="rawEntryBean" required="true">
		<cflock name="bugLogListenerAsync_logEntry" type="exclusive" timeout="10">
			<cfif arrayLen(variables.queue) lte variables.maxQueueSize>
				<cfset arrayAppend(variables.queue, arguments.entryBean)>
			<cfelse>
				<cfset logMessage("Queue full! Discarding entry.")>
			</cfif>
		</cflock>
	</cffunction>	
	
	<cffunction name="processQueue" access="public" returntype="numeric" hint="Processes all entries on the queue">
		<cfargument name="key" type="string" required="true">
		<cfset var myQueue = arrayNew(1)>
		<cfset var i = 0>
		<cfset var errorQueue = arrayNew(1)>
		<cfset var count = 0>
		<cfset var dp = variables.oDAOFactory.getDataProvider()>
		
		<cfif arguments.key neq variables.key>
			<cfset logMessage("Invalid key received. Exiting.")>
			<cfreturn 0>
		</cfif>
		
		<cflock name="bugLogListenerAsync_processQueue" type="exclusive" timeout="10">
			<cfset myQueue = duplicate(variables.queue)> <!--- get a snapshot of the queue as of right now --->
			<cfset variables.queue = arrayNew(1)>	<!--- clear the queue now --->
			<cfset variables.oRuleProcessor.processQueueStart(myQueue, dp, variables.oConfig )>
			<cfif arrayLen(myQueue) gt 0>
				<cfset logMessage("Processing queue. Queue size: #arrayLen(myQueue)#")>
				<cfloop from="1" to="#arrayLen(myQueue)#" index="i">
					<cftry>
						<cfset super.logEntry(myQueue[i])>
						<cfset count = count + 1>
						<cfcatch type="any">
							<!--- log error and save entry in another queue --->
							<cfset arrayAppend(errorQueue,myQueue[i])>
							<cfset logMessage("ERROR: #cfcatch.message# #cfcatch.detail#. Original message in entry: '#myQueue[i].getMessage()#'")>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfif>
			<cfset variables.oRuleProcessor.processQueueEnd(myQueue, dp, variables.oConfig )>
		</cflock>
			
		<!--- add back all entries on the error queue to the main queue --->
		<cfloop from="1" to="#arrayLen(errorQueue)#" index="i">
			<cfset logEntry(errorQueue[i])>
		</cfloop>
		<cfif arrayLen(errorQueue) gt 0>
			<cfset logMessage("Failed to add #arrayLen(errorQueue)# entries. Returned entries to main queue. To clear up queue and discard this entries reset the listener.")>
		</cfif>
		
		<cfreturn count>
	</cffunction>

	<cffunction name="shutDown" access="public" returntype="void" hint="Performs any clean up action required">
		<cfset logMessage("Stopping BugLogListener service...")>
		<cfset logMessage("Stopping ProcessQueue scheduled task...")>
		<cftry>
			<cfschedule action="delete" task="bugLogProcessQueue" />
			<cfcatch type="any">
				<cfif findNoCase("coldfusion.scheduling.SchedulingNoSuchTaskException",cfcatch.stackTrace)>
					<!--- it's ok, nothing to do here --->
					<cfset logMessage("Scheduled task was not running.")>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>				
		</cftry>
		<cfset logMessage("Processing remaining elements in queue...")>
		<cfset processQueue(variables.key)>
		<cfset logMessage("BugLogListener service stopped.")>
	</cffunction>
	
	
	<!--- Private methods --->
		
	<cffunction name="startScheduler" access="private" output="false" returntype="void">
		<cfscript>
			var thisHost = "";
			if(cgi.server_port_secure) thisHost = "https://"; else thisHost = "http://";
			thisHost = thisHost & cgi.server_name;
			if(cgi.server_port neq 80) thisHost = thisHost & ":" & cgi.server_port;
		</cfscript>

		<cfschedule action="update"
			task="bugLogProcessQueue"
			operation="HTTPRequest"
			startDate="#createDate(1990,1,1)#"
			startTime="00:00"
			endTime="23:59"
			url="#thisHost#/bugLog/util/processQueue.cfm?key=#variables.KEY#"
			interval="#variables.schedulerIntervalSecs#"
		/>		
	</cffunction>
	
	
	<!--- Getters --->
	
	<cffunction name="getMessageLog" access="public" returntype="array">
		<cfreturn variables.msgLog>
	</cffunction>

	<cffunction name="getEntryQueue" access="public" returntype="array">
		<cfreturn variables.queue>
	</cffunction>

	<cffunction name="getKey" access="public" returntype="string">
		<cfreturn variables.key>
	</cffunction>
	
</cfcomponent>