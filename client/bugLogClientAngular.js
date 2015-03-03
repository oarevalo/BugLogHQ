angular.module('BugLogHq', [])
    //the application to tell BugLog from where the report is coming from.
    .constant('appName', "app")
    .constant('bugLogConfig', {
        // this is the location of the BugLog server that will be receiving the error reports (needs to be a REST/POST endpoint)
        listener: "",
        // the hostname to tell BugLog from where the report is coming from. Leave empty to get the info from the browser.
        hostName: "",
        // If the BugLog server requires an API Key to talk to it, then here is where you put it.
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
    .factory('BugLogService', function BugLogService($window, appName, bugLogConfig) {
        var service = {
            // this is the location of the BugLog server that will be receiving the error reports (needs to be a REST/POST endpoint)
            listener: bugLogConfig.listener,

            // the hostname to tell BugLog from where the report is coming from. Leave empty to get the info from the browser.
            hostName: bugLogConfig.hostName,

            //the application to tell BugLog from where the report is coming from.
            appName: appName,

            // If the BugLog server requires an API Key to talk to it, then here is where you put it.
            apiKey: bugLogConfig.apiKey,
            notifyService: notifyService,
            createNotifier: createNotifier,
            destroyNotifier: destroyNotifier,
            getStylesheets: getStylesheets,
            getScripts: getScripts,
            getRootScope: getRootScope,
            cleanScope: cleanScope
        };

        return service;
        /////////////////////
        /**
         * Communicates with a BugLogHq Server
         * @param message
         */
        function notifyService(message) {
            var msg = {};
            var htmlReport = '<h3>Bug Report</h3>';

            // Message Defaults
            if(typeof message === 'string') {
                msg.message = message;
            }
            else {
                msg.message = message.message;
            }
            msg.error = message.error || undefined;
            msg.severity = message.severity || 'ERROR';
            msg.stack = message.stack || undefined;
            msg.errorUrl = message.errorUrl || $window.location.href;
            msg.stylesheets = message.stylesheets || service.getStylesheets();
            msg.scripts = message.scripts || service.getScripts();
            msg.rootScope = message.rootScope || service.getRootScope();

            // URL
            htmlReport += '<h4>Error Url:</h4><pre>' + msg.errorUrl + '</pre>';

            // Stacktrace
            var stacktrace;
            if(typeof msg.stack !== 'undefined') {
                stacktrace = msg.stack;
            }
            else if(typeof msg.error !== 'undefined') {
                stacktrace = (typeof msg.error.stack !== 'undefined') ? msg.error.stack : $window.printStackTrace({e: msg.error}).join('\n');
            }
            if(typeof stacktrace !== 'undefined') {
                htmlReport += '<h4>Stacktrace:</h4><pre>' + stacktrace + '</pre>';
            }

            // Additional Information (if any)
            if($window.JSON) {
                htmlReport += '<h4>Stylesheets:</h4><pre>' + $window.JSON.stringify(msg.stylesheets) + '</pre>';
                htmlReport += '<h4>Scripts:</h4><pre>' + $window.JSON.stringify(msg.scripts) + '</pre>';
                htmlReport += '<h4>RootScope:</h4><pre>' + $window.JSON.stringify(msg.rootScope) + '</pre>';
            }

            // Build the message as URL parameter
            var data = 'message=' + escape(msg.message) +
                '&severityCode=' + escape(msg.severity) +
                '&hostName=' + escape(service.hostName || $window.location.host) +
                '&applicationCode=' + escape(service.appName) +
                '&apiKey=' + escape(service.apiKey) +
                '&userAgent=' + escape(navigator.userAgent) +
                '&templatePath=' + escape(document.URL) +
                '&htmlReport=' + escape(htmlReport);

            // create the notifier
            var noti = service.createNotifier('script');
            noti.src = service.listener + '?' + data;

            // destroy the notifier
            service.destroyNotifier(noti);
        }

        /**
         * Creates an Html element in an Html Document's <head>
         * @param tagName
         * @returns {HTMLElement}
         */
        function createNotifier(tagName) {
            var notifier = document.createElement(tagName);
            notifier.id = 'buglog' + (+ new Date());
            var head = document.getElementsByTagName('head')[0];
            head.appendChild(notifier);
            return notifier;
        }

        /**
         * Destroys an Html element created by createNotifier()
         * @param notifier
         */
        function destroyNotifier(notifier) {
            var elm = document.getElementById(notifier.id);
            var head = document.getElementsByTagName('head')[0];
            head.removeChild(elm);
        }

        /**
         * Gets an Html Document's stylesheets
         * @returns {Array}
         */
        function getStylesheets() {
            var assets = [];
            var links = document.getElementsByTagName('link');
            for(var i = 0; i < links.length; i++) {
                if (links[i].href && links[i].rel && links[i].rel.toLowerCase() === 'stylesheet') {
                    assets.push(links[i].href);
                }
            }
            return assets;
        }

        /**
         * Gets an Html Document's scripts
         * @returns {Array}
         */
        function getScripts() {
            var assets = [];
            var scripts = document.getElementsByTagName('script');
            for(var j = 0; j < scripts.length; j++) {
                if (scripts[j].src) {
                    assets.push(scripts[j].src);
                }
            }
            return assets;
        }

        /**
         * Finds an AngularJs rootScope and returns its properties
         * @returns {{}}
         */
        function getRootScope() {
            var body = angular.element(document.body);
            var rootScope = body.scope().$root || undefined;
            return cleanScope(rootScope);
        }

        /**
         * Returns an object with copied properties from an AngularJs scope
         * @param scope
         * @returns {{}}
         */
        function cleanScope(scope) {
            var obj = {};
            for( var key in scope) {
                if(key.substring(0, 1) !== '$' && key.substring(0,2) !== '__' && key !== 'constructor') {
                    obj[key] = angular.copy(scope[key]);
                }
            }
            return obj;
        }
    })
;
