<%@ WebHandler Language="C#" class="fetch_alluserrolelist" %>

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


public class fetch_alluserrolelist: IHttpHandler,System.Web.SessionState.IRequiresSessionState
{
	StatusObject statusObject = new StatusObject();
	
	String jsonString = String.Empty;
	JsonSerializerSettings settings = new JsonSerializerSettings();
	
	String 	sOrg	="";
	String	sLocn	="";
	String	sUser	="";
	String	sLang	="";

	String 	sFilterby			= "";
	String	sUser_id			= "";
	String	sUser_name			= "";
	String	sRole_id			= "";
	String	sRole_description	= "";
	String 	sValid_until		= "";
	String 	sEmail_id			= "";
	String 	sUser_of_desc		= "";
	String 	sStatus_desc		= "";
	String	sUser_mobile		= "";
	String	sApprover_desc 		= "";
	
	
	//DATARETURN - Declaration
	Result result = new Result();
	Util util = new Util();
	DirectoryLookup directoryLookup=new DirectoryLookup();

	public void logResult (HttpContext context, String sLogString )
	{
		directoryLookup.logResultForSituation(context,"fetch_userrole",sLogString);
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
				sFilterby	= (String.IsNullOrEmpty(context.Request.QueryString["filterby"])) ?	"" : context.Request.QueryString["filterby"].ToString();	
			}
			//directoryLookup.logActivity(context,"fetch_alluserrolelist ashx", "Fetch UserList" , context.Request.QueryString.ToString());

			try
				{
					String sDSN=context.Session["DBControl"].ToString();
					using (SqlConnection conPush = new SqlConnection(sDSN))
					{	
						conPush.Open();
						var sCommand="fetch_userrole_list";
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
								cmd.Parameters.Add("@filterby", SqlDbType.NVarChar).Value = sFilterby;

								using ( SqlDataReader reader = cmd.ExecuteReader())
								{
									while (reader.Read())
									{
										sUser_id 			=  reader["user_id"].ToString().Trim();
										sUser_name 			=  reader["user_name"].ToString().Trim();
										sRole_id 			=  reader["role_id"].ToString().Trim();
										sRole_description 	=  reader["role_description"].ToString().Trim();
										sValid_until 		=  reader["valid_until"].ToString().Trim();
										sEmail_id 			=  reader["email_id"].ToString().Trim();
										sUser_of_desc 		=  reader["user_of_desc"].ToString().Trim();
										sStatus_desc 		=  reader["status_desc"].ToString().Trim();
										sUser_mobile 		=  reader["user_mobile"].ToString().Trim();
										sApprover_desc 		=  reader["approver_desc"].ToString().Trim();

										BuildDetail ( sUser_id, sUser_name, sRole_id, sRole_description, sValid_until, sEmail_id, sUser_of_desc,  sStatus_desc, sUser_mobile, sApprover_desc);
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
				logResult(context, "fetch_alluserrolelist Exception :" + e.Message);
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
			logResult(context, "fetch_alluserrolelist Error :" + e.Message);
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
		
		[JsonProperty("List")]
		public IList<object> Detail;
	}
	
	public class Detail
	{
		public String user_id;
		public String user_name;
		public String role_id;
		public String role_description;
		public String valid_until;
		public String email_id;
		public String user_of_desc;
		public String status_desc;
		public String user_mobile;
		public String approver_desc;
	}
	
	
	public void BuildDetail ( String sUser_id, String sUser_name, String sRole_id, String sRole_description, String sValid_until, String sEmail_id, String sUser_of_desc, String  sStatus_desc, String sUser_mobile, String sApprover_desc)
	{
		var detail 	= new Detail();
		
		detail.user_id 			= sUser_id;
		detail.user_name 		= sUser_name;
		detail.role_id 			= sRole_id;
		detail.role_description	= sRole_description;
		detail.valid_until		= sValid_until;
		detail.email_id			= sEmail_id;
		detail.user_of_desc		= sUser_of_desc;
		detail.status_desc		= sStatus_desc;
		detail.user_mobile		= sUser_mobile;
		detail.approver_desc	= sApprover_desc;
		
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
