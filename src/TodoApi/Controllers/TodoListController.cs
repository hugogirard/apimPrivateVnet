using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using TodoApi.Models;
using Microsoft.Identity.Web.Resource;
using Microsoft.Identity.Web;
using Microsoft.Identity.Client;
using System.Net.Http.Headers;
using System.Net;
using System.Security.Claims;
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;

namespace TodoApi.Controllers
{
    /// <summary>
    /// Simple Todo API
    /// </summary>
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class TodoListController : ControllerBase
    {                
        private readonly IHttpContextAccessor _contextAccessor;
        private readonly TodoContext _repository;
        
        public TodoListController(IHttpContextAccessor contextAccessor, TodoContext context)
        {
            this._contextAccessor = contextAccessor;
            this._repository = context;
        }

        /// <summary>
        /// Get all TodoItem
        /// </summary>        
        [HttpGet]
        public async Task<IEnumerable<TodoItem>> Get()
        {
            string owner = User.Identity.Name;            
            return await _repository.TodoItems.Where(x => x.Owner == owner).ToListAsync();            
        }

        [HttpGet("all")]
        public async Task<IEnumerable<TodoItem>> All() 
        {
            HttpContext.ValidateAppRole("DaemonAppRole");
            return await _repository.TodoItems.ToListAsync();
        }

        /// <summary>
        /// Test to reach the web api
        /// </summary>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpGet("test")]
        public IActionResult Test() 
        {
            return new OkObjectResult("Works");
        }

        /// <summary>
        /// Get specific todo item by id
        /// </summary>
        [HttpGet("{id}", Name = "Get")]
        public async Task<TodoItem> Get(int id)
        {
            return await _repository.TodoItems.FirstOrDefaultAsync(t => t.Id == id);            
        }

        /// <summary>
        /// Delete specific todo item by id
        /// </summary>        
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var entity = await _repository.TodoItems.SingleOrDefaultAsync(x => x.Id == id);

            if (entity == null) 
            {
                return Ok(0);
            }

            _repository.TodoItems.Remove(entity);
            await _repository.SaveChangesAsync();

            return Ok();
        }

        /// <summary>
        /// Create a new todo item
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Post([FromBody] TodoItem todo)
        {                            
            TodoItem todonew = new TodoItem() { Owner = HttpContext.User.Identity.Name, Title = todo.Title };
            _repository.TodoItems.Add(todonew);
            await _repository.SaveChangesAsync();

            return Ok(todo);
        }

        /// <summary>
        /// Update a specific todo item
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> Patch(int id, [FromBody] TodoItem todo)
        {
            if (id != todo.Id)
            {
                return NotFound();
            }

            var oldEntity = await _repository.TodoItems.SingleOrDefaultAsync(x => x.Id == id);

            if (oldEntity == null)
            {
                return NotFound();
            }

            _repository.TodoItems.Update(todo);
            await _repository.SaveChangesAsync();

            return Ok(todo);
        }
    }
}