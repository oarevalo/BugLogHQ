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
		<cfset extclass = "alert-error">
		<cfset autodismiss = false>
	<cfelseif CompareNocase(msgStruct.type, "warning") eq 0>
		<cfset img = "wmsg.gif">
		<cfset extclass = "">
		<cfset autodismiss = false>
	<cfelse>
		<cfset img = "cmsg.gif">
		<cfset extclass = "alert-success">
		<cfset autodismiss = true>
	</cfif>
	
	<cfoutput>
		<div class="alert #extclass#" id="alert">
			<a class="close" data-dismiss="alert">&times;</a>
			<img src="#IMAGES_ROOT#/#img#" align="absmiddle" alt="#msgStruct.type#"> #msgStruct.text#
		</div>
		<cfif autodismiss>
			<script type="text/javascript">__removeAlert = true;</script>
		</cfif>
	</cfoutput>
</cfif>
