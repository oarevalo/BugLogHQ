<cfcomponent name="ehStats" extends="eventHandler">

	<cffunction name="dspMain">
		<cfscript>
			qryEntries = getService("app").searchEntries("");
			setValue("qryEntries", qryEntries);
			setView("vwStats");
		</cfscript>
	</cffunction>

</cfcomponent>