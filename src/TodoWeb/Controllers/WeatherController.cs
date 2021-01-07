using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Web;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TodoWeb.Services;

namespace TodoWeb.Controllers
{
    [AuthorizeForScopes(ScopeKeySection = "WeatherApp:WeathertScope")]
    public class WeatherController : Controller
    {
        private readonly IWeatherService _weatherService;

        public WeatherController(IWeatherService weatherService)
        {
            _weatherService = weatherService;
        }

        public async Task<ActionResult> Index()
        {
            return View(await _weatherService.GetAsync());
        }
    }
}
