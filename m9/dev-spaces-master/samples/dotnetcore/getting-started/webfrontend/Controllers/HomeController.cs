using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using webfrontend.Models;

namespace webfrontend.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
/*
        public IActionResult About()
        {
            ViewData["Message"] = "Your application description page.";

            return View();
        }
*/

	public async Task<IActionResult> About()
	{
		ViewData["Message"] = "Hello from webfrontend!!";

		using (var client = new System.Net.Http.HttpClient())
			{
				// Call *mywebapi*, and display its response in the page
				var request = new System.Net.Http.HttpRequestMessage();

                // For Team Development Demo in Azure Dev Spaces uncomment the below code
				request.RequestUri = new Uri("http://azds-dev-int-me.s.mywebapi.b612f154a46a4a46b11d.eastus2.aksapp.io:80/api/values/1");
                // For Individual Development Demo in Azure Dev Spaces uncomment the below code
				// request.RequestUri = new Uri("http://mywebapi/api/values/1");
				if (this.Request.Headers.ContainsKey("azds-route-as"))
				{
					// Propagate the dev space routing header
					request.Headers.Add("azds-route-as", this.Request.Headers["azds-route-as"] as IEnumerable<string>);
				}
				var response = await client.SendAsync(request);
				ViewData["Message"] += " --->  " + await response.Content.ReadAsStringAsync();
			}

		return View();
	}        

        public IActionResult Contact()
        {
            ViewData["Message"] = "Your contact page.";

            return View();
        }

        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
