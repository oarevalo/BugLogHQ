/**
 * This module requires stacktrace-js and angular, it has been tested with:
 *
 * "stacktrace-js": "~0.6.4"
 * "angular": "~1.3.15"
 */

angular.module('BugLogHq', [])
    .constant('bugLogConfig', {
        // This is the location of the BugLog server that will be receiving the error reports
        // example: 'https://domain/buglog/listeners/bugLogListenerREST.cfm'
        listener: '',
        // Tell BugLog which application is submitting this bug
        applicationCode: '',
        // If the BugLog server requires an API Key to talk to it, then here is where you put it.
        apiKey: '',
        // The hostname to tell BugLog from where the report is coming from. Leave empty to get the info from the browser.
        hostName: '',
        // Default bug serverity code
        defaultSeverity: 'ERROR'
    })
    .config(['$provide',
        function ($provide) {
            $provide.decorator('$exceptionHandler', ['$delegate', '$log', 'BugLogService',
                function ($delegate, $log, BugLogService) {
                    return function(exception, cause) {
                        // Custom error handling.
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
    .factory('BugLogService', function BugLogService($window, bugLogConfig) {
        var service = {
            logBug: logBug
        };
        return service;
        /////////////////////

        /**
         * Communicates with a BugLogHq Server
         * @param {string} cause
         * @param {object} error
         * @param {string} [severityCode]
         */
        function logBug(cause, error, severityCode) {
            var data = {};
            data.message = 'Caused by: ' + cause;
            data.exceptionMessage = cause || 'Unknown';
            data.exceptionDetails =  buildStacktrace(error) || 'something went wrong';
            data.severityCode = severityCode || bugLogConfig.defaultSeverity || 'ERROR';
            data.HTMLReport = buildHtmlReport() || 'something went wrong';
            data.userAgent = navigator.userAgent || 'Unknown';
            data.templatePath = document.URL || 'Unknown';
            data.applicationCode = bugLogConfig.applicationCode || 'Unknown';
            data.APIKey = bugLogConfig.apiKey || '';
            data.hostName = bugLogConfig.hostName || '';
            // Make server call; we could use the $http via the $injector service (to avoid circular dependencies)
            // but customer header could be set that upset CORS requests to the bugLog server
            // so a plain old javascript XHR request is used.
            var xhr = new XMLHttpRequest();
            xhr.open('POST', encodeURI(bugLogConfig.listener));
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.send(angular.toJson(data));
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
         * The $rootScope is included because it holds our user session object
         * If your app uses a service instead the $injector service can be used to retrieve it
         * @returns {string}
         */
        function buildHtmlReport() {
            var html = '<h3>Bug Report</h3>';
            var rootScope = getRootScope() || 'something went wrong';
            var scripts = getScripts() || 'something went wrong';
            var stylesheets = getStylesheets() || 'something went wrong';
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
            for (var key in scope) {
                if(key.substring(0, 1) !== '$' && key.substring(0,2) !== '__' && key !== 'constructor') {
                    obj[key] = angular.copy(scope[key]);
                }
            }
            return obj;
        }
    })
;
