<?php
/* BugLogClient PHP Wrapper
*/

class BugLogClient {
	
	protected $bugLogEndpoint;
	protected $hostName;
	protected $applicationCode;
	
	/* *** Constructor ** */
	
	public function __construct($endpoint, $hostName, $appCode)	{
		$this->bugLogEndpoint = $endpoint;
		$this->hostName = $hostName;
		$this->applicationCode = $appCode;
	}
	
	/* *** Public Methods ** */
	
	public function notifyException($exception, $severity = "ERROR", $info = "") {
		$this->notifyService($exception->getMessage(), $severity, $info);
	}
	
	public function notifyService($msg, $severity = "ERROR", $info = "") {

		# generate the html report
		$backtrace = debug_backtrace();
		$backtrace_str = ""; $i = 1;
		foreach($backtrace as $item) {
			if(isset($item['file']) && isset($item['line'])) {
				$backtrace_str .= "[" . $i . "] " . $item['file'] .' (line '.$item['line'] . ')<br/>'; 
				$i++;
			}
		}
		
		$server_str = "<table>"; 
		foreach($_SERVER as $key=>$value) { $server_str .= "<tr><td><b>" . $key . ':</b></td><td>' . $value.'</td></tr>'; }
		$server_str .= "</table>";
		
		$report = "<b>Backtrace:</b><pre>" . $backtrace_str . "</pre><br />"
					. "<b>Server Environment:</b><pre>" . $server_str . "</pre><br />"
					. "<b>Extra Info:</b><pre>" . print_r($info, True) . "</pre>";
		
		$fields = array(
						'message'=>urlencode($msg),
						'severityCode'=>urlencode($severity),
						'applicationCode'=>urlencode($this->applicationCode),
						'hostName'=>urlencode($this->hostName),
						'userAgent'=>urlencode($_SERVER['HTTP_USER_AGENT']),
						'exceptionMessage'=>urlencode($msg),
						'HTMLReport'=>urlencode($report)
					);

		//url-ify the data for the POST
		$fields_string = "";
		foreach($fields as $key=>$value) { $fields_string .= $key.'='.$value.'&'; }
		rtrim($fields_string,'&');

		//open connection	
		$ch = curl_init();

		curl_setopt($ch, CURLOPT_URL, $this->bugLogEndpoint); # URL to post to
		curl_setopt($ch, CURLOPT_POST,count($fields));
		curl_setopt($ch, CURLOPT_POSTFIELDS,$fields_string);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1 );
		
		$result = curl_exec( $ch ); 

		//close connection
		curl_close($ch);
		
		return $result;
	}
	
}