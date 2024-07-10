<%@ WebHandler Language="C#" class="fetch_userrole" %>

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


public class fetch_userrole: IHttpHandler,System.Web.SessionState.IRequiresSessionState
{
	StatusObject statusObject = new StatusObject();
	
	String jsonString = String.Empty;
	JsonSerializerSettings settings = new JsonSerializerSettings();
	
	String 	sOrg	="";
	String	sLocn	="";
	String	sUser	="";
	String	sLang	="";
	String	sUser_id="";

	String	sUser_name		= "";
	String	sRole_id		= "";
	String	sUser_password	= "";
	String 	sValid_until	= "";
	String 	sEmail_id		= "";
	String 	sUser_of_code	= "";
	String 	sProfile_photo	= "";
	String 	sStatus_desc	= "";
	String	sUser_mobile	= "";
	String	sApprover_code	= "";
	
	String	sSel_flag			= "";
	String	sRole_description	= "";
	String	sDef_role_flag		= "";
	
	String 	sTab_name;
	String	sCtrl_type;
	String	sCtrl_id;
	String	sCtrl_value;
	
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
		
		result.context= new Context();
		result.context.Header = new Header();
		result.context.Detail = new List<object>();
		result.context.Tab_Detail = new List<object>();
		
		
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
			}
			//directoryLookup.logActivity(context,"fetch_userrole ashx", "Fetch UserRole" , context.Request.QueryString.ToString());

			try
				{
					String sDSN=context.Session["PPControl"].ToString();
					using (SqlConnection conPush = new SqlConnection(sDSN))
					{	
						conPush.Open();
						var sCommand="fetch_userrole";
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
								
								SqlParameter prmuser_name =  cmd.Parameters.Add("@user_name", SqlDbType.NVarChar, 256);
								prmuser_name.Direction = ParameterDirection.Output;
								 
								cmd.Parameters.Add("@role_id", SqlDbType.VarChar, 20).Direction = ParameterDirection.Output;
								cmd.Parameters.Add("@user_password", SqlDbType.NVarChar, 256).Direction = ParameterDirection.Output;
								cmd.Parameters.Add("@valid_until", SqlDbType.VarChar, 10).Direction = ParameterDirection.Output;
								cmd.Parameters.Add("@email_id", SqlDbType.NVarChar, 256).Direction = ParameterDirection.Output;
								cmd.Parameters.Add("@user_of_code", SqlDbType.VarChar, 20).Direction = ParameterDirection.Output;
								cmd.Parameters.Add("@profile_photo", SqlDbType.VarChar, -1).Direction = ParameterDirection.Output;
								cmd.Parameters.Add("@status_desc", SqlDbType.NVarChar, 256).Direction = ParameterDirection.Output;
								cmd.Parameters.Add("@user_mobile", SqlDbType.NVarChar, 256).Direction = ParameterDirection.Output;
								cmd.Parameters.Add("@approver_code", SqlDbType.VarChar, 20).Direction = ParameterDirection.Output;
								
								using (SqlDataReader reader = cmd.ExecuteReader())
								{
									while (reader.Read())
									{
										sSel_flag = reader["sel_flag"].ToString();
										sRole_id = reader["role_id"].ToString();
										sRole_description = reader["role_description"].ToString();
										sDef_role_flag = reader["def_role_flag"].ToString();
										
										BuildDetail ( sSel_flag, sRole_id, sRole_description, sDef_role_flag);
									}
									reader.NextResult();
									while (reader.Read())
									{
										sTab_name	= reader["tab_name"].ToString().Trim(); 
										sCtrl_type	= reader["ctrl_type"].ToString().Trim(); 
										sCtrl_id	= reader["ctrl_id"].ToString().Trim(); 
										sCtrl_value	= reader["ctrl_value"].ToString().Trim(); 
										
										BuildTabDetail ( sTab_name, sCtrl_type, sCtrl_id, sCtrl_value );
									}
									// reader must be closed before reading the output parameter
									reader.Close();
								}
								
								sUser_name 		=  prmuser_name.Value.ToString().Trim();
								sRole_id 		=  cmd.Parameters["@role_id"].Value.ToString();
								sUser_password 	=  cmd.Parameters["@user_password"].Value.ToString();
								sValid_until 	=  cmd.Parameters["@valid_until"].Value.ToString();
								sEmail_id 		=  cmd.Parameters["@email_id"].Value.ToString();
								sUser_of_code 	=  cmd.Parameters["@user_of_code"].Value.ToString();
								sProfile_photo 	=  cmd.Parameters["@profile_photo"].Value.ToString();
								sStatus_desc 	=  cmd.Parameters["@status_desc"].Value.ToString();
								sUser_mobile 	=  cmd.Parameters["@user_mobile"].Value.ToString();
								sApprover_code 	=  cmd.Parameters["@approver_code"].Value.ToString();

								BuildHeader ( sUser_name, sRole_id, sUser_password, sValid_until, sEmail_id, sUser_of_code, sProfile_photo, sUser_mobile, sApprover_code);
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
				logResult(context, "fetch_userrole Exception :" + e.Message);
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
			logResult(context, "fetch_userrole Error :" + e.Message);
		}
	}
	
		 
	//DATARETURN -- Class Declaration	 
	public class Result
	{
		public Context context;
	}
	
	public class Context
	{
		public String orgnId;
		public String locnId;
		public Header Header;
		
		[JsonProperty("Detail")]
		public IList<object> Detail;
		
		[JsonProperty("Tab_Detail")]
		public IList<object> Tab_Detail;
		
	}
	
	public class Header
	{
		public String user_name;
		public String role_id;
		public String user_password;
		public String valid_until;
		public String email_id;
		public String user_of_code;
		public String profile_photo;
		public String status_desc;
		public String user_mobile;
		public String approver_code;
	}
	
	public class Detail
	{
		public String sel_flag;
		public String role_id;
		public String role_description;
		public String def_role_flag;
	}
	public class Tab_Detail
	{
		public String	tab_name;
		public String	ctrl_type;
		public String	ctrl_id;
		public String	ctrl_value;
	}
	
	public void BuildHeader ( String sUser_name, String sRole_id, String sUser_password, String sValid_until, String sEmail_id, String sUser_of_code, String  sProfile_photo, String sUser_mobile, String sApprover_code)
	{
		result.context.Header.user_name 		= sUser_name;
		result.context.Header.role_id 			= sRole_id;
		result.context.Header.user_password		= sUser_password;
		result.context.Header.valid_until		= sValid_until;
		result.context.Header.email_id			= sEmail_id;
		result.context.Header.user_of_code		= sUser_of_code;
		result.context.Header.profile_photo		= sProfile_photo;
		result.context.Header.status_desc		= sStatus_desc;
		result.context.Header.user_mobile		= sUser_mobile;
		result.context.Header.approver_code		= sApprover_code;
	}

	public void BuildDetail ( String sSel_flag, String sRole_id, String sRole_description, String sDef_role_flag)
	{
		var detail = new Detail();
		
		detail.sel_flag			= sSel_flag;
		detail.role_id			= sRole_id;
		detail.role_description	= sRole_description;
		detail.def_role_flag	= sDef_role_flag;
		
		result.context.Detail.Add(detail);
	}
	public void BuildTabDetail ( String sTab_name, String sCtrl_type, String sCtrl_id, String  sCtrl_value)
	{
		var t_detail 	= new Tab_Detail();
		
		t_detail.tab_name	= sTab_name;
		t_detail.ctrl_type	= sCtrl_type;
		t_detail.ctrl_id	= sCtrl_id;
		t_detail.ctrl_value	= sCtrl_value;

		result.context.Tab_Detail.Add(t_detail);
	}
	
	public void BuildContext()
	{
		result.context.orgnId = sOrg;
		result.context.locnId = sLocn;
	}

	public bool IsReusable
	{
		get
		{
			return false;
		}
	}	
}