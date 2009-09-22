<?xml version="1.0" encoding="UTF-8"?>
<config>
	<setting name="general.adminEmail">admin@somedomain.org</setting>
	<setting name="general.externalURL"></setting>
	
	<setting name="db.dsn">bugLog</setting>
	<setting name="db.dbtype">mysql</setting>
	<setting name="db.username"></setting>
	<setting name="db.password"></setting>

	<setting name="service.serviceCFC">bugLog.components.bugLogListenerAsync</setting>
	<setting name="service.autoStart">true</setting>
	<setting name="service.requireAPIKey">false</setting>
	<setting name="service.API">2CF20630-DD24-491F-BA44314842183AFC</setting>
	<setting name="service.maxQueueSize">1000</setting>
	<setting name="service.maxLogSize">20</setting>
	<setting name="service.schedulerIntervalSecs">120</setting>

	<setting name="jira.enabled">false</setting>
	<setting name="jira.wsdl"></setting>
	<setting name="jira.username"></setting>
	<setting name="jira.password"></setting>
</config>