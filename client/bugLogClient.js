/*		BugLogHQ Javascript Notification Client   ( https://github.com/oarevalo/BugLogHQ )
 * 
 * 	Usage:
 * 		<script type="text/javascript" src="bugLogClient.js"></script>
		<script>
			BugLog.listener = "http://your_buglog_server/bugLog/listeners/bugLogListenerREST.cfm";
			BugLog.appName = "Your_App_Name";

			
		// Method 1: Within your own error handler (full stacktrace)
			try {
				.... code that throws an error ...			
			} catch(e) {
				BugLog.notifyService({
					message: e.message,
					error: e,
					severity: "ERROR"
				});
			}
			
		// Method 2:  Within a global error handler (no stacktrace)
			window.onerror = function(message, file, line) {
			  	BugLog.notifyService({
						  message: message,
						  extraInfo: 'Error occurred in: ' + file + ':' + line,
						  severity:"ERROR"
				  });
				  return true;
			};		
		</script>
 */

var BugLog = {
	// this is the location of the BugLog server that will be receiving the error reports (needs to be a REST/POST endpoint)
	listener: "",

	// the hostname to tell BugLog from where the report is coming from. Leave empty to get the info from the browser.
	hostName: "",

	//the application to tell BugLog from where the report is coming from. 
	appName: "BugLogJSClient",

	// If the BugLog server requires an API Key to talk to it, then here is where you put it.
	apiKey: "",
		
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
		var extra = "";
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
			stacktrace = (typeof msg.error.stack!=="undefined")?msg.error.stack:printStackTrace({e:msg.error}).join("\n");
		}
		if(typeof stacktrace !== "undefined") {
			extra += "<br><br><b>Stacktrace:</b><br><pre>"+stacktrace+"</pre>";
		}

		// build the message in a format that can be passed along
		var data = "message="+escape(msg.message)
							+"&severityCode="+escape(msg.severity)
							+"&hostName="+escape(BugLog.hostName || window.location.host)
							+"&applicationCode="+escape(BugLog.appName)
							+"&apiKey="+escape(BugLog.apiKey)
							+"&userAgent="+escape(navigator.userAgent)
							+"&templatePath="+escape(document.URL)
							+"&htmlReport=" + escape(extra);

		// create the notifier
		var noti = BugLog.createNotifier("script");
		noti.src = BugLog.listener + "?" + data; 

		// destroy the notifier
		BugLog.destroyNotifier(noti);
	},
	
	createNotifier: function(tagName) {
		var notifier = document.createElement(tagName);
		notifier.id = "buglog" + (+new Date);;
		var head = document.getElementsByTagName("body")[0];
		head.appendChild(notifier);
		return notifier;
	},
	
	destroyNotifier: function(notifier) {
		var elm = document.getElementById(notifier.id);
		var head = document.getElementsByTagName("body")[0];
		head.removeChild(elm);
	}

}

//Domain Public by Eric Wendelin http://eriwen.com/ (2008)
//Luke Smith http://lucassmith.name/ (2008)
//Loic Dachary <loic@dachary.org> (2008)
//Johan Euphrosine <proppy@aminche.com> (2008)
//Oyvind Sean Kinsey http://kinsey.no/blog (2010)
//Victor Homyakov <victor-homyakov@users.sourceforge.net> (2010)

/**
* Main function giving a function stack trace with a forced or passed in Error
*
* @cfg {Error} e The error to create a stacktrace from (optional)
* @cfg {Boolean} guess If we should try to resolve the names of anonymous functions
* @return {Array} of Strings with functions, lines, files, and arguments where possible
*/
function printStackTrace(options){options=options||{guess:true};var ex=options.e||null,guess=!!options.guess;var p=new printStackTrace.implementation(),result=p.run(ex);return(guess)?p.guessAnonymousFunctions(result):result}printStackTrace.implementation=function(){};printStackTrace.implementation.prototype={run:function(ex,mode){ex=ex||this.createException();mode=mode||this.mode(ex);if(mode==='other'){return this.other(arguments.callee)}else{return this[mode](ex)}},createException:function(){try{this.undef()}catch(e){return e}},mode:function(e){if(e['arguments']&&e.stack){return'chrome'}else if(e.stack&&e.sourceURL){return'safari'}else if(e.stack&&e.number){return'ie'}else if(typeof e.message==='string'&&typeof window!=='undefined'&&window.opera){if(!e.stacktrace){return'opera9'}if(e.message.indexOf('\n')>-1&&e.message.split('\n').length>e.stacktrace.split('\n').length){return'opera9'}if(!e.stack){return'opera10a'}if(e.stacktrace.indexOf("called from line")<0){return'opera10b'}return'opera11'}else if(e.stack){return'firefox'}return'other'},instrumentFunction:function(context,functionName,callback){context=context||window;var original=context[functionName];context[functionName]=function instrumented(){callback.call(this,printStackTrace().slice(4));return context[functionName]._instrumented.apply(this,arguments)};context[functionName]._instrumented=original},deinstrumentFunction:function(context,functionName){if(context[functionName].constructor===Function&&context[functionName]._instrumented&&context[functionName]._instrumented.constructor===Function){context[functionName]=context[functionName]._instrumented}},chrome:function(e){var stack=(e.stack+'\n').replace(/^\S[^\(]+?[\n$]/gm,'').replace(/^\s+(at eval )?at\s+/gm,'').replace(/^([^\(]+?)([\n$])/gm,'{anonymous}()@$1$2').replace(/^Object.<anonymous>\s*\(([^\)]+)\)/gm,'{anonymous}()@$1').split('\n');stack.pop();return stack},safari:function(e){return e.stack.replace(/\[native code\]\n/m,'').replace(/^(?=\w+Error\:).*$\n/m,'').replace(/^@/gm,'{anonymous}()@').split('\n')},ie:function(e){var lineRE=/^.*at (\w+) \(([^\)]+)\)$/gm;return e.stack.replace(/at Anonymous function /gm,'{anonymous}()@').replace(/^(?=\w+Error\:).*$\n/m,'').replace(lineRE,'$1@$2').split('\n')},firefox:function(e){return e.stack.replace(/(?:\n@:0)?\s+$/m,'').replace(/^[\(@]/gm,'{anonymous}()@').split('\n')},opera11:function(e){var ANON='{anonymous}',lineRE=/^.*line (\d+), column (\d+)(?: in (.+))? in (\S+):$/;var lines=e.stacktrace.split('\n'),result=[];for(var i=0,len=lines.length;i<len;i+=2){var match=lineRE.exec(lines[i]);if(match){var location=match[4]+':'+match[1]+':'+match[2];var fnName=match[3]||"global code";fnName=fnName.replace(/<anonymous function: (\S+)>/,"$1").replace(/<anonymous function>/,ANON);result.push(fnName+'@'+location+' -- '+lines[i+1].replace(/^\s+/,''))}}return result},opera10b:function(e){var lineRE=/^(.*)@(.+):(\d+)$/;var lines=e.stacktrace.split('\n'),result=[];for(var i=0,len=lines.length;i<len;i++){var match=lineRE.exec(lines[i]);if(match){var fnName=match[1]?(match[1]+'()'):"global code";result.push(fnName+'@'+match[2]+':'+match[3])}}return result},opera10a:function(e){var ANON='{anonymous}',lineRE=/Line (\d+).*script (?:in )?(\S+)(?:: In function (\S+))?$/i;var lines=e.stacktrace.split('\n'),result=[];for(var i=0,len=lines.length;i<len;i+=2){var match=lineRE.exec(lines[i]);if(match){var fnName=match[3]||ANON;result.push(fnName+'()@'+match[2]+':'+match[1]+' -- '+lines[i+1].replace(/^\s+/,''))}}return result},opera9:function(e){var ANON='{anonymous}',lineRE=/Line (\d+).*script (?:in )?(\S+)/i;var lines=e.message.split('\n'),result=[];for(var i=2,len=lines.length;i<len;i+=2){var match=lineRE.exec(lines[i]);if(match){result.push(ANON+'()@'+match[2]+':'+match[1]+' -- '+lines[i+1].replace(/^\s+/,''))}}return result},other:function(curr){var ANON='{anonymous}',fnRE=/function\s*([\w\-$]+)?\s*\(/i,stack=[],fn,args,maxStackSize=10;while(curr&&curr['arguments']&&stack.length<maxStackSize){fn=fnRE.test(curr.toString())?RegExp.$1||ANON:ANON;args=Array.prototype.slice.call(curr['arguments']||[]);stack[stack.length]=fn+'('+this.stringifyArguments(args)+')';curr=curr.caller}return stack},stringifyArguments:function(args){var result=[];var slice=Array.prototype.slice;for(var i=0;i<args.length;++i){var arg=args[i];if(arg===undefined){result[i]='undefined'}else if(arg===null){result[i]='null'}else if(arg.constructor){if(arg.constructor===Array){if(arg.length<3){result[i]='['+this.stringifyArguments(arg)+']'}else{result[i]='['+this.stringifyArguments(slice.call(arg,0,1))+'...'+this.stringifyArguments(slice.call(arg,-1))+']'}}else if(arg.constructor===Object){result[i]='#object'}else if(arg.constructor===Function){result[i]='#function'}else if(arg.constructor===String){result[i]='"'+arg+'"'}else if(arg.constructor===Number){result[i]=arg}}}return result.join(',')},sourceCache:{},ajax:function(url){var req=this.createXMLHTTPObject();if(req){try{req.open('GET',url,false);req.send(null);return req.responseText}catch(e){}}return''},createXMLHTTPObject:function(){var xmlhttp,XMLHttpFactories=[function(){return new XMLHttpRequest()},function(){return new ActiveXObject('Msxml2.XMLHTTP')},function(){return new ActiveXObject('Msxml3.XMLHTTP')},function(){return new ActiveXObject('Microsoft.XMLHTTP')}];for(var i=0;i<XMLHttpFactories.length;i++){try{xmlhttp=XMLHttpFactories[i]();this.createXMLHTTPObject=XMLHttpFactories[i];return xmlhttp}catch(e){}}},isSameDomain:function(url){return typeof location!=="undefined"&&url.indexOf(location.hostname)!==-1},getSource:function(url){if(!(url in this.sourceCache)){this.sourceCache[url]=this.ajax(url).split('\n')}return this.sourceCache[url]},guessAnonymousFunctions:function(stack){for(var i=0;i<stack.length;++i){var reStack=/\{anonymous\}\(.*\)@(.*)/,reRef=/^(.*?)(?::(\d+))(?::(\d+))?(?: -- .+)?$/,frame=stack[i],ref=reStack.exec(frame);if(ref){var m=reRef.exec(ref[1]);if(m){var file=m[1],lineno=m[2],charno=m[3]||0;if(file&&this.isSameDomain(file)&&lineno){var functionName=this.guessAnonymousFunction(file,lineno,charno);stack[i]=frame.replace('{anonymous}',functionName)}}}}return stack},guessAnonymousFunction:function(url,lineNo,charNo){var ret;try{ret=this.findFunctionName(this.getSource(url),lineNo)}catch(e){ret='getSource failed with url: '+url+', exception: '+e.toString()}return ret},findFunctionName:function(source,lineNo){var reFunctionDeclaration=/function\s+([^(]*?)\s*\(([^)]*)\)/;var reFunctionExpression=/['"]?([0-9A-Za-z_]+)['"]?\s*[:=]\s*function\b/;var reFunctionEvaluation=/['"]?([0-9A-Za-z_]+)['"]?\s*[:=]\s*(?:eval|new Function)\b/;var code="",line,maxLines=Math.min(lineNo,20),m,commentPos;for(var i=0;i<maxLines;++i){line=source[lineNo-i-1];commentPos=line.indexOf('//');if(commentPos>=0){line=line.substr(0,commentPos)}if(line){code=line+code;m=reFunctionExpression.exec(code);if(m&&m[1]){return m[1]}m=reFunctionDeclaration.exec(code);if(m&&m[1]){return m[1]}m=reFunctionEvaluation.exec(code);if(m&&m[1]){return m[1]}}}return'(?)'}};

