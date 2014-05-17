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
	// Scenario:  mock config proviver
	scenario = "mock config provider";
	target = createObject("component","bugLog.components.config")
					.init("bugLog.test.lib.mock");

	target
		.setSetting("TestA", 123)
		.setSetting("TestB", 456);

	tests = [{
		name = "getSetting()",
		actual = target.getSetting("TestA"),
		expected = 123
	},
	{
		name = "getSetting() (with default)",
		actual = target.getSetting("TestB",456),
		expected = 456
	},
	{
		name = "getConfigKey()",
		actual = target.getConfigKey(),
		expected = "test"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);

	// Scenario: xmlConfigProvider (default environment)
	scenario = "xml config provider (default environment)";
	target = createObject("component","bugLog.components.config")
					.init(configProviderType = "xml", 
							configDoc = "/bugLog/test/lib/test-config.xml");

	tests = [{
		name = "getSetting()",
		actual = target.getSetting("db.dsn"),
		expected = "bugLog"
	},
	{
		name = "getConfigKey()",
		actual = target.getConfigKey(),
		expected = ""
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);

	// Scenario: xmlConfigProvider (custom environment)
	scenario = "xml config provider (custom environment)";
	target = createObject("component","bugLog.components.config")
					.init(configProviderType = "xml", 
							configDoc = "/bugLog/test/lib/test-config.xml",
							configKey = "dev");

	tests = [{
		name = "getSetting()",
		actual = target.getSetting("db.dsn"),
		expected = "bugLog_dev"
	},
	{
		name = "getSetting() (with default to global)",
		actual = target.getSetting("general.adminEmail"),
		expected = "info@somedomain.org"
	},
	{
		name = "getConfigKey()",
		actual = target.getConfigKey(),
		expected = "dev"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);

	// Scenario: xmlConfigProvider (another custom environment)
	scenario = "xml config provider (another custom environment)";
	target = createObject("component","bugLog.components.config")
					.init(configProviderType = "xml", 
							configDoc = "/bugLog/test/lib/test-config.xml",
							configKey = "qa");

	tests = [{
		name = "getSetting()",
		actual = target.getSetting("db.dsn"),
		expected = "bugLog_qa"
	},
	{
		name = "getSetting() (with default to global)",
		actual = target.getSetting("general.adminEmail"),
		expected = "info@somedomain.org"
	},
	{
		name = "getConfigKey()",
		actual = target.getConfigKey(),
		expected = "qa"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);

	// Scenario: xmlConfigProvider (unknown custom environment)
	scenario = "xml config provider (unknown custom environment)";
	target = createObject("component","bugLog.components.config")
					.init(configProviderType = "xml", 
							configDoc = "/bugLog/test/lib/test-config.xml",
							configKey = "live");

	tests = [{
		name = "getSetting()",
		actual = target.getSetting("db.dsn"),
		expected = "bugLog"
	},
	{
		name = "getSetting() (with default to global)",
		actual = target.getSetting("general.adminEmail"),
		expected = "info@somedomain.org"
	},
	{
		name = "getConfigKey()",
		actual = target.getConfigKey(),
		expected = "live"
	}];
	writeOutput(testDriver.evaluateScenario(scenario,tests).html);


</cfscript>