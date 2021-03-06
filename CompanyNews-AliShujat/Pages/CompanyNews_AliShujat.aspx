﻿<%@ Page language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<WebPartPages:AllowFraming ID="AllowFraming" runat="server" />

<html>
<head>
    <title>CompanyNews-Ali</title>

    <script src="../Scripts/jquery-3.3.1.min.js"></script>
    <script src="../Scripts/moment.min.js"></script>
    <script src="../Scripts/bootstrap.min.js"></script>
    <script type="text/javascript">

        var hostweburl;
        var appweburl;

        // Load the required SharePoint libraries
        $(document).ready(function () {
            //Get the URI decoded URLs.
            hostweburl = decodeURIComponent(getQueryStringParameter("SPHostUrl"));
            appweburl = decodeURIComponent(getQueryStringParameter("SPAppWebUrl"));

            // resources are in URLs in the form: web_url/_layouts/15/resource
            var scriptbase = hostweburl + "/_layouts/15/";

            // Load the js files and continue to the successHandler
            $.getScript(scriptbase + "SP.RequestExecutor.js", execCrossDomainRequest);
        });

        // Function to prepare and issue the request to get SharePoint data
        function execCrossDomainRequest() {

            // executor: The RequestExecutor object Initialize the RequestExecutor with the app web URL.
            var executor = new SP.RequestExecutor(appweburl);

            // Deals with the issue the call against the app web.
            executor.executeAsync({
                url: appweburl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('CompanyNewsList')/items?@target='" + hostweburl + "/CompanyNewsSite'&$filter=Show%20eq%20'Yes'&$top=5",
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: successHandler,
                error: errorHandler
            }
            );
        }

        // Function to handle the success event. Prints the data to the page.
        function successHandler(data) {
            var jsonObject = JSON.parse(data.body);
            var items = [];
            var results = jsonObject.d.results;
            items.push("<ul class='list-group'>");

            $(results).each(function () {
                
                var d = moment(this.Created).format('YYYY-MM-DD'); // chage date format
                
                items.push('<li class="list-group-item list-group-item-info"> ' + '<img src="../Images/News.png"  height="35" width="35"/> ' + this.Category + " <b />"+
                    
                    "<div><a href=\"" + hostweburl + "/CompanyNewsSite/Lists/CompanyNewsList/DispForm.aspx?ID=" + this.ID + "\"target=\"_blank\">" + this.Title + "</a></div><b/>"+d + '</li>');
               
            });

            items.push("</ul");
            $("#listResult").html(items.join(''))

        }


        // Function to handle the error event. Prints the error message to the page.
        function errorHandler(data, errorCode, errorMessage) {
            document.getElementById("internal").innerText = "Could not complete cross-domain call: " + errorMessage;
        }

        // Function to retrieve a query string value.
        function getQueryStringParameter(paramToRetrieve) {
            var params = document.URL.split("?")[1].split("&");
            var strParams = "";
            for (var i = 0; i < params.length; i = i + 1) {
                var singleParam = params[i].split("=");
                if (singleParam[0] == paramToRetrieve)
                    return singleParam[1];
            }
        }


    </script>
    <link href="../Content/bootstrap.min.css" rel="stylesheet" />

</head>
<body>

    <div><strong>Latest news</strong></div>
    <div id="listResult"></div>

</body>
</html>