<!--- xml/setup.cfm  

	This file inserts the default values on the users datafile. This is only needed when
	using the xml data provider.

--->
<cfset oDAOFactory = createObject("component","bugLog.components.dao.DAOFactory").init( expandPath("/bugLog/config/dao-config.xml.cfm") )>

<cfset oUserDAO = oDAOFactory.getDAO("user")>
<cfset oUserDAO.save(username="admin", password="admin")>
