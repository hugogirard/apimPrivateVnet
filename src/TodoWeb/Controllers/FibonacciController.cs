using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TodoWeb.Services;
using TodoWeb.ViewModel;

namespace TodoWeb.Controllers
{
    public class FibonacciController : Controller
    {
        private readonly IFibonacciService _fibonacciService;

        public FibonacciController(IFibonacciService fibonacciService)
        {
            _fibonacciService = fibonacciService;
        }

        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Create([Bind] FibonacciViewModel vm)
        {
            var result = await _fibonacciService.GetSequenceAsync(vm.Len);
            return Ok();
        }

    }
}
