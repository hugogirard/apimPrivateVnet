using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace PrimeNumberFunction
{
    public static class Function1
    {
        [FunctionName("IsPrime")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
            ILogger log)
        { 
            string queryString = req.Query["number"];

            if (string.IsNullOrEmpty(queryString)) 
            {
                return new BadRequestObjectResult("The query string parameter number is missing");
            }
            
            int number = int.Parse(queryString);
                        
            return new OkObjectResult(IsPrime(number));
        }

        private static bool IsPrime(int number)
        {

            if (number <= 1) return false;
            if (number == 2) return true;
            if (number % 2 == 0) return false;

            var boundary = (int)Math.Floor(Math.Sqrt(number));

            for (int i = 3; i <= boundary; i += 2)
                if (number % i == 0)
                    return false;

            return true;

        }
    }
}
