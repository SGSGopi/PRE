<%@ Application Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Utility" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>


<Script language="C#" runat="server">

protected void Session_Start(Object sender, EventArgs e)
{

	HttpContext.Current.Session["DBControl"]="Server=INFI-LLP\\SQLEXP2022;Initial Catalog=PRE;Persist Security Info=False;User ID=sa;Password=Sql@2023;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;";

	HttpContext.Current.Session["debugflag"]="1";
}

</script>