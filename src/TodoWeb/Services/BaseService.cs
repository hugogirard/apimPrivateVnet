using Microsoft.Identity.Web;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace TodoWeb.Services
{
    public abstract class BaseService
    {
        protected readonly ITokenAcquisition _tokenAcquisition;
        protected readonly HttpClient _httpClient;

        public BaseService(ITokenAcquisition tokenAcquisition, HttpClient httpClient)
        {
            _tokenAcquisition = tokenAcquisition;
            _httpClient = httpClient;
        }

        protected async Task<T> PostAsync<T>(string url, string serializedObject) where T : class
        {
            var jsoncontent = new StringContent(serializedObject, Encoding.UTF8, "application/json");
            var response = await this._httpClient.PostAsync($"{url}/api/fibo", jsoncontent);

            if (response.StatusCode == HttpStatusCode.OK)
            {
                var content = await response.Content.ReadAsStringAsync();
                var result = JsonConvert.DeserializeObject<T>(content);

                return result;
            }

            throw new HttpRequestException($"Invalid status code in the HttpResponseMessage: {response.StatusCode}.");
        }

        protected async Task PrepareAuthenticatedClient(string[] scopes, string apiAccessKey)
        {
            var accessToken = await _tokenAcquisition.GetAccessTokenForUserAsync(scopes);
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            _httpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", apiAccessKey);
            _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        }
    }
}
