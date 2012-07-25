<cfcomponent>
	
	<cffunction name="init" access="public" returntype="schedulerService">
		<cfargument name="config" required="true" type="config">
		<cfargument name="instanceName" type="string" required="true">
		<cfscript>
			variables.config = arguments.config;		// global configuration
			variables.instanceName = arguments.instanceName;
			return this;
		</cfscript>		
	</cffunction>

	<cffunction name="setupTask" access="public" returnType="void" hint="adds or updates a scheduled task">
		<cfargument name="taskName" type="string" required="true">
		<cfargument name="taskPath" type="string" required="true" hint="the relative path from the bugLog root to where the task template is located">
		<cfargument name="startTime" type="string" required="true">
		<cfargument name="interval" type="string" required="true">
		<cfargument name="params" type="array" required="false" default="#arrayNew(1)#" hint="additional query arguments to pass to the scheduled task href. This is an array of structs with keys: name,value">
		<cfscript>
			var utils = createObject("component","bugLog.components.util").init();
			
			var href = utils.getBaseBugLogHREF(config, "default") 
						& arguments.taskPath 
						& "?instance=" & instanceName;
						
			for(var i=1;i lte arrayLen(arguments.params);i++) {
				href = href & "&" & arguments.params[i].name & "=" & arguments.params[i].value;
			}
		</cfscript>

		<cfschedule action="update"
			task="#arguments.taskName#_#instanceName#"
			operation="HTTPRequest"
			startDate="#createDate(1990,1,1)#"
			startTime="#arguments.startTime#"
			url="#href#"
			interval="#arguments.interval#"
		/>		
	</cffunction>

	<cffunction name="removeTask" access="public" returnType="void" hint="deletes a scheduled task">
		<cfargument name="taskName" type="string" required="true">
		<cftry>
			<cfschedule action="delete" task="#arguments.taskName#_#variables.instanceName#" />
			<cfcatch type="any">
				<cfif findNoCase("coldfusion.scheduling.SchedulingNoSuchTaskException",cfcatch.stackTrace)>
					<!--- it's ok, nothing to do here --->
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>			
		</cftry>
	</cffunction>

</cfcomponent>