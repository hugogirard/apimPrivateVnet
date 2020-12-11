using System.Collections.Generic;
using System.Threading.Tasks;
using TodoWeb.Models;

namespace TodoWeb.Services 
{
    public interface IToDoListService
    {
        Task<IEnumerable<ToDoItem>> GetAsync();

        Task<ToDoItem> GetAsync(int id);

        Task DeleteAsync(int id);

        Task<ToDoItem> AddAsync(ToDoItem todo);

        Task<ToDoItem> EditAsync(ToDoItem todo);
    }    
}