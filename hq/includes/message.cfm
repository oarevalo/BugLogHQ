<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
Template :  messagebox.cfm 
Author 	 :	Luis Majano
Date     :	October 10, 2005
Description : 			
	This is the display of the frameworks messagebox. 
	You can customize this as you want.
				
Modification History:		
01/16/2006	-	Added support for child apps.
5/3/07 - modified for the new application framework. oarevalo.
----------------------------------------------------------------------->

<cfparam name="cookie.message_type" default="">
<cfparam name="cookie.message_text" default="">

<cfset msgStruct.type = cookie.message_type>
<cfset msgStruct.text = cookie.message_text>

<cfset structDelete(cookie,"message_type")>
<cfset structDelete(cookie,"message_text")>
		
		
<cfif msgStruct.text neq "">
	<!--- Get image to display --->
	<cfif CompareNocase(msgStruct.type, "error") eq 0>
		<cfset img = "images/emsg.gif">
	<cfelseif CompareNocase(msgStruct.type, "warning") eq 0>
		<cfset img = "images/wmsg.gif">
	<cfelse>
		<cfset img = "images/cmsg.gif">
	</cfif>
	
	<cfoutput>
		<!--- Style Declarations --->
		<style>
			.fw_messageboxTable{
				border:1px dotted ##999999;
				background: ##FFFFE0;
				padding: 3px 3px 3px 3px;
			}
			.fw_messageboxMessage{
				font-family: Arial, Helvetica, sans-serif;
				font-size: 11px;
				font-weight: bold;
			}
		</style>
	
		<!--- Message Box --->
		<cfif len(msgStruct.text) gt 130>
			<cfset style = "overflow: auto; height:40px;">
		<cfelse>
			<cfset style = "overflow: auto;">
		</cfif>
		
		<table width="99%" border="0" align="center" cellpadding="0" cellspacing="5" class="fw_messageboxTable">
		  <tr>
		    <td width="30" align="center" valign="top"><img src="#img#"></td>
		    <td class="fw_messageboxMessage">#msgStruct.text#</td>
		  </tr>
		</table>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">

