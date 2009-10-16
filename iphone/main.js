var bugLogDefaultPath = ""
var bugLogHQPath = "/bugLog/hq/"
var bugLogProxyPath = "/bugLog/bugLogProxy.cfm"
var bugLogProtocol = "http"

var serverInfo = {
	username: "",
	password: "",
	server: "",
	token: "",
	rememberMe: false
};

var listingRefreshTimer = 0;

function initApp() {
	
	// attach actions
	document.getElementById("app_refresh").addEventListener("click", doRefresh, false);
	document.getElementById("app_refresh_text").addEventListener("click", doRefresh, false);
	document.getElementById("app_logoff").addEventListener("click", doLogOff, false);
	document.getElementById("app_logoff_text").addEventListener("click", doLogOff, false);

	// load any stored login credentials
	loadServerInfo();

	// display connect page
	setView("connect");
}

function setView(vw) {
	document.getElementById('UI').contentWindow.location="views/" + vw + ".html";
} 

function resizeUI(e) {
	var newWindowHeight = e.afterBounds.height;
	var ui = document.getElementById('UI');
	ui.style.height = newWindowHeight-80;
}

function doRefresh() {
	if(serverInfo.token!="") 
		setView("main");
	else
		setView("connect");
}

function doGoHome() {
	if(serverInfo.token!="") {
		var url = bugLogProtocol + "://" + serverInfo.server + bugLogHQPath;
		doOpenURL(url);
	}
	else
		alert("Please connect to a BugLog server");
}

function doOpenURL(url) {
	document.location = url;
}

function doLogOff() {
	serverInfo.token = "";
	clearInterval(listingRefreshTimer);
	setView("connect");
}

function doConnect(srv,usr,pwd,rem) {
	if(srv==null || srv=='') {alert("Server cannot be empty"); return;}
	if(usr==null || usr=='') {alert("Username cannot be empty"); return;}
	if(pwd==null || pwd=='') {alert("Password cannot be empty"); return;}
	
	var url = bugLogProtocol + "://" + srv + bugLogProxyPath;
		url += "?action=checkLogin";
		url += "&username="+usr;
		url += "&password="+pwd;

	setView("../loading");

	xmlhttp = new XMLHttpRequest();
	xmlhttp.open("POST", url, true);
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4) {
			if (xmlhttp.status == 200) {
	
				// check for errors				
				var errorNode = xmlhttp.responseXML.getElementsByTagName("error");
				if(errorNode[0].firstChild.nodeValue == "true") {
					var errorMsgNode = xmlhttp.responseXML.getElementsByTagName("errorMessage");
					alert(errorMsgNode[0].firstChild.nodeValue);
					setView("connect");
					return;
				}
				
				// get authentication token
				resultsNode = xmlhttp.responseXML.getElementsByTagName("results");
				
				serverInfo.username = usr;
				serverInfo.password = pwd;
				serverInfo.server = srv;
				serverInfo.token = resultsNode[0].firstChild.nodeValue;
				serverInfo.rememberMe = rem;

				if(rem) 				
					storeServerInfo();
				else
					clearServerInfo();
				
				setView("main");
	
			} else {
				alert("There was a problem connecting to the BugLog server:\n" + xmlhttp.statusText);
				alert(xmlhttp.status);
				setView("connect");
			}			
		}
	};
	xmlhttp.send(null); 
}

function doGetSummary() {
	var aEntries = new Array();

	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getSummary";
		url += "&token="+serverInfo.token;

	clearInterval(listingRefreshTimer);
	document.getElementById("app_refresh_text").innerHTML = "Loading...";

	xmlhttp = new XMLHttpRequest();
	xmlhttp.open("POST", url, true);
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4) {
			if (xmlhttp.status == 200) {

				document.getElementById("app_refresh_text").innerHTML = "Refresh";

				// check for errors				
				var errorNode = xmlhttp.responseXML.getElementsByTagName("error");
				if(errorNode[0].firstChild.nodeValue == "true") {
					var errorMsgNode = xmlhttp.responseXML.getElementsByTagName("errorMessage");
					alert(errorMsgNode[0].firstChild.nodeValue);
					return;
				}

				// create an array with the returned entries	
				try {			
					var dataNodes = xmlhttp.responseXML.getElementsByTagName("entry");
					for(var i=0; i < dataNodes.length;i++) {
						var entry = {};					
						entry.ApplicationCode = getElementTextNS("", "ApplicationCode", dataNodes[i], 0)
						entry.ApplicationID = getElementTextNS("", "ApplicationID", dataNodes[i], 0)
						entry.Message = getElementTextNS("", "Message", dataNodes[i], 0)
						entry.bugCount = getElementTextNS("", "bugCount", dataNodes[i], 0)
						entry.createdOn = getElementTextNS("", "createdOn", dataNodes[i], 0)
						entry.EntryID = getElementTextNS("", "EntryID", dataNodes[i], 0)
						entry.SeverityCode = getElementTextNS("", "SeverityCode", dataNodes[i], 0)
						aEntries[i] = entry;
					}				

					// call a method on the view to display the entries
					document.getElementById('UI').contentWindow.displaySummary(aEntries);

				} catch(e) {
					document.getElementById('UI').contentWindow.displayError(e);
				}
				
	
			} else {
				alert("There was a problem connecting to the BugLog server:\n" + xmlhttp.statusText);
			}			
		}
	};
	xmlhttp.send(null); 

}

function doGetListing(appID,entryID) {
	var aEntries = new Array();

	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getListing";
		url += "&applicationID="+appID;
		url += "&msgFromEntryID="+entryID;
		url += "&token="+serverInfo.token;

	clearInterval(listingRefreshTimer);
	document.getElementById("app_refresh_text").innerHTML = "Loading...";

	xmlhttp = new XMLHttpRequest();
	xmlhttp.open("POST", url, true);
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4) {
			if (xmlhttp.status == 200) {

				document.getElementById("app_refresh_text").innerHTML = "Refresh";

				// check for errors				
				var errorNode = xmlhttp.responseXML.getElementsByTagName("error");
				if(errorNode[0].firstChild.nodeValue == "true") {
					var errorMsgNode = xmlhttp.responseXML.getElementsByTagName("errorMessage");
					alert(errorMsgNode[0].firstChild.nodeValue);
					return;
				}

				// create an array with the returned entries	
				//try {			
					var dataNodes = xmlhttp.responseXML.getElementsByTagName("entry");
					for(var i=0; i < dataNodes.length;i++) {
						var entry = {};					
						entry.ApplicationCode = getElementTextNS("", "ApplicationCode", dataNodes[i], 0)
						entry.ApplicationID = getElementTextNS("", "ApplicationID", dataNodes[i], 0)
						entry.HostName = getElementTextNS("", "HostName", dataNodes[i], 0)
						entry.HostID = getElementTextNS("", "HostID", dataNodes[i], 0)
						entry.Message = getElementTextNS("", "Message", dataNodes[i], 0)
						entry.bugCount = 1
						entry.createdOn = getElementTextNS("", "createdOn", dataNodes[i], 0)
						entry.EntryID = getElementTextNS("", "EntryID", dataNodes[i], 0)
						entry.SeverityCode = getElementTextNS("", "SeverityCode", dataNodes[i], 0)
						aEntries[i] = entry;
					}				

					// call a method on the view to display the entries
					document.getElementById('UI').contentWindow.displayListing(aEntries);

				//} catch(e) {
				//	document.getElementById('UI').contentWindow.displayError(e);
				//}
				
	
			} else {
				alert("There was a problem connecting to the BugLog server:\n" + xmlhttp.statusText);
			}			
		}
	};
	xmlhttp.send(null); 
}
function doGetServerInfo() {
	return serverInfo;
}

function doGetEntry(entryID) {
	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getEntry";
		url += "&entryID="+entryID;
		url += "&token="+serverInfo.token;

	clearInterval(listingRefreshTimer);
	document.getElementById("app_refresh_text").innerHTML = "Loading...";

	xmlhttp = new XMLHttpRequest();
	xmlhttp.open("POST", url, true);
	xmlhttp.onreadystatechange = function() {
		if (xmlhttp.readyState == 4) {
			if (xmlhttp.status == 200) {

				document.getElementById("app_refresh_text").innerHTML = "Refresh";

				// check for errors				
				var errorNode = xmlhttp.responseXML.getElementsByTagName("error");
				if(errorNode[0].firstChild.nodeValue == "true") {
					var errorMsgNode = xmlhttp.responseXML.getElementsByTagName("errorMessage");
					alert(errorMsgNode[0].firstChild.nodeValue);
					return;
				}

				// create an array with the returned entries	
				try {			
					var dataNodes = xmlhttp.responseXML.getElementsByTagName("entry");
					if(dataNodes.length > 0) {
						var entry = {};					
						entry.ApplicationCode = getElementTextNS("", "ApplicationCode", dataNodes[0], 0)
						entry.ApplicationID = getElementTextNS("", "ApplicationID", dataNodes[0], 0)
						entry.HostName = getElementTextNS("", "HostName", dataNodes[0], 0)
						entry.HostID = getElementTextNS("", "HostID", dataNodes[0], 0)
						entry.Message = getElementTextNS("", "Message", dataNodes[0], 0)
						entry.createdOn = getElementTextNS("", "createdOn", dataNodes[0], 0)
						entry.EntryID = getElementTextNS("", "EntryID", dataNodes[0], 0)
						entry.SeverityCode = getElementTextNS("", "SeverityCode", dataNodes[0], 0)
						entry.ExceptionMessage = getElementTextNS("", "ExceptionMessage", dataNodes[0], 0)
						entry.ExceptionDetails = getElementTextNS("", "ExceptionDetails", dataNodes[0], 0)
						entry.BugCFID = getElementTextNS("", "BugCFID", dataNodes[0], 0)
						entry.BugCFTOKEN = getElementTextNS("", "BugCFTOKEN", dataNodes[0], 0)
						entry.UserAgent = getElementTextNS("", "UserAgent", dataNodes[0], 0)
						entry.TemplatePath = getElementTextNS("", "TemplatePath", dataNodes[0], 0)
						
						// call a method on the view to display the entries
						document.getElementById('UI').contentWindow.displayEntry(entry);
					}				

				} catch(e) {
					document.getElementById('UI').contentWindow.displayError(e);
				}
				
	
			} else {
				alert("There was a problem connecting to the BugLog server:\n" + xmlhttp.statusText);
			}			
		}
	};
	xmlhttp.send(null); 

}

function doSetListingRefreshTimer() {
	listingRefreshTimer = setInterval(listingRefreshTimerHandler, 10000)
}

function listingRefreshTimerHandler(event) {
	doGetSummary();
}

function loadServerInfo() {
    serverInfo.username = getCookie("username");
    serverInfo.password = getCookie("password");
//    serverInfo.server = getCookie("server");
    serverInfo.rememberMe = getCookie("rememberMe");
}
function storeServerInfo() {
	setCookie("username",serverInfo.username,30);
	setCookie("password",serverInfo.password,30);
//	setCookie("server",serverInfo.server,30);
	setCookie("rememberMe",serverInfo.rememberMe,30);
}
function clearServerInfo() {
	setCookie("username","");
	setCookie("password","");
//	setCookie("server","");
	setCookie("rememberMe",false);
}

// retrieve text of an XML document element, including
// elements using namespaces
function getElementTextNS(prefix, local, parentElem, index) {
    var result = parentElem.getElementsByTagName(local)[index];

    if (result) {
        // get text, accounting for possible
        // whitespace (carriage return) text nodes 
        if (result.childNodes.length > 1) {
            return result.childNodes[1].nodeValue;
        } 
        if (result.childNodes.length == 1) {
            return result.firstChild.nodeValue;    		
        } else {
            return "";    		
        }
    } else {
        return "n/a";
    }
}

function setCookie(c_name,value,expiredays) {
	var exdate=new Date();
	exdate.setDate(exdate.getDate()+expiredays);
	document.cookie=c_name+ "=" +escape(value)+
	((expiredays==null) ? "" : ";expires="+exdate.toGMTString());
}
function getCookie(c_name) {
	if (document.cookie.length>0)
	  {
	  c_start=document.cookie.indexOf(c_name + "=");
	  if (c_start!=-1)
	    {
	    c_start=c_start + c_name.length+1;
	    c_end=document.cookie.indexOf(";",c_start);
	    if (c_end==-1) c_end=document.cookie.length;
	    return unescape(document.cookie.substring(c_start,c_end));
	    }
	  }
	return "";
}
