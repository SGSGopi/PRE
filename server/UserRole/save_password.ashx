<%@ WebHandler Language="C#" class="save_password" %>

using System;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using PP.Types;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using Newtonsoft.Json.Linq;
using PP.Utility;
using System.Transactions;


public class save_password: IHttpHandler,System.Web.SessionState.IRequiresSessionState
{
	String jsonString = String.Empty;
	JsonSerializerSettings settings = new JsonSerializerSettings();
	
	String 	sOrg	="";
	String	sLocn	="";
	String	sUser	="";
	String	sLang	="";


	StatusObject statusObject = new StatusObject();
	Util util = new Util();
	DirectoryLookup directoryLookup=new DirectoryLookup();
	String dataRequest=String.Empty;
	DataRequest objDataRequest;

	public void logResult (HttpContext context, String sLogString )
	{
		directoryLookup.logResultForSituation(context,"save_password",sLogString);
	}
	
	public void ProcessRequest(HttpContext context)
	{
		context = util.SetContext(context);
		
		bool bTransactionSuccess=true;
		settings.NullValueHandling = NullValueHandling.Ignore;
		
		//DATARETURN - Reading Input Data
		try
        {
            using (StreamReader reader = new StreamReader(context.Request.InputStream))
            {
                dataRequest = reader.ReadToEnd();
                reader.Close();
            }
			
			if ( ! String.IsNullOrEmpty( dataRequest) )
			{	
				objDataRequest=JsonConvert.DeserializeObject<DataRequest>(dataRequest);
				//logResult(context, JsonConvert.SerializeObject(objDataRequest, Formatting.None, settings));
			}		
        }
        catch (Exception e)
        {
            statusObject.update = "failed";
            statusObject.error = e.Message;
            statusObject.errorat = "request";
			statusObject.data = null;
			logResult(context, "save_password Input Stream Parse Error :" + e.Message + e.StackTrace);
        }
		
		try
		{
			if (context.Request.QueryString.Count > 0)
			{
				sOrg 	= (String.IsNullOrEmpty(context.Request.QueryString["org"]))  ? "" : context.Request.QueryString["org"].ToString();
				sLocn	= (String.IsNullOrEmpty(context.Request.QueryString["locn"])) ? "" : context.Request.QueryString["locn"].ToString();
				sUser	= (String.IsNullOrEmpty(context.Request.QueryString["user"])) ? "" : context.Request.QueryString["user"].ToString();
				sLang	= (String.IsNullOrEmpty(context.Request.QueryString["lang"])) ?	"" : context.Request.QueryString["lang"].ToString();	
			}
			//directoryLookup.logActivity(context,"save_password ashx", "Save Password" , context.Request.QueryString.ToString());

			using (TransactionScope ts = new TransactionScope(TransactionScopeOption.RequiresNew))
			{
				String sDSN=context.Session["PPControl"].ToString();
				using (SqlConnection conUsrRole = new SqlConnection(sDSN))
				{	
					conUsrRole.Open();
					var sCommand="change_password";
					using (SqlCommand cmd = new SqlCommand(sCommand , conUsrRole))
					{
						try
						{
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.CommandTimeout = 0;

							//Register Parameters
							cmd.Parameters.Add("@user_id", SqlDbType.VarChar).Value = objDataRequest.context.Header.user_id;
							cmd.Parameters.Add("@user_password", SqlDbType.VarChar).Value = objDataRequest.context.Header.user_password;

							cmd.Parameters.Add("@orgnId", SqlDbType.VarChar).Value = objDataRequest.context.orgnId;
							cmd.Parameters.Add("@locnId", SqlDbType.VarChar).Value = objDataRequest.context.locnId;
							cmd.Parameters.Add("@localeId", SqlDbType.VarChar).Value = objDataRequest.context.localeId;
							cmd.Parameters.Add("@userId", SqlDbType.VarChar).Value = objDataRequest.context.userId;

							int retValue = cmd.ExecuteNonQuery();
						}
						catch (Exception e)
						{
							bTransactionSuccess=false;
							statusObject.update = "failed";
							statusObject.error += e.Message;
							statusObject.errorat += e.StackTrace;
						}
						finally
						{
							if (cmd != null)
								cmd.Dispose();
						}
					}
						
					if  (conUsrRole!= null) {
						if (conUsrRole.State.ToString() == "Open")
						{
							conUsrRole.Close();
						}
						conUsrRole.Dispose();
					}
				}
					
				if (bTransactionSuccess == true){
					ts.Complete();
				}
			}
					
			//DATARETURN - Returning JSON to the Web
			context.Response.ContentType = "application/json";
			jsonString = JsonConvert.SerializeObject(statusObject, Formatting.None, settings);
			context.Response.Write(jsonString);
		}
		catch (Exception e)
		{
			statusObject.update = "failed";
			statusObject.error = e.Message;
			statusObject.errorat = e.StackTrace;
			statusObject.data = null;
			
			context.Response.ContentType = "application/json";
			jsonString = JsonConvert.SerializeObject(statusObject, Formatting.None, settings);
			context.Response.Write(jsonString);
			logResult(context, "save_password Error :" + e.Message);
		}
	}
	
	//DATARETURN -- Class Declaration	 
	public class DataRequest
	{
		public Context context;
	}
	
	public class Context
	{
		public String localeId;
		public String orgnId;
		public String locnId;
		public String userId;
		public Header Header;
	}
	
	public class Header
	{
		public String user_id;
		public String user_password;
	}
	
	public bool IsReusable
	{
		get
		{
			return false;
		}
	}	
}