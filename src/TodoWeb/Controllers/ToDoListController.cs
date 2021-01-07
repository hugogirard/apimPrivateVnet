using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Identity.Web;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TodoWeb.Models;
using TodoWeb.Services;
using TodoWeb.Utils;

namespace TodoWeb.Controllers
{
    [AuthorizeForScopes(ScopeKeySection = "TodoList:TodoListScope")]
    public class ToDoListController : Controller
    {
        private IToDoListService _todoListService;

        public ToDoListController(IToDoListService todoListService)
        {
            _todoListService = todoListService;
        }

        // GET: TodoList
        [AuthorizeForScopes(ScopeKeySection = "TodoList:TodoListScope")]
        public async Task<ActionResult> Index()
        {
            return View(await _todoListService.GetAsync());
        }

        // GET: TodoList/Details/5
        public async Task<ActionResult> Details(int id)
        {
            return View(await _todoListService.GetAsync(id));
        }

        // GET: TodoList/Create
        public ActionResult Create()
        {
            ToDoItem todo = new ToDoItem() { Owner = HttpContext.User.Identity.Name };
            return View(todo);
        }

        // POST: TodoList/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Create([Bind("Title,Owner")] ToDoItem todo)
        {
            await _todoListService.AddAsync(todo);
            return RedirectToAction("Index");
        }

        // GET: TodoList/Edit/5
        public async Task<ActionResult> Edit(int id)
        {
            ToDoItem todo = await this._todoListService.GetAsync(id);

            if (todo == null)
            {
                return NotFound();
            }

            return View(todo);
        }

        // POST: TodoList/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Edit(int id, [Bind("Id,Title,Owner")] ToDoItem todo)
        {
            await _todoListService.EditAsync(todo);
            return RedirectToAction("Index");
        }

        // GET: TodoList/Delete/5
        public async Task<ActionResult> Delete(int id)
        {
            ToDoItem todo = await this._todoListService.GetAsync(id);

            if (todo == null)
            {
                return NotFound();
            }

            return View(todo);
        }

        // POST: TodoList/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Delete(int id, [Bind("Id,Title,Owner")] ToDoItem todo)
        {
            await _todoListService.DeleteAsync(id);
            return RedirectToAction("Index");
        }
    }
}