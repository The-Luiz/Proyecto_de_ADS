//------------------------------------------------------------------------------
// <auto-generated>
//     Este código se generó a partir de una plantilla.
//
//     Los cambios manuales en este archivo pueden causar un comportamiento inesperado de la aplicación.
//     Los cambios manuales en este archivo se sobrescribirán si se regenera el código.
// </auto-generated>
//------------------------------------------------------------------------------

namespace AplicacionWebADS.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Recibos
    {
        public int ReciboID { get; set; }
        public int ClienteID { get; set; }
        public int PedidoID { get; set; }
        public string NombreCliente { get; set; }
        public string CorreoCliente { get; set; }
        public string TelefonoCliente { get; set; }
        public System.DateTime FechaPedido { get; set; }
        public decimal TotalPedido { get; set; }
        public string EstadoPedido { get; set; }
        public string DetallesPedido { get; set; }
    
        public virtual Clientes Clientes { get; set; }
        public virtual Pedidos Pedidos { get; set; }
    }
}
