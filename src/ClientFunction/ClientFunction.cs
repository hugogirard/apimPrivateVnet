using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Azure.Identity;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net.Http.Headers;

namespace ClientFunction
{
    public class ClientFunction
    {
        private readonly IHttpClientFactory _factory;

        public ClientFunction(IHttpClientFactory factory)
        {
            _factory = factory;
        }

        [FunctionName("validateNumber")]     
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            try
            {

                string number = req.Query["number"];

                if (string.IsNullOrEmpty(number))
                {
                    return new BadRequestObjectResult("The query string parameter number is missing");
                }

                var http = _factory.CreateClient();

                var tokenCredential = new DefaultAzureCredential();               
                var accessToken = await tokenCredential.GetTokenAsync(new Azure.Core.TokenRequestContext(scopes: new string[]
                {
                    Environment.GetEnvironmentVariable("scope")                    
                }));
            
                var uri = new Uri($"{Environment.GetEnvironmentVariable("baseApiUrl")}/isPrime?number={number}");

                log.LogInformation(uri.ToString());

                http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer",accessToken.Token);
                
                http.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", Environment.GetEnvironmentVariable("Ocp-Apim-Subscription-Key"));
                var response = await http.PostAsync(uri,null);

                if (response.IsSuccessStatusCode)
                {
                    return new OkObjectResult(await response.Content.ReadAsStringAsync());
                }

                return new BadRequestObjectResult(response.StatusCode);
                
            }
            catch (Exception ex)
            {               
                log.LogError(ex.Message);
                throw ex;
            }

        }
    }
}

