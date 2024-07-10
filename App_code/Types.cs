using System;
using System.Collections;
using System.Collections.Generic;

namespace Types
{
	public class StatusObject
	{
		public String update;
		public String error;
		public String errorat; 
		public String message;
		public object data;
		
		public StatusObject()
		{
			update = "successful";
			error="";
			errorat="";
			message="";
			data=null;
		}
	}
 

	public class LogItem
    {
		public String logtime;
		public String logString ;
	}
	  
  
  
  
}