// Función para agregar al carrito con AJAX
function agregarAlCarrito(productoId) {
    var token = $('input[name="__RequestVerificationToken"]').val(); // Obtén el token
    $.post('@Url.Action("AgregarAlCarrito", "Carrito")', { productoId: productoId })
        .done(function (data) {
            if (data.success) {
                alert('Producto agregado al carrito');
            } else {
                alert(data.message);
            }
        })
        .fail(function () {
            alert('Error al agregar el producto al carrito');
        });
}

function toggleMenu() {
    const sideMenu = document.getElementById('sideMenu');
    const overlay = document.getElementById('overlay');

    if (sideMenu.style.left === '0px' || sideMenu.style.left === '') {
        sideMenu.style.left = '-250px';
        overlay.style.display = 'none';
        document.body.removeEventListener('click', closeOnClickOutside);
    } else {
        sideMenu.style.left = '0px';
        overlay.style.display = 'block';
        setTimeout(() => {
            document.body.addEventListener('click', closeOnClickOutside);
        }, 10);
    }
}

function closeOnClickOutside(event) {
    const sideMenu = document.getElementById('sideMenu');
    const menuIcon = document.querySelector('.menu-icon');
  //  const overlay = document.getElementById('overlay');

    if (!sideMenu.contains(event.target) && !menuIcon.contains(event.target)) {
        /*sideMenu.style.left = '-250px';
        overlay.style.display = 'none';
        document.body.removeEventListener('click', closeOnClickOutside);*/
        toggleMenu();
    }
}
function toggleSearch() {
    const searchBox = document.getElementById('searchBox');
    searchBox.classList.toggle('visible');

    if (searchBox.classList.contains('visible')) {
        searchBox.focus();
    }
}

function buscarProducto() {
    const valor = document.getElementById('searchBox').value.toLowerCase();
    const productos = document.querySelectorAll('.Producto1');

    productos.forEach(producto => {
        const nombre = producto.querySelector('h3').textContent.toLowerCase();
        producto.style.display = nombre.includes(valor) ? 'block' : 'none';
    });
}
// ========== INICIALIZACIÓN ==========
document.addEventListener('DOMContentLoaded', function () {
    loadMenu();
});


// ========== FUNCIONES PRINCIPALES ==========

function showpage(pageId) {

    toggleMenu();

    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    document.getElementById(pageId).classList.add('active');
}

function logout() {
    document.body.setAttribute('data-role', 'user');
    loadMenu();
    alert('Sesión de administrador cerrada');
}

// ========== SISTEMA DE LOGIN ==========
document.getElementById('userIcon').addEventListener('click', function () {
    document.getElementById('loginModal').style.display = 'block';
});

document.querySelector('.close-modal').addEventListener('click', function () {
    document.getElementById('loginModal').style.display = 'none';
});

document.getElementById('loginForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const loginError = document.getElementById('loginError');

    if (validCredentials[username] && validCredentials[username] === password) {
        document.getElementById('loginModal').style.display = 'none';
        document.body.setAttribute('data-role', 'admin');
        loadMenu();
        alert('Bienvenido, ' + username);
        loginError.textContent = '';
    } else {
        loginError.textContent = 'Credenciales incorrectas';
    }
});

//===alternar entre los formularios de inicio de sesión y registro===

document.getElementById('toggleForm').addEventListener('click', function (e) {
    e.preventDefault();
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');
    const modalTitle = document.getElementById('modalTitle');

    if (loginForm.style.display === 'none') {
        loginForm.style.display = 'block';
        registerForm.style.display = 'none';
        this.textContent = '¿No tienes una cuenta? Regístrate aquí.';
    } else {
        loginForm.style.display = 'none';
        registerForm.style.display = 'block';
        this.textContent = '¿Ya tienes una cuenta? Inicia sesión aquí.';
    }
});

//===Manejo registro de usuarios nuevos===
document.getElementById('registerForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const newUsername = document.getElementById('newUsername').value;
    const newPassword = document.getElementById('newPassword').value;
    const registerError = document.getElementById('registerError');

    if (users[newUsername]) {
        registerError.textContent = 'El usuario ya existe';
    } else {
        users[newUsername] = newPassword;
        alert('Registro exitoso. Ahora puedes iniciar sesión.');
        document.getElementById('toggleForm').click(); // Cambia al formulario de inicio de sesión
        document.getElementById('registerForm').reset();
    }
});
// Función para el carrito (usando AJAX)
function agregarAlCarrito(productoId) {
    fetch('/Productos/AgregarAlCarrito', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ productoId: productoId })
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert("¡Producto agregado!");
            }
        });
}

// Menú dinámico según rol
function loadMenu() {
    fetch('/Account/GetUserRole')
        .then(response => response.json())
        .then(data => {
            const role = data.role || 'user';
            document.body.setAttribute('data-role', role);
        });
}

document.addEventListener('DOMContentLoaded', loadMenu);

document.addEventListener('DOMContentLoaded', function () {
    var authModal = document.getElementById('authModal');
    if (authModal) {
        if (typeof bootstrap !== 'undefined') {
            var modal = bootstrap.Modal.getInstance(authModal);
            if (modal) {
                modal.hide();
            }
        } else {
            authModal.style.display = 'none';
        }
    }
});