using Microsoft.Extensions.Configuration;
using Microsoft.Identity.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using TodoWeb.Models;

namespace TodoWeb.Services
{
    public class FibonacciService : BaseService, IFibonacciService
    {
        private readonly string _scopes;
        private readonly string _baseAddress;
        private readonly string _apiAccessKey;

        public FibonacciService(ITokenAcquisition tokenAcquisition, HttpClient httpClient, IConfiguration configuration) : base(tokenAcquisition, httpClient)
        {
            _scopes = configuration["Fibonacci:Scopes"];
            _baseAddress = configuration["Fibonacci:BaseAddress"];
            _apiAccessKey = configuration["Fibonacci:ApiAccessKey"];
        }

        public async Task<IEnumerable<int>> GetSequenceAsync(int len)
        {
            //await base.PrepareAuthenticatedClient(_scopes, _apiAccessKey);
            base._httpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", _apiAccessKey);
            base._httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            var model = new FibonacciModel(len);
            string serialized = JsonConvert.SerializeObject(model);

            return await base.PostAsync<IEnumerable<int>>($"{_baseAddress}/GetFibonacciSeries", serialized);

        }
    }
}
