<%@ WebHandler Language="C#" class="fetch_userrolemap" %>

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


public class fetch_userrolemap: IHttpHandler,System.Web.SessionState.IRequiresSessionState
{
	StatusObject statusObject = new StatusObject();
	
	String jsonString = String.Empty;
	JsonSerializerSettings settings = new JsonSerializerSettings();
	
	String 	sOrg		= "";
	String	sLocn		= "";
	String	sUser		= "";
	String	sLang		= "";
	String	sUser_id	= "";
	String	sRole_id	= "";

	String	sScreen_id		= "";
	String 	sScreen_name	= "";
	String	sNew_perm		= "";
	String	sMod_perm		= "";
	String	sDel_perm		= "";
	String	sPrn_perm		= "";
	String	sView_perm		= "";
	String	sDeny_perm		= "";
	
	//DATARETURN - Declaration
	Result result = new Result();
	Util util = new Util();
	DirectoryLookup directoryLookup=new DirectoryLookup();

	public void logResult (HttpContext context, String sLogString )
	{
		directoryLookup.logResultForSituation(context,"fetch_userrolemap",sLogString);
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
				sLocn	= (String.IsNullOrEmpty(context.Request.QueryString["locn"])) ? "" : context.Request.QueryString["locn"].ToString();
				sUser	= (String.IsNullOrEmpty(context.Request.QueryString["user"])) ? "" : context.Request.QueryString["user"].ToString();
				sLang	= (String.IsNullOrEmpty(context.Request.QueryString["lang"])) ?	"" : context.Request.QueryString["lang"].ToString();	
				sUser_id = (String.IsNullOrEmpty(context.Request.QueryString["user_id"])) ? "" : context.Request.QueryString["user_id"].ToString();
				sRole_id = (String.IsNullOrEmpty(context.Request.QueryString["role_id"])) ?	"" : context.Request.QueryString["role_id"].ToString();
			}
			//directoryLookup.logActivity(context,"fetch_userrolemap ashx", "Fetch UserRoleMap" , context.Request.QueryString.ToString());

			try
				{
					String sDSN=context.Session["PPControl"].ToString();
					using (SqlConnection conPush = new SqlConnection(sDSN))
					{	
						conPush.Open();
						var sCommand="fetch_userrolemap";
						using (SqlCommand cmd = new SqlCommand(sCommand , conPush))
						{
							try
							{
								cmd.CommandType = CommandType.StoredProcedure;
								cmd.CommandTimeout = 0;

								//Register Parameters
								cmd.Parameters.Add("@orgnId", SqlDbType.VarChar).Value = sOrg;
								cmd.Parameters.Add("@locnId", SqlDbType.VarChar).Value = sLocn;
								cmd.Parameters.Add("@localeId", SqlDbType.VarChar).Value = sLang;
								cmd.Parameters.Add("@userId", SqlDbType.VarChar).Value = sUser;
								cmd.Parameters.Add("@user_id", SqlDbType.VarChar).Value = sUser_id;
								cmd.Parameters.Add("@role_id", SqlDbType.VarChar).Value = sRole_id;
								
								using ( SqlDataReader reader = cmd.ExecuteReader())
								{
									while (reader.Read())
									{
										sScreen_id = reader["screen_id"].ToString();
										sScreen_name = reader["screen_name"].ToString();
										sNew_perm = reader["new_perm"].ToString();
										sMod_perm = reader["mod_perm"].ToString();
										sDel_perm = reader["del_perm"].ToString();
										sPrn_perm = reader["prn_perm"].ToString();
										sView_perm = reader["view_perm"].ToString();
										sDeny_perm = reader["deny_perm"].ToString();

										BuildDetail ( sScreen_id, sScreen_name, sNew_perm, sMod_perm, sDel_perm, sPrn_perm, sView_perm, sDeny_perm);
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
				logResult(context, "fetch_userrolemap Exception :" + e.Message);
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
			logResult(context, "fetch_userrolemap Error :" + e.Message);
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
		public String orgnId;
		public String locnId;
		
		[JsonProperty("Detail")]
		public IList<object> Detail;
	}
	
	public class Detail
	{
		public String screen_id;
		public String screen_name;
		public String new_perm;
		public String mod_perm;
		public String del_perm;
		public String prn_perm;
		public String view_perm;
		public String deny_perm;
	}
	
	public void BuildDetail ( String sScreen_id, String sScreen_name, String sNew_perm, String sMod_perm, String sDel_perm, String sPrn_perm, String 
	sView_perm, String sDeny_perm)
	{
		var detail = new Detail();
		
		detail.screen_id	= sScreen_id;
		detail.screen_name	= sScreen_name;
		detail.new_perm		= sNew_perm;
		detail.mod_perm		= sMod_perm;
		detail.del_perm		= sDel_perm;
		detail.prn_perm		= sPrn_perm;
		detail.view_perm	= sView_perm;
		detail.deny_perm	= sDeny_perm;
		
		result.context.Detail.Add(detail);
	}
	
	public void BuildContext()
	{
		result.context.orgnId = sOrg;
		result.context.locnId = sLocn;
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