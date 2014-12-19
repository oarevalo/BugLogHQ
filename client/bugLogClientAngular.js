angular.module('BugLogHq', [])
.constant('appName', "app")
.constant('bugLogConfig', {
    listener: "",
    hostName: "",
    apiKey: ""
})
.config(['$provide',
    function ($provide) {
        $provide.decorator('$exceptionHandler', ['$delegate', '$log', 'BugLogService',
            function ($delegate, $log, BugLogService) {
                return function(exception, cause) {
                    //Custom error handling.
                    try {
                        BugLogService.notifyService({
                            message: cause,
                            error: exception
                        });
                    }
                    catch (e) {
                        $log.warn("BugLog Service: Error logging bug");
                        $log.warn(e);
                    }
                    // Calls the original $exceptionHandler.
                    $delegate(exception, cause);
                };
            }
        ]);
    }
])
.factory('BugLogService', ["$window", "$document", "appName", "bugLogConfig",
    function BugLogService($window, $document, appName, bugLogConfig) {
        var BugLog = {
            // this is the location of the BugLog server that will be receiving the error reports (needs to be a REST/POST endpoint)
            listener: bugLogConfig.listener,

            // the hostname to tell BugLog from where the report is coming from. Leave empty to get the info from the browser.
            hostName: bugLogConfig.hostName,

            //the application to tell BugLog from where the report is coming from.
            appName: appName,

            // If the BugLog server requires an API Key to talk to it, then here is where you put it.
            apiKey: bugLogConfig.apiKey,

            notifyService: function(message) {
                var msg = {};			// set defaults
                if(typeof message == "string")
                    msg.message = message;
                msg.message = message.message;
                msg.extraInfo = message.extraInfo || "";
                msg.severity = message.severity || "ERROR";
                msg.error = message.error || undefined;
                msg.stack = message.stack || undefined;

                // get additional information (if any)
                // get assets here for file version reference
                var extra = {
                    assets: BugLog.getAssets(),
                    errorUrl: $window.location.href
                };
                if(msg.extraInfo) {
                    extra += "<br><br><b>Extra Info:</b><br>";
                    if(typeof msg.extraInfo=="string") {
                        extra += msg.extraInfo;
                    } else {
                        if(window.JSON) {
                            extra += JSON.stringify(msg.extraInfo);
                        }
                    }
                }

                // see if we can get a stacktrace
                var stacktrace = undefined;
                if(typeof msg.stack !== "undefined") {
                    stacktrace = msg.stack;
                } else if(typeof msg.error !== "undefined") {
                    stacktrace = (typeof msg.error.stack!=="undefined") ? msg.error.stack : $window.printStackTrace({e:msg.error}).join("\n");
                }
                if(typeof stacktrace !== "undefined") {
                    extra += "<br><br><b>Stacktrace:</b><br><pre>"+stacktrace+"</pre>";
                }
                

                // build the message in a format that can be passed along
                var data = "message="+escape(msg.message)
                    +"&severityCode="+escape(msg.severity)
                    +"&hostName="+escape(BugLog.hostName || $window.location.host)
                    +"&applicationCode="+escape(BugLog.appName)
                    +"&apiKey="+escape(BugLog.apiKey)
                    +"&userAgent="+escape(navigator.userAgent)
                    +"&templatePath="+escape($document.URL)
                    +"&htmlReport=" + escape(extra);
                
                // create the notifier
                var noti = BugLog.createNotifier("script");
                noti.src = BugLog.listener + "?" + data;

                // destroy the notifier
                BugLog.destroyNotifier(noti);
            },

            createNotifier: function(tagName) {
                var notifier = document.createElement(tagName);
                notifier.id = "buglog" + (+ new Date);
                var head = document.getElementsByTagName("head")[0];
                head.appendChild(notifier);
                return notifier;
            },

            destroyNotifier: function(notifier) {
                var elm = document.getElementById(notifier.id);
                var head = document.getElementsByTagName("head")[0];
                head.removeChild(elm);
            },

            getAssets: function () {
                var assets = [];
                var links = document.getElementsByTagName("link");
                for(var i = 0; i < links.length; i++) {
                    if (links[i].href) {
                        assets.push(links[i].href);
                    }
                }

                var scripts = document.getElementsByTagName("script");
                for(var j = 0; j < scripts.length; j++) {
                    if (scripts[j].src) {
                        assets.push(scripts[j].src);
                    }
                }
                return assets;
            }
        };

        return BugLog;
    }
]);
