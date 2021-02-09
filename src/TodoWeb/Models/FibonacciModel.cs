using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TodoWeb.Models
{
    public class FibonacciModel
    {
        public FibonacciModel(int len)
        {
            Body = new SoapBody
            { 
                Len = len
            };
        }

        [JsonProperty("getFibonacciSeries")]
        public SoapBody Body { get; set; }
    }

    public class SoapBody 
    {
        [JsonProperty("len")]
        public int Len { get; set; }
    }
}
