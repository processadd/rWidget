<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="rWidgetPage.aspx.cs" Inherits="RWidget.rWidgetPage" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.0/jquery.min.js"></script>
    <script type="text/javascript">
        function loadWidget(ifmId, widget) {
            var ifm = document.getElementById(ifmId);
            ifm.contentDocument.open();
            ifm.contentDocument.write(widget);
            ifm.contentDocument.close();
        }

        function showWidget() {
            $.ajax({
                url: 'rWidgetPage.aspx/ShowWidgets',
                type: "POST",
                contentType: "application/json",
                dataType: "json",
                success: function (result) {
                    //console.dir(result.d);
                    loadWidget('ifmTbl', result.d[0]);
                    loadWidget('ifmTS', result.d[1]);
                },
                error: function(m) {
                    alert(m.responseText);
                }
            });
        }
    </script>
</head>
<body>
    <div>
        <input id="rWidget" type="button" value="Show rWidgets" onclick="showWidget();" />
    </div>
    <br />
    <iframe id="ifmTbl" style=" width:1000px;height:600px;border:0"></iframe>
    <iframe id="ifmTS" style="width:1000px;height:600px;border:0"></iframe>
</body>
</html>



