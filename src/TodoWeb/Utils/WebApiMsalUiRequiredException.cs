using System;

namespace TodoWeb.Utils 
{
    public class WebApiMsalUiRequiredException:Exception
    {
        public WebApiMsalUiRequiredException(string message) : base(message) { }
    }    
}