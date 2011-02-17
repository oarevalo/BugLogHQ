/************* Connect View ***********/
function initConnectView() {
	serverInfo = doGetServerInfo();
	$("#server").val(serverInfo.server);
	$("#username").val(serverInfo.username);
	$("#password").val(serverInfo.password);
	$("#rememberMe").attr("checked",serverInfo.rememberMe);
	$("#btnConnect").click(function(){
		frm = this.form;
		doConnect(frm.server.value,
						frm.username.value,
						frm.password.value,
						frm.rememberMe.checked);
	});
}

/************* Main View ***********/
function initMainView() {
	mainViewCallback = displaySummary;
	doGetSummary();
}

function displaySummary(data) {
	var div = $("#contentArea");
	div.html("");
	
	if(data.length > 0) {
		for(var i=0;i < data.length;i++) {
			div.append(createSummaryCapsuleHTML(data[i]));
		}
		$(".entryCapsule").click(viewListing);
	} else {
		div.html("<br /><p align='center' style='font-size:16px;'>No bug reports found. Yay!</a>");
	}
	
	// set the timer
	doSetListingRefreshTimer();
}

function viewListing(e) {
	var entryID = this.getAttribute("entryID");
	doGetListing(entryID, displayListing);
}
function displayListing(data) {
	var div = $("#contentArea");
	div.html("");
	
	if(data.length > 0) {
		var tmpHTML = "<div class='entryListingHeader'>"
			tmpHTML += "<div class='entryCapsuleApplication'>" + data[0].ApplicationCode + "</div>";
			tmpHTML += "<div class='entryCapsuleMessage'>" + data[0].Message + "</div>";
			tmpHTML += "</div>"
		div.append(tmpHTML);

		for(var i=0;i < data.length;i++) {
			div.append(createListingCapsuleHTML(data[i]));
		}
		$(".entryCapsule").click(viewEntry);
	}

	$("#goBackHandle").click(doGoBack).show();
}


function viewEntry(e) {
	var entryID = this.getAttribute("entryID");
	doGetEntry(entryID, displayEntry);
}
function displayEntry(data) {
	$("#contentArea").html(createEntryHTML(data[0]));
	$("#goBackHandle").click(doGoBack).show();
}

function doGoBack() {
	setView("main");
}

function createSummaryCapsuleHTML(entry) {
	var tmpHTML = "<div class='entryCapsule' entryID='" + entry.EntryID + "' applicationID='" + entry.ApplicationID + "'>";
		tmpHTML += "<div class='entryCapsuleBugCount'>"
		tmpHTML += "<img src='/bugLog/hq/images/severity/" + entry.SeverityCode.toLowerCase() + ".png'><br>"
		tmpHTML += entry.bugCount 
		tmpHTML += "</div>";
		tmpHTML += "<div class='entryCapsuleApplication'>" + entry.ApplicationCode + "</div>";
		tmpHTML += "<div class='entryCapsuleMessage' id='entryMessage_" + entry.EntryID + "'>" + entry.Message + "</div>";
		tmpHTML += "<div class='entryCapsuleDate'>Last: " + entry.createdOn + "</div>";
		tmpHTML += "</div>";
	return tmpHTML;				
}
function createListingCapsuleHTML(entry) {
	var tmpHTML = "<div class='entryCapsule' entryID='" + entry.EntryID + "'>";
		tmpHTML += "<div class='entryCapsuleHost' style='float:right;'>" + entry.HostName + "</div>";
		tmpHTML += "<div class='entryCapsuleDate'>";
		tmpHTML += "<img src='/bugLog/hq/images/severity/" + entry.SeverityCode.toLowerCase() + ".png' align='absmiddle'>&nbsp;"
		tmpHTML += entry.createdOn + "</div>"
		tmpHTML += "</div>";
	return tmpHTML;				
}
function createEntryHTML(entry) {
	var tmpHTML = "<table class='entryDetailTable'>";
	tmpHTML += "<tr><td colspan='2' class='entryDetailTitle'>" 
	tmpHTML += "<img src='/bugLog/hq/images/severity/" + jQuery.trim(entry.SeverityCode).toLowerCase()  + ".png' align='absmiddle' style='float:left;margin-right:3px;margin-top:5px;'>"
	tmpHTML += entry.Message + "</td></tr>";
	tmpHTML += "<tr><th>Application:</th><td>" + entry["ApplicationCode"] + "</td></tr>";
	tmpHTML += "<tr><th>Host:</th><td>" + entry.HostName+ "</td></tr>";
	tmpHTML += "<tr><th>Date/Time:</th><td>" + entry.createdOn + "</td></tr>";
	tmpHTML += "<tr><th>Severity:</th><td>" + entry.SeverityCode + "</td></tr>";
	if(entry.ExceptionMessage!='')
		tmpHTML += "<tr><th>Exception Message:</th><td>" + entry.ExceptionMessage + "&nbsp;</td></tr>";
	if(entry.ExceptionDetails!='')
		tmpHTML += "<tr><th>Exception Details:</th><td>" + entry.ExceptionDetails + "&nbsp;</td></tr>";
	if(entry.BugCFID!='' || entry.BugCFTOKEN!='')
		tmpHTML += "<tr><th>CFID/CFTOKEN:</th><td>" + entry.BugCFID + " / " + entry.BugCFTOKEN + "</td></tr>";
	tmpHTML += "<tr><th>User Agent:</th><td>" + entry.UserAgent + "</td></tr>";
	tmpHTML += "<tr><th>Template Path:</th><td>" + entry.TemplatePath + "</td></tr>";
	tmpHTML += "</table><br/><b>Full Report:</b><br />" + entry.HTMLReport;
	return tmpHTML;				
}


/************* Config View ***********/
function initConfigView() {
	alert('full5')
	serverInfo = doGetServerInfo();
	$("#numDays").val(serverInfo.numDays);
	
	doGetApplications( doPopulateApplications );
	doGetHosts( doPopulateHosts );
	doGetSeverities( doPopulateSeverities );
	
	$("#btnSave").click(function(){
		frm = this.form;
		var severities = new Array();
		for(var i=0;i<frm.severityID.length;i++) {
			if(frm.severityID[i].checked) {
				severities[severities.length] = frm.severityID[i].value;
			}
		}
		doSaveSettings(frm.numDays.value, 
						frm.applicationID.value, 
						frm.hostID.value, 
						"");
	});
}

function doPopulateApplications(items) {
	for(var i=0;i < items.length;i++) {
		$("#applicationID").
	          append($("<option></option>").
              attr("value",items[i].appID).
              attr("selected",(serverInfo.applicationID==items[i].appID)).
              text(items[i].appCode)); 
	}
	$("#applicationID").attr("disabled",false);
}
function doPopulateHosts(items) {
	for(var i=0;i < items.length;i++) {
		$("#hostID").
          append($("<option></option>").
          attr("value",items[i].hostID).
          attr("selected",(serverInfo.hostID==items[i].hostID)).
          text(items[i].hostName)); 
	}
	$("#hostID").attr("disabled",false);
}
function doPopulateSeverities(items) {
	var severities = new Array();
	severities = serverInfo.severities.split(",");
	
	var tmpHTML = "";
	for(var i=0;i < items.length;i++) {
		tmpHTML += "<input type='checkbox' name='severityID' value='"+items[i].severityID +"'";
		if(severities.indexOf(items[i].severityID)!=-1) tmpHTML += " checked";
		tmpHTML += "><img src='/bugLog/hq/images/severity/" + items[i].code.trim().toLowerCase()  + ".png' align='absmiddle'> ";
		tmpHTML += items[i].name + "<br/>";
	}
	$("#severitiesContainer").html(tmpHTML);
}

