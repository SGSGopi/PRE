<%@ WebHandler Language="C#" class="GetAnnualData" %>

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


public class GetAnnualData: IHttpHandler,System.Web.SessionState.IRequiresSessionState
{
	StatusObject statusObject = new StatusObject();
	
	String jsonString = String.Empty;
	JsonSerializerSettings settings = new JsonSerializerSettings();
	
	String 	sOrg	="";
	String	sUser	="";
	String	sYear	="";
	string  sType   = "";
	string sResult  = "";
	
	
	
	//DATARETURN - Declaration
	Result result = new Result();
	Util util = new Util();
	DirectoryLookup directoryLookup=new DirectoryLookup();

	public void logResult (HttpContext context, String sLogString )
	{
		directoryLookup.logResultForSituation(context,"pr_GetAnnualData",sLogString);
	}
	
	public void ProcessRequest(HttpContext context)
	{
		context = util.SetContext(context);
		//directoryLookup.logServiceCall(context, this.GetType().Name, context.Request.QueryString.ToString());
		
		result.context= new Context();
		result.context.Detail = new List<object>();
		
		settings.NullValueHandling = NullValueHandling.Ignore;
		try
		{
			if (context.Request.QueryString.Count > 0)
			{
				sOrg 	= (String.IsNullOrEmpty(context.Request.QueryString["org"]))  ? "" : context.Request.QueryString["org"].ToString();
				sUser	= (String.IsNullOrEmpty(context.Request.QueryString["user"])) ? "" : context.Request.QueryString["user"].ToString();
				sYear	= (String.IsNullOrEmpty(context.Request.QueryString["year"])) ?	"" : context.Request.QueryString["year"].ToString();	
				sType	= (String.IsNullOrEmpty(context.Request.QueryString["type"])) ?	"" : context.Request.QueryString["type"].ToString();	
			}
			//directoryLookup.logActivity(context,"GetAnnualData ashx", "GetAnnualData" , context.Request.QueryString.ToString());

			try
				{
					String sDSN=context.Session["DBControl"].ToString();
					using (SqlConnection conPush = new SqlConnection(sDSN))
					{	
						conPush.Open();
						var sCommand="pr_GetAnnualData";
						using (SqlCommand cmd = new SqlCommand(sCommand , conPush))
						{
							try
							{
								cmd.CommandType = CommandType.StoredProcedure;
								cmd.CommandTimeout = 0;

								//Register Parameters
								cmd.Parameters.Add("@orgId", SqlDbType.VarChar).Value = sOrg;								
								cmd.Parameters.Add("@userId", SqlDbType.VarChar).Value = sUser;
								cmd.Parameters.Add("@year", SqlDbType.VarChar).Value = sYear;								
								cmd.Parameters.Add("@type", SqlDbType.VarChar).Value = sType;

								using ( SqlDataReader reader = cmd.ExecuteReader())
								{
									while (reader.Read())
									{
										if(sType == "Years"){
											sResult = reader["Year"].ToString().Trim();
										}else if(sType == "Template"){
											sResult = reader["DataTemplate"].ToString().Trim();
										}else if(sType == "Data"){
											sResult = reader["Data"].ToString().Trim();
										}										

										BuildDetail ( sResult);
									}
									
									// reader must be closed before reading the output parameter
									if (reader != null) reader.Close();
									
								}
							}
							catch (Exception e)
							{
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
						
						if  (conPush!= null) {
							if (conPush.State.ToString() == "Open")
							{
								conPush.Close();
							}
							conPush.Dispose();
						}
					}
				}
			catch (Exception e)
			{
				statusObject.update = "failed";
				statusObject.error = "Message Posting Failed : "+e.Message;
				statusObject.errorat = e.StackTrace;
				logResult(context, "GetAnnualData Exception :" + e.Message);
			}
			finally
			{
			}	

				
			//DATARETURN - Final Building Of Result Set
			BuildContext();
			statusObject.data = result;
					
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
			logResult(context, "GetAnnualData Error :" + e.Message);
		}
	}
	
		 
	//DATARETURN -- Class Declaration	 
	public class Result
	{
		public Context context;
		public String ApplicationException;
	}
	
	public class Context
	{
		//public String orgnId;
		//public String userId;
		
		[JsonProperty("List")]
		public IList<object> Detail;
	}
	
	public class Detail
	{
		public String Response;
	}
	
	
	public void BuildDetail ( String sResult)
	{
		var detail 	= new Detail();
		
		detail.Response = sResult;
		
		result.context.Detail.Add(detail);
	}
	
	public void BuildContext()
	{
		//result.context.orgnId = sOrg;
		//result.context.userId = sUser;
		result.ApplicationException = "";
	}

	public bool IsReusable
	{
		get
		{
			return false;
		}
	}	
}
