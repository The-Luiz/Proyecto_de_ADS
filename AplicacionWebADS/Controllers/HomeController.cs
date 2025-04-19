using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.Entity;
using AplicacionWebADS.Models;



namespace AplicacionWebADS.Controllers
{
    public class HomeController : Controller
    {
        private MyIphone2Entities1 db = new MyIphone2Entities1();

        public ActionResult Index()
        {
            var productos = db.Productos.ToList(); // Fetch products from the database  
            return View(productos);
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}