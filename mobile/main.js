var bugLogEndpoint = "proxy.cfm";

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
var mainViewCallback = 0;

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
		doConnect(serverInfo.username,serverInfo.password,serverInfo.rememberMe);
	else {
		// display connect page
		setView("connect");
	}
}

function setView(vw) {
	clearInterval(listingRefreshTimer);
	var loc = "views/" + vw + ".html";
	if(vw=="main")
		callback=initMainView;
	else if(vw=="connect")
		callback=initConnectView;
	else if(vw=="config")
		callback=initConfigView;
	jQuery("#UI").load(loc, callback);
} 

function doRefresh() {
	if(serverInfo.token!="") 
		setView("main");
	else
		setView("connect");
}

function doLogOff() {
	serverInfo.token = "";
	setView("connect");
}

function doConfig() {
	if(serverInfo.token!="") 
		setView("config");
	else
		setView("connect");
}

function doConnect(usr,pwd,rem) {
	if(usr==null || usr=='') {alert("Username cannot be empty"); return;}
	if(pwd==null || pwd=='') {alert("Password cannot be empty"); return;}
	
	var url = bugLogEndpoint;
		url += "?action=checkLogin";
		url += "&username="+usr;
		url += "&password="+pwd;

	displayLoading();

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
	var qs = "numDays="+serverInfo.numDays;
		qs += "&applicationID="+serverInfo.applicationID;
		qs += "&hostID="+serverInfo.hostID;
		qs += "&severities="+serverInfo.severities;
	displayLoading();
	doGetData("getSummary", qs, mainViewCallback);
}

function doGetListing(entryID, callback) {
	var qs = "msgFromEntryID="+entryID;
		qs += "&applicationID="+serverInfo.applicationID;
		qs += "&hostID="+serverInfo.hostID;
		qs += "&numDays="+serverInfo.numDays;
	displayLoading();
	doGetData("getListing", qs, callback);
}

function doGetEntry(entryID, callback) {
	var qs = "entryID="+entryID;
	displayLoading();
	doGetData("getEntry", qs, callback);
}

function doGetApplications(callback) {
	doGetData("getApplications", "", callback);
}

function doGetHosts(callback) {
	doGetData("getHosts", "", callback);
}

function doGetSeverities(callback) {
	doGetData("getSeverities", "", callback);
}




function doGetData(action,qs,func) {
	var url = bugLogEndpoint;
		url += "?action="+action;
		url += "&" + qs;
		url += "&token="+serverInfo.token;
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
					if(children[j].nodeType==1) {
						if(children[j].childNodes.length)
							item[children[j].nodeName] = children[j].childNodes[0].nodeValue
						else
							item[children[j].nodeName] = "";
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
	doClearListingRefreshTimer();
	listingRefreshTimer = setInterval(listingRefreshTimerHandler, 10000)
	console.log("Timer SET:"+listingRefreshTimer);
}

function doClearListingRefreshTimer() {
	if(listingRefreshTimer) {
		clearInterval(listingRefreshTimer);
		console.log("Timer CLEAR:"+listingRefreshTimer);
	}
}
function listingRefreshTimerHandler(event) {
	doGetSummary();
}



function doGetServerInfo() {
	return serverInfo;
}

function loadServerInfo() {
    serverInfo.username = getCookie("username","");
    serverInfo.password = getCookie("password","");
    serverInfo.rememberMe = getCookie("rememberMe",false);
    serverInfo.numDays = getCookie("numDays",1);
    serverInfo.applicationID = getCookie("applicationID","");
    serverInfo.hostID = getCookie("hostID","");
    serverInfo.severities = getCookie("severities","");
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
	setCookie("numDays","1");
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
function getCookie(c_name,defaultValue) {
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
	return defaultValue;
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
function displayLoading() {
	var tmpHTML = "<div style='text-align:center;margin-top:100px;'>";
		tmpHTML += "<img src='../images/ajax-loader.gif'><br />";
		tmpHTML += "Loading Data...";
		tmpHTML += "</div>";
	$("#UI").contents().find("#contentArea").html(tmpHTML)
}
function displayError(e) {
	$("#UI").contents().find("#contentArea").html("<div class='entryError'>An error ocurred while retrieving the bugLog data from the server:<br><br>" + e + "</div>");
}
		
		