<?xml version="1.0" encoding="UTF-8"?>
<config>
	<setting name="general.adminEmail">info@oscararevalo.com</setting>
	<setting name="general.externalURL" />
	<setting name="general.dateFormat">mm/dd/yy</setting>
	<!-- all dates/times are based on the current server time,
		but you can use the following setting to display times
		on a different time zone. Keep in mind that this is a basic
		offset calculation and does not handle things like daylight savings
		time and such. Use the format: "UTC+/-{hour offset}". Ex UTC+8 -->
	<setting name="general.timezoneInfo"></setting>
	<setting name="db.dsn">bugLog</setting>
	<setting name="db.dbtype">mysql</setting>
	<setting name="db.username" />
	<setting name="db.password" />
	<setting name="service.serviceCFC">bugLog.components.bugLogListenerAsync</setting>
	<setting name="service.autoStart">true</setting>
	<setting name="service.requireAPIKey">false</setting>
	<setting name="service.APIKey">2CF20630-DD24-491F-BA44314842183AFC</setting>
	<setting name="service.maxQueueSize">1000</setting>
	<setting name="service.maxLogSize">20</setting>
	<setting name="service.schedulerIntervalSecs">120</setting>
	<setting name="jira.enabled">false</setting>
	<setting name="jira.wsdl" />
	<setting name="jira.username" />
	<setting name="jira.password" />
	<setting name="purging.numberOfDays">15</setting>
	<setting name="purging.enabled">true</setting>
	<setting name="digest.enabled">true</setting>
	<setting name="digest.recipients">oarevalo@gmail.com</setting>
	<setting name="digest.schedulerIntervalHours">24</setting>
	<setting name="digest.schedulerStartTime">06:00</setting>
	<setting name="digest.sendIfEmpty">true</setting>
	<setting name="digest.severity" />
	<setting name="digest.application" />
	<setting name="digest.host" />
</config>
