<%@ WebHandler Language="C#" class="SaveAnnualData" %>

using System;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using Types;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using Newtonsoft.Json.Linq;
using Utility;
using System.Transactions;


public class SaveAnnualData: IHttpHandler,System.Web.SessionState.IRequiresSessionState
{
	String jsonString = String.Empty;
	JsonSerializerSettings settings = new JsonSerializerSettings();
	
	String 	sOrg	="";
	String	sUser	="";


	StatusObject statusObject = new StatusObject();
	Util util = new Util();
	DirectoryLookup directoryLookup=new DirectoryLookup();
	String dataRequest=String.Empty;
	DataRequest objDataRequest;

	public void logResult (HttpContext context, String sLogString )
	{
		directoryLookup.logResultForSituation(context,"SaveAnnualData",sLogString);
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
				logResult(context, JsonConvert.SerializeObject(objDataRequest, Formatting.None, settings));
			}		
        }
        catch (Exception e)
        {
            statusObject.update = "failed";
            statusObject.error = e.Message;
            statusObject.errorat = "request";
			statusObject.data = null;
			logResult(context, "SaveAnnualData Input Stream Parse Error :" + e.Message + e.StackTrace);
        }
		
		try
		{
			if (context.Request.QueryString.Count > 0)
			{
				sOrg 	= (String.IsNullOrEmpty(context.Request.QueryString["org"]))  ? "" : context.Request.QueryString["org"].ToString();
				sUser	= (String.IsNullOrEmpty(context.Request.QueryString["user"])) ? "" : context.Request.QueryString["user"].ToString();							
			}
			//directoryLookup.logActivity(context,"SaveAnnualData ashx", "SaveAnnualData" , context.Request.QueryString.ToString());

			using (TransactionScope ts = new TransactionScope(TransactionScopeOption.RequiresNew))
			{
				String sDSN=context.Session["DBControl"].ToString();
				using (SqlConnection con = new SqlConnection(sDSN))
				{	
					con.Open();
					var sCommand="pr_SaveAnnualData";
					using (SqlCommand cmd = new SqlCommand(sCommand , con))
					{
						try
						{
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.CommandTimeout = 0;

							//Register Parameters
							cmd.Parameters.Add("@orgId", SqlDbType.VarChar).Value = objDataRequest.context.org;
							cmd.Parameters.Add("@userId", SqlDbType.VarChar).Value = objDataRequest.context.user;
							cmd.Parameters.Add("@year", SqlDbType.VarChar).Value = objDataRequest.context.Header.year;
							cmd.Parameters.Add("@datatemplate", SqlDbType.VarChar).Value = objDataRequest.context.Header.datatemplate;							
							cmd.Parameters.Add("@data", SqlDbType.VarChar).Value = objDataRequest.context.Header.data;
							cmd.Parameters.Add("@type", SqlDbType.VarChar).Value = objDataRequest.context.Header.type;					

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
						
					if  (con!= null) {
						if (con.State.ToString() == "Open")
						{
							con.Close();
						}
						con.Dispose();
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
			logResult(context, "SaveAnnualData Error :" + e.Message);
		}
	}
	
	//DATARETURN -- Class Declaration	 
	public class DataRequest
	{
		public Context context;
	}
	
	public class Context
	{
		public String org;
		public String user;		
		public Header Header;
	}
	
	public class Header
	{
		public String year;
		public String datatemplate;
		public String data;
		public String type;
	}
		
	
	public bool IsReusable
	{
		get
		{
			return false;
		}
	}	
}