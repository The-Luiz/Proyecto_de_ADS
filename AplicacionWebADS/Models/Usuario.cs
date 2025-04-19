using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace AplicacionWebADS.Models
{
	public class Usuario
	{
		public int UsuarioID { get; set; }
		[Required(ErrorMessage ="El nombre es obligatorio")]
		public string Nombre { get; set; }
        [Required(ErrorMessage = "El correo es obligatorio")]
        [EmailAddress(ErrorMessage = "Correo electrónico no válido")]
        public string Correo { get; set; }
        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [DataType(DataType.Password)]
        public string Contraseña { get; set; }
        public string Rol { get; set; } // Admin, VIP, Proveedores, Cliente
    }
}