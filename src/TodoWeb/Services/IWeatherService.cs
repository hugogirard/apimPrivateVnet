using System.Collections.Generic;
using System.Threading.Tasks;
using TodoWeb.Models;

namespace TodoWeb.Services
{
    public interface IWeatherService
    {
        Task<IEnumerable<WeatherForecast>> GetAsync();
    }
}