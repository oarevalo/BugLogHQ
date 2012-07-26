<cfset testDriver = createObject("component","bugLog.test.lib.testDriver").init()>
<style type="text/css">
	.scenario {font-family:arial; border-bottom:1px solid silver;margin-bottom:20px;}
	.scenario > label {font-weight:bold;font-size:14px;margin-bottom:5px;}
	.scenario-tests {margin-left:30px;margin-top:8px;}
	.test { font-size:13px; font-family:arial; margin-bottom:10px; }
	.success label {font-weight:bold;color:green;}
	.failure label {font-weight:bold;color:red;}
</style>
<cfscript>
	// Scenario:  default buglog location, default instance
	scenario = "default buglog location, default instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","");
	instance = "default";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = target.getCurrentHost() & "/bugLog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = target.getCurrentHost() & "/bugLog/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = target.getCurrentHost() & "/bugLog/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = target.getCurrentHost() & "/bugLog/hq/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);



	// Scenario:  default buglog location, named instance
	scenario = "default buglog location, named instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","");
	instance = "myinstance";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = target.getCurrentHost() & "/myinstance/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = target.getCurrentHost() & "/myinstance/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = target.getCurrentHost() & "/bugLog/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = target.getCurrentHost() & "/myinstance/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);




	// Scenario:  root buglog location, default instance
	scenario = "root buglog location, default instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","/");
	instance = "default";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = target.getCurrentHost() & "/hq/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = target.getCurrentHost() & "/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = target.getCurrentHost() & "/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = target.getCurrentHost() & "/hq/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);





	// Scenario:  root buglog location, named instance
	scenario = "root buglog location, named instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","/");
	instance = "myinstance";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = target.getCurrentHost() & "/myinstance/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = target.getCurrentHost() & "/myinstance/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = target.getCurrentHost() & "/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = target.getCurrentHost() & "/myinstance/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);





	// Scenario:  custom buglog location (no url), default instance
	scenario = "custom buglog location (no url), default instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","/mybuglog");
	instance = "default";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = target.getCurrentHost() & "/mybuglog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = target.getCurrentHost() & "/mybuglog/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = target.getCurrentHost() & "/mybuglog/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = target.getCurrentHost() & "/mybuglog/hq/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);






	// Scenario:  custom buglog location (no url), named instance
	scenario = "custom buglog location (no url), named instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","/mybuglog");
	instance = "myinstance";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = target.getCurrentHost() & "/mybuglog/myinstance/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = target.getCurrentHost() & "/mybuglog/myinstance/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = target.getCurrentHost() & "/mybuglog/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = target.getCurrentHost() & "/mybuglog/myinstance/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);




	// Scenario:  custom buglog location (with url to root), default instance
	scenario = "custom buglog location (with url to root), default instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","https://buglog.somedomain.org/");
	instance = "default";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = "https://buglog.somedomain.org/hq/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = "https://buglog.somedomain.org/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = "https://buglog.somedomain.org/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = "https://buglog.somedomain.org/hq/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);




	// Scenario:  custom buglog location (with url to root), named instance
	scenario = "custom buglog location (with url to root), named instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","https://buglog.somedomain.org/");
	instance = "myinstance";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = "https://buglog.somedomain.org/myinstance/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = "https://buglog.somedomain.org/myinstance/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = "https://buglog.somedomain.org/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = "https://buglog.somedomain.org/myinstance/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);



	// Scenario:  custom buglog location (with url to default dir), default instance
	scenario = "custom buglog location (with url to default dir), default instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","https://buglog.somedomain.org/bugLog");
	instance = "default";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = "https://buglog.somedomain.org/bugLog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = "https://buglog.somedomain.org/bugLog/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = "https://buglog.somedomain.org/bugLog/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = "https://buglog.somedomain.org/bugLog/hq/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);




	// Scenario:  custom buglog location (with url to default dir), named instance
	scenario = "custom buglog location (with url to default dir), named instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","https://buglog.somedomain.org/bugLog");
	instance = "myinstance";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = "https://buglog.somedomain.org/bugLog/myinstance/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = "https://buglog.somedomain.org/bugLog/myinstance/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = "https://buglog.somedomain.org/bugLog/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = "https://buglog.somedomain.org/bugLog/myinstance/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);



	// Scenario:  custom buglog location (with url to custom dir), default instance
	scenario = "custom buglog location (with url to custom dir), default instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","https://buglog.somedomain.org/mybuglog");
	instance = "default";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = "https://buglog.somedomain.org/mybuglog/hq/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = "https://buglog.somedomain.org/mybuglog/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = "https://buglog.somedomain.org/mybuglog/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = "https://buglog.somedomain.org/mybuglog/hq/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);




	// Scenario:  custom buglog location (with url to custom dir), named instance
	scenario = "custom buglog location (with url to custom dir), named instance";
	target = createObject("component","bugLog.components.util").init();
	config = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock")
					.setSetting("general.externalURL","https://buglog.somedomain.org/mybuglog");
	instance = "myinstance";

	tests = [{
		name = "getBugEntryHREF()",
		actual = target.getBugEntryHREF(123,config,instance),
		expected = "https://buglog.somedomain.org/mybuglog/myinstance/index.cfm?event=ehGeneral.dspEntry&entryID=123"
	},{
		name = "getBaseBugLogHREF()",
		actual = target.getBaseBugLogHREF(config,instance),
		expected = "https://buglog.somedomain.org/mybuglog/myinstance/"
	},{
		name = "getBugLogHQAssetsHREF()",
		actual = target.getBugLogHQAssetsHREF(config),
		expected = "https://buglog.somedomain.org/mybuglog/hq/"
	},{
		name = "getBugLogHQAppHREF()",
		actual = target.getBugLogHQAppHREF(config,instance),
		expected = "https://buglog.somedomain.org/mybuglog/myinstance/"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);
	
</cfscript>
