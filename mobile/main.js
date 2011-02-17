var bugLogDefaultPath = ""
var bugLogMiniPath = "/bugLog/mobile/"
var bugLogHQPath = "/bugLog/hq/"
var bugLogProxyPath = "/bugLog/bugLogProxy.cfm"
var bugLogProtocol = "http"

var serverInfo = {
	username: "",
	password: "",
	server: "",
	token: "",
	rememberMe: false,
	numDays: 1,
	applicationID: 0,
	hostID: 0,
	severities: ""
};

var listingRefreshTimer = 0;

function initApp() {
	// attach actions
	$("#app_main").click(doRefresh);
	$("#app_logoff").click(doLogOff);
	$("#app_logoff_text").click(doLogOff);
	$("#app_config").click(doConfig);
	$("#app_config_text").click(doConfig);

	// load any stored login credentials
	loadServerInfo();

	if(serverInfo.rememberMe)
		doConnect(serverInfo.server,serverInfo.username,serverInfo.password,serverInfo.rememberMe);
	else {
		// display connect page
		setView("connect");
	}
}

function setView(vw) {
	document.getElementById('UI').contentWindow.location = bugLogMiniPath + "views/" + vw + ".html";
} 

function doRefresh() {
	if(serverInfo.token!="") 
		setView("main");
	else
		setView("connect");
}

function doLogOff() {
	serverInfo.token = "";
	clearInterval(listingRefreshTimer);
	setView("connect");
}

function doConfig() {
	if(serverInfo.token!="") {
		clearInterval(listingRefreshTimer);
		setView("config");
	}
	else
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

	$.ajax({
		url:url,
		success: function(data) {
			if(checkForErrors(data)) {
				setView("connect");
				return;
			}
			
			// get authentication token
			resultsNode = data.getElementsByTagName("results");
			
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
		}
	});
}

function doGetSummary() {
	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getSummary";
		url += "&numDays="+serverInfo.numDays;
		url += "&applicationID="+serverInfo.applicationID;
		url += "&hostID="+serverInfo.hostID;
		url += "&severities="+serverInfo.severities;
		url += "&token="+serverInfo.token;
	doGetData(url, document.getElementById('UI').contentWindow.displaySummary);
}

function doGetListing(appID,entryID) {
	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getListing";
		url += "&msgFromEntryID="+entryID;
		url += "&token="+serverInfo.token;
		url += "&numDays="+serverInfo.numDays;
	doGetData(url, document.getElementById('UI').contentWindow.displayListing);
}

function doGetEntry(entryID) {
	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getEntry";
		url += "&entryID="+entryID;
		url += "&token="+serverInfo.token;
	doGetData(url, document.getElementById('UI').contentWindow.displayEntry);
}

function doPopulateApplications(entryID) {
	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getApplications";
		url += "&token="+serverInfo.token;
	doGetData(url, document.getElementById('UI').contentWindow.doPopulateApplications);
}

function doPopulateHosts(entryID) {
	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getHosts";
		url += "&token="+serverInfo.token;
	doGetData(url, document.getElementById('UI').contentWindow.doPopulateHosts);
}

function doPopulateSeverities(entryID) {
	var url = bugLogProtocol + "://" + serverInfo.server + bugLogProxyPath;
		url += "?action=getSeverities";
		url += "&token="+serverInfo.token;
	doGetData(url, document.getElementById('UI').contentWindow.doPopulateSeverities);
}




function doGetData(url,func) {
	clearInterval(listingRefreshTimer);
	$("#app_loading_text").html("Loading...");
	$.ajax({
		type:"GET",
		dataType:"xml",
		url:url,
		complete: function() {
			$("#app_loading_text").html("");
		},
		success: function(data) {
			if(checkForErrors(data)) return;
			var nodes = data.getElementsByTagName("item");
			var aItems = new Array();
			for(var i=0; i < nodes.length;i++) {
				var children = nodes[i].childNodes;
				var item = {};	
				for (var j=0;j<children.length;j++)	{
					if(children[j].nodeType==1 && children[j].childNodes.length) {
						item[children[j].nodeName] = children[j].childNodes[0].nodeValue
					}
				}
				aItems[i] = item;
			}
			func(aItems);
		}
	});
}

function doSaveSettings(numDays, applicationID, hostID, severities) {
    serverInfo.numDays = numDays;
    serverInfo.applicationID = applicationID;
    serverInfo.hostID = hostID;
    serverInfo.severities = severities;
    storeServerInfo();
    doRefresh();
}
function doSetListingRefreshTimer() {
	listingRefreshTimer = setInterval(listingRefreshTimerHandler, 10000)
}

function listingRefreshTimerHandler(event) {
	doGetSummary();
}



function doGetServerInfo() {
	return serverInfo;
}

function loadServerInfo() {
    serverInfo.username = getCookie("username");
    serverInfo.password = getCookie("password");
    serverInfo.rememberMe = getCookie("rememberMe");
    serverInfo.numDays = getCookie("numDays");
    serverInfo.applicationID = getCookie("applicationID");
    serverInfo.hostID = getCookie("hostID");
    serverInfo.severities = getCookie("severities");
}

function storeServerInfo() {
	setCookie("username",serverInfo.username,30);
	setCookie("password",serverInfo.password,30);
	setCookie("rememberMe",serverInfo.rememberMe,30);
	setCookie("numDays",serverInfo.numDays,30);
	setCookie("applicationID",serverInfo.applicationID,30);
	setCookie("hostID",serverInfo.hostID,30);
	setCookie("severities",serverInfo.severities,30);
}

function clearServerInfo() {
	setCookie("username","");
	setCookie("password","");
	setCookie("rememberMe",false);
	setCookie("numDays","");
	setCookie("applicationID","");
	setCookie("hostID","");
	setCookie("severities","");
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

function checkForErrors(data) {
	// check for errors				
	var errorNode = data.getElementsByTagName("error");
	if(errorNode[0].firstChild.nodeValue == "true") {
		var errorMsgNode = data.getElementsByTagName("errorMessage");
		alert(errorMsgNode[0].firstChild.nodeValue);
		return true;
	}
	return false;
}
