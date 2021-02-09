using System;
using Microsoft.AspNetCore.Mvc;

namespace PrimeApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PrimeController : ControllerBase 
    {
        [HttpGet]
        [Route("isPrime")]
        public bool Get(int number) 
        {
            if (number == 1) return false;
            if (number == 2) return true;

            var limit = Math.Ceiling(Math.Sqrt(number)); //hoisting the loop limit

            for (int i = 2; i <= limit; ++i)  
            if (number % i == 0)  
                return false;
                
            return true;
        }
    }
}