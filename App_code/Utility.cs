using System;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Caching;
using Types;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Net;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Messaging;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using Newtonsoft.Json.Linq;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Hosting;
//using Microsoft.Azure.Documents;
//using Microsoft.Azure.Documents.Client;
//using Microsoft.Azure.Documents.Linq;



namespace Utility
{
	public class Util
	{
		public HttpContext SetContext(HttpContext context)
		{
			context.Response.AddHeader("CACHE-CONTROL", "NO-CACHE");
			context.Response.AddHeader("EXPIRES", "0");
			context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
			context.Response.AddHeader("Acces-Control-Allow-Origin","*");
			context.Response.AddHeader("Acces-Control-Allow-Methods","GET,POST,PUT,PATCH,DELETE");

			return context;
		}
	}
	
	public class DirectoryLookup
	{
	   private static readonly object _lock = new object();

		String jsonString = String.Empty;
		JsonSerializerSettings settings = new JsonSerializerSettings();
		//settings.NullValueHandling = NullValueHandling.Ignore;


		public void logServiceEnd (HttpContext context, String sService, String sPayLoad){
			logServiceEnd_async ( context,  sService,  sPayLoad);
		}

		private async Task  logServiceEnd_async (HttpContext context, String sService, String sPayLoad){
				lock(_lock){				
					try
					{
						//DateTime istTime1 = DateTime.Now.AddHours(5.5);
						DateTime istTime1 = DateTime.Now;
						String sFileName="";
						sFileName=String.Format("_SERVICECALL_LOG_{0:yyyy-MM-dd}.txt", istTime1);
						using (StreamWriter w = File.AppendText(context.Server.MapPath("~/server/Metrics/"+sFileName)))
						{
							DateTime istTime = DateTime.Now.AddHours(5.5);
							String sLineToWrite="";
							sLineToWrite=String.Format(" {0:MM/dd/yyyy}  {0:HH:mm:ss.ffffff}", istTime) +" : "+ sService+":Ends";
							w.WriteLine("ASYNC : {0}", sLineToWrite);
						}
					}
					catch (Exception e){
						using (StreamWriter w = File.AppendText(context.Server.MapPath("~/server/Metrics/_SERVICECALLERROR.txt")))
						{
							w.WriteLine("{0}", e.Message);
						}
					}
				}
		}


		public void logServiceCall (HttpContext context, String sService, String sPayLoad){
			logServiceCall_async ( context,  sService,  sPayLoad);
		}


		public void logMetric (HttpContext context, String sMetric, int nValue){
			return;
			lock(_lock){	
				try
				{
					String sStats="";
					String sPV="";
					sPV=sMetric;
					if (File.Exists(context.Server.MapPath("~/server/Metrics/GetMeStats_serverlog.txt")))
						sStats=File.ReadAllText(context.Server.MapPath("~/server/Metrics/GetMeStats_serverlog.txt"));
					else
						sStats="";

					int nStart=0;
					int nEnd=0;
					int nCount=0;
					String sLine="";
					nStart=sStats.IndexOf("#"+sPV+"#");
					 if (nStart >-1) { 
					 	nEnd=sStats.IndexOf("#$#",nStart)+3;
					 	sLine=sStats.Substring(nStart,nEnd-nStart);
					 	sStats=sStats.Replace(sLine,"");
					 	sLine=sLine.Replace("#"+sPV+"#","");
					 	sLine=sLine.Replace("#$#","");
					 	nCount=Int32.Parse(sLine);
					}
					nCount=nCount+nValue;
				 	sStats="#"+sPV+"#"+nCount.ToString()+"#$#"+sStats;
				 	File.WriteAllText(context.Server.MapPath("~/server/Metrics/GetMeStats_serverlog.txt"),sStats);
				}
				catch (Exception e){
					using (StreamWriter w = File.AppendText(context.Server.MapPath("~/server/Metrics/STATERROR.txt")))
					{
						w.WriteLine("{0}", e.Message);
					}
				}
			}
		}


		private async Task  logServiceCall_async (HttpContext context, String sService, String sPayLoad){
				lock(_lock){				
					try
					{
						//DateTime istTime1 = DateTime.Now.AddHours(5.5); //UTC to GMT
						DateTime istTime1 = DateTime.Now;
						String sFileName="";
						sFileName=String.Format("_SERVICECALL_LOG_{0:yyyy-MM-dd}.txt", istTime1);
						using (StreamWriter w = File.AppendText(context.Server.MapPath("~/server/Metrics/"+sFileName)))
						{
							DateTime istTime = DateTime.Now;
							String sLineToWrite="";
							sLineToWrite=String.Format(" {0:MM/dd/yyyy}  {0:HH:mm:ss.ffffff}", istTime) +" : "+ sService+":"+sPayLoad;
							w.WriteLine("ASYNC : {0}", sLineToWrite);
						}
					}
					catch (Exception e){
						using (StreamWriter w = File.AppendText(context.Server.MapPath("~/server/Metrics/_SERVICECALLERROR.txt")))
						{
							w.WriteLine("{0}", e.Message);
						}
					}
				}
		}

		private async Task logLineToFile (HttpContext context, String sPV, String sLogString)
		{
			if ( (context.Session["debugflag"].ToString()=="1") || ( sPV=="_USER_EXCEPTIONS")){
				lock(_lock){				
					using (StreamWriter w = File.AppendText(context.Server.MapPath("~/server/logfiles/"+sPV+"_serverlog.txt")))
					{
						w.WriteLine("ASYNC : {0}", sLogString);
					}
				}
			}
			return;		
		}


		public void logLaunch (HttpContext context, String sLine)
		{
			return;
			DateTime istTime = DateTime.Now.AddHours(5.5);
			String sLineToWrite="";
			sLineToWrite=String.Format(" {0:MM/dd/yyyy}  {0:HH:mm:ss.ffffff}", istTime) +" : "+ sLine;

			lock(_lock){
				using (StreamWriter w = File.AppendText(context.Server.MapPath("~/server/Metrics/usersignature.txt")))
				{
					w.WriteLine("SYNC : {0}", sLineToWrite);
				}				
			}
		}

		public void logPVString (HttpContext context, String sPV, String sLogString )
		{
			DateTime istTime = DateTime.Now.AddHours(5.5);
			String sLineToWrite="";
			sLineToWrite=String.Format(" {0:MM/dd/yyyy}  {0:HH:mm:ss.ffffff}", istTime) +" : "+ sLogString;

			logLineToFile( context, sPV, sLineToWrite);
			return;
		}	
		
		public void logResult (HttpContext context, String sLogString )
		{
				if (context.Session["debugflag"].ToString()=="1"){
					logPVString(context, "CONFIG",sLogString);
				}
		}		
		
		public void logResultForSituation (HttpContext context, String sSituation, String sLogString )
		{
				if (context.Session["debugflag"].ToString()=="1") {
					logPVString(context, sSituation,sLogString);
				}
		}		


		public void logActivity (HttpContext context, String sUser, String sFunctionality, String sPayload )
		{
			if (context.Session["debugflag"].ToString()=="1"){
				lock(_lock){				
					using (StreamWriter w = File.AppendText(context.Server.MapPath("~/server/activity/activity_serverlog.txt")))
					{
						DateTime istTime = DateTime.Now.AddHours(5.5);

						w.Write("{0} {1} {2} ", istTime.ToString("s").Replace("T"," ") ,
							sUser, sFunctionality);
						w.WriteLine("  :{0}", sPayload);
					}
				}
			}
			return;
		}

		
		public string GetTextFromFile(HttpContext context, string sFileName){
			String line="";
			try
			{ 
				using (StreamReader sr = new StreamReader(sFileName))
				{
					 line = sr.ReadToEnd();
				}
			}
			catch (Exception e)
			{
				//Console.WriteLine("The file could not be read:");
				//Console.WriteLine(e.Message);
			}
			return line;
		}
		
		public bool IsMobileNumberValid(HttpContext context, string mobileNumber)
	    {
			try{
		    	String _mobileNumber="";

		        // remove all non-numeric characters
		        _mobileNumber = CleanNumber(context, mobileNumber);

		        // trim any leading zeros
		        _mobileNumber = _mobileNumber.TrimStart(new char[] { '0' });

		        if (_mobileNumber.StartsWith("91"))
		        {
			        if (_mobileNumber.Length == 12)
			        {
			            _mobileNumber = _mobileNumber.Remove(0, 2);
			        }

		        }

		        // check if it's the right length
		        if (_mobileNumber.Length != 10)
		        {
		            return false;
		        }
		        return true;
			}
			catch(Exception e) {
				logResult(context, "IsMobileNumberValid Exception : "+e.Message);
				return false;
			}
	    }

	    private string CleanNumber(HttpContext context, string phone)
	    { 
	    	String sNumber="";
			try{
		         for (int i = 0; i< 10;i++)
		         {
		         	if (phone[i] >='0' && phone[i] <= '9')
		         	sNumber=sNumber+phone[i];
		         }

		    }
			catch(Exception e){
				logResult(context, "CleanNumber Exception : "+e.Message);				
			}
	        return sNumber;
	    }
	}
}
