/**
 * This module requires stacktrace-js and angular, it has been tested with:
 *
 * "stacktrace-js": "~0.6.4"
 * "angular": "~1.3.15"
 */

angular.module('BugLogHq', [])
    //the application to tell BugLog from where the report is coming from.
    .constant('appName', "app")
    .constant('bugLogConfig', {
        // this is the location of the BugLog server that will be receiving the error reports (needs to be a REST/POST endpoint)
        listener: "",
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
                            BugLogService.logBug(cause, exception);
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
    .factory('BugLogService', function BugLogService($window, $log, appName, bugLogConfig) {
        var config = {
            // this is the location of the BugLog server that will be receiving the error reports (needs to be a REST/POST endpoint)
            listener: bugLogConfig.listener,
            //the application to tell BugLog from where the report is coming from.
            appName: appName,
            // If the BugLog server requires an API Key to talk to it, then here is where you put it.
            apiKey: bugLogConfig.apiKey
        };

        var service = {
            logBug: logBug
        };

        return service;
        /////////////////////

        /**
         * Communicates with a BugLogHq Server
         * @param {string} cause
         * @param {object} error
         * @param {string} severityCode
         */
        function logBug(cause, error, severityCode) {
            var data = {};
            data.message = 'Caused by: ' + cause;
            data.exceptionMessage = cause || 'Unknown';
            data.exceptionDetails =  buildStacktrace(error) || 'something went wrong';
            data.severityCode = severityCode || 'EXCEPTION';
            data.HTMLReport = buildHtmlReport() || 'something went wrong';
            data.userAgent = navigator.userAgent || 'Unknown';
            data.templatePath = document.URL || 'Unknown';
            data.applicationCode = config.appName || 'Unknown';
            data.APIKey = config.apiKey || '';

            // Make server call
            var xhr = new XMLHttpRequest();
            xhr.open('POST', encodeURI(config.listener));
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.send(JSON.stringify(data));

        }

        /**
         * Build Stacktrace
         * @param error
         * @return {*}
         */
        function buildStacktrace(error) {
            var stack;
            if(typeof error.stack !== 'undefined') {
                stack = error.stack;
            }
            if ($window.printStackTrace) {
                stack = $window.printStackTrace({e: error}).join('\n');
            }
            return stack;
        }

        /**
         * Build HTML Report
         * @returns {string}
         */
        function buildHtmlReport() {
            var html = '<h3>Bug Report</h3>';
            var stylesheets = getStylesheets() || 'something went wrong';
            var scripts = getScripts() || 'something went wrong';
            var rootScope = getRootScope() || 'something went wrong';

            // URL
            html += '<h4>RootScope:</h4><pre>' + angular.toJson(rootScope, 2) + '</pre>';
            html += '<h4>Scripts:</h4><pre>' + angular.toJson(scripts, 2) + '</pre>';
            html += '<h4>Stylesheets:</h4><pre>' + angular.toJson(stylesheets, 2) + '</pre>';

            return html;
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
                    var href = links[i].href.split('/');
                    assets.push(href[href.length-1]);
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
                    var src = scripts[j].src.split('/');
                    assets.push(src[src.length-1]);
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
