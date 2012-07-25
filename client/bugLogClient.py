"""BugLogClient.py

This is a simple client class to facilitate sending bug
reports and other messages to a bugLog server

"""

import httplib, urllib
import traceback
import sys
from socket import gethostname
from os import environ
import logging
from urlparse import urlparse

class BugLogClient:
    
    INFO = "INFO"
    ERROR = "ERROR"
    FATAL = "FATAL"
    
    def __init__(self, listener, appName):
        # parse the listener URL into subcomponents
        parts = urlparse(listener)
        self.listener = listener
        self.listenerHost = parts[1]
        self.listenerPath = parts[2]
        self.listenerSecure = (parts[0] == "https")
        self.appName = appName
        try:
            self.hostName = gethostname()
        except:
            self.hostName = "unknown"
        logging.info("BugLogClient initialized. I will be talking to the buglog listener at:" + self.listenerHost)
        
    def notifyMessage(self, msg, severity = INFO, extra = None):
        stack = traceback.format_stack()
        htmlReport = self._stackToHTML(stack)
        if extra:
            htmlReport += extra
        self._notify(msg,severity,htmlReport)

    def notifyException(self, severity = ERROR, extra = None):
        exc_type, exc_value, exc_tb = sys.exc_info()
        try:
            msg = str(exc_type) + ": " + str(exc_value)
        except:
            msg = "error"
        stack = traceback.format_exception(exc_type, exc_value, exc_tb)
        htmlReport = self._stackToHTML(stack)
        if extra:
            htmlReport += extra
        self._notify(msg,severity,htmlReport)
        
        
    def _notify(self,msg,severity,htmlReport):
        userAgent = environ.get("HTTP_USER_AGENT", "")
        
        headers = {"Content-type": "application/x-www-form-urlencoded",
                            "Accept": "text/plain"}
        
        params = urllib.urlencode({
                                   "message" : msg,
                                   "severityCode" : severity,
                                   "applicationCode" : self.appName,
                                   "hostName" : self.hostName,
                                   "userAgent" : userAgent,
                                   "exceptionMessage" : msg,
                                   "HTMLReport" : htmlReport
                                })
    
        endPoint = self.listenerHost
    
        if self.listenerSecure:
            conn = httplib.HTTPSConnection(endPoint)
        else:
            conn = httplib.HTTPConnection(endPoint)
        conn.request("POST", self.listenerPath, params, headers)
        response = conn.getresponse()
        logging.info("BugLog Response: " + str(response.status) + " " + str(response.reason))
        conn.close()
    
    def _stackToHTML(self, stack):
        html = ""
        for x in stack:
            html += x + "<br />"
        return html
    
    def _appendCGIStack(self, content):
        html = ("<h1>Traceback</h1>"
                    + cgitb.html(i18n=self.translator)
                    + ("<h1>Environment Variables</h1><table>%s</table>"
                       % cgitb.niceDict("", self.env)))

        