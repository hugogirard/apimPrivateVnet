using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

// NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "Service" in code, svc and config file together.
public class FibonacciService : IFibonacciService
{
	public IEnumerable<int> GetFibonacciSeries(int len)
	{
        var result = new List<int>();
        int a = 0, b = 1, c = 0;        
        for (int i = 2; i < len; i++)
        {
            c = a + b;
            result.Add(c);
            a = b;
            b = c;
        }

        return result;
    }
}
