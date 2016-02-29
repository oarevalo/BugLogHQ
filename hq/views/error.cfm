<cfheader statuscode="500" statustext="Server error" />
<!DOCTYPE html>
<cfoutput>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
            <title>BugLogHQ Error!</title>
            <link rel="stylesheet" href="includes/bootstrap/css/bootstrap.min.css" type="text/css" />
            <link rel="stylesheet" href="includes/bootstrap/css/bootstrap-responsive.min.css" type="text/css" />
            <link rel="stylesheet" href="includes/style.css" type="text/css">
        </head>
        <body>
            <div id="header">
                <div class="clearfix">
                    <div id="header-left">
                        <a href="/"><img src="images/bug.png" align="absmiddle" width="32" height="32"></a>
                        <a href="/" style=""><h1>BugLog<span>HQ</span></h1></a>
                    </div>
                    <div id="header-right">
                        #lsDateFormat(now())#
                    </div>
                </div>
            </div>
            <div id="mainBody">
                <div id="content">
                    <br />
                    <h2>Error!</h2>
                    <br />
                    <p>#htmlEditFormat(cfcatch.message)#</p>
                    <br />
                    <a href="##" onclick="history.go(-1)">Go Back</a>
                </div>
            </div>
        </body>
    </html>
</cfoutput>
