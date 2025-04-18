using AplicacionWebADS.Models;
using System.Linq;
using System.Web.Mvc;

namespace AplicacionWebADS.Controllers
{
    public class AccesoController : Controller
    {
        private MyIphonesvEntities db = new MyIphonesvEntities();

        // GET: Acceso/Login
        [HttpGet]
        public ActionResult Login()
        {
            return View();
        }

        // POST: Acceso/Login
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(string correo, string contraseña)
        {
            if (string.IsNullOrWhiteSpace(correo) || string.IsNullOrWhiteSpace(contraseña))
            {
                ViewBag.Mensaje = "Correo y contraseña son obligatorios";
                return View();
            }

            var resultado = db.LoginUsuario(correo, contraseña).FirstOrDefault();

            if (resultado != null && resultado.UsuarioID > 0)
            {
                Session["UsuarioID"] = resultado.UsuarioID;
                Session["Nombre"] = resultado.Nombre;
                Session["Rol"] = resultado.Rol;

                return RedirectToAction("Index", "Home");
            }

            ViewBag.Mensaje = "Usuario o contraseña incorrectos";
            return View();
        }

        // GET: Acceso/Registrar
        [HttpGet]
        public ActionResult Registrar()
        {
            return View();
        }

        // POST: Acceso/Registrar
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Registrar(string nombre, string correo, string contraseña, string rol = "Nuevo")
        {
            if (string.IsNullOrWhiteSpace(nombre) ||
              string.IsNullOrWhiteSpace(correo) ||
              string.IsNullOrWhiteSpace(contraseña))
            {
                ViewBag.Mensaje = "Todos los campos son obligatorios";
                return View();
            }

            var msgResult = db.CrearUsuario(nombre, correo, contraseña).FirstOrDefault();

            ViewBag.Mensaje = msgResult;
            if (msgResult == "Cuenta creada exitosamente")
                return RedirectToAction("Login");

            return View();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }
}