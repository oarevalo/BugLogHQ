<!--- This template displays a system message --->

<!--- This indicates how to find the images within the HTML --->
<cfset IMAGES_ROOT = "core/images">
<cfif isDefined("request.requestState._coreImagesPath")>
	<cfset IMAGES_ROOT = request.requestState._coreImagesPath>
</cfif>

<!--- message contents are stored in cookies to persist across requests --->
<cfparam name="cookie.message_type" default="">
<cfparam name="cookie.message_text" default="">
<cfset msgStruct.type = cookie.message_type>
<cfset msgStruct.text = cookie.message_text>

<!--- expire cookies instead of just deleting them because of bluedragon compatibility,
seems that deleting from the cookie struct in BD does not actually erase the cookie --->
<cfcookie name="message_type" expires="now" value="">
<cfcookie name="message_text" expires="now" value="">
		
<!--- Render Message --->		
<cfif msgStruct.text neq "">
	<!--- Get image to display --->
	<cfif CompareNocase(msgStruct.type, "error") eq 0>
		<cfset img = "emsg.gif">
	<cfelseif CompareNocase(msgStruct.type, "warning") eq 0>
		<cfset img = "wmsg.gif">
	<cfelse>
		<cfset img = "cmsg.gif">
	</cfif>
	
	<cfoutput>
		<style type="text/css">
			##app_messagebox {
				border:1px dotted ##999999;
				background: ##FFFFE0;
				font-family: Arial, Helvetica, sans-serif;
				font-size: 11px;
				font-weight: bold;
				padding:10px;
			}
		</style>
				
		<div id="app_messagebox">
			<img src="#IMAGES_ROOT#/#img#" align="absmiddle" alt="[#msgStruct.type#]"> #msgStruct.text#
		</div>
	</cfoutput>
</cfif>
