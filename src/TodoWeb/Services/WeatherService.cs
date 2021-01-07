using Microsoft.Extensions.Configuration;
using Microsoft.Identity.Web;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using TodoWeb.Models;

namespace TodoWeb.Services
{
    public class WeatherService : IWeatherService
    {
        private HttpClient _httpClient;
        private ITokenAcquisition _tokenAcquisition;
        private readonly string _WeatherScope;
        private readonly string _WeatherBaseAddress;
        private readonly string _apiAccessKey;

        public WeatherService(ITokenAcquisition tokenAcquisition, HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _tokenAcquisition = tokenAcquisition;
            _WeatherScope = configuration["WeatherApp:WeathertScope"];
            _WeatherBaseAddress = configuration["WeatherApp:WeatherBaseAddress"];
            _apiAccessKey = configuration["WeatherApp:ApiAccessKey"];
        }

        public async Task<IEnumerable<WeatherForecast>> GetAsync()
        {
            await PrepareAuthenticatedClient();
            var response = await _httpClient.GetAsync($"{ _WeatherBaseAddress}/api/weatherforecast");
            if (response.StatusCode == HttpStatusCode.OK)
            {
                var content = await response.Content.ReadAsStringAsync();
                var weatherforecast = JsonConvert.DeserializeObject<IEnumerable<WeatherForecast>>(content);

                return weatherforecast;
            }

            throw new HttpRequestException($"Invalid status code in the HttpResponseMessage: {response.StatusCode}.");
        }

        private async Task PrepareAuthenticatedClient()
        {
            var accessToken = await _tokenAcquisition.GetAccessTokenForUserAsync(new[] { _WeatherScope });
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            _httpClient.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", _apiAccessKey);
            _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        }
    }
}
