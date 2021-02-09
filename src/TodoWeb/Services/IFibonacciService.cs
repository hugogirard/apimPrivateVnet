using System.Collections.Generic;
using System.Threading.Tasks;

namespace TodoWeb.Services
{
    public interface IFibonacciService
    {
        Task<IEnumerable<int>> GetSequenceAsync(int len);
    }
}