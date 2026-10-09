// Login: calcula el hash SHA-256 de la contraseña en el navegador antes de
// enviar el formulario. El servidor nunca recibe la contraseña en texto
// plano (ver WEB-INF/conexion.jsp y sql/01_esquema.sql, columna
// usuario.contrasena_hash).
(function () {
    "use strict";

    async function sha256Hex(texto) {
        var datos = new TextEncoder().encode(texto);
        var buffer = await crypto.subtle.digest("SHA-256", datos);
        return Array.prototype.map.call(new Uint8Array(buffer), function (b) {
            return b.toString(16).padStart(2, "0");
        }).join("");
    }

    document.addEventListener("DOMContentLoaded", function () {
        var formulario = document.getElementById("formularioLogin");
        if (!formulario) {
            return;
        }

        formulario.addEventListener("submit", function (evento) {
            evento.preventDefault();
            var claveVisible = document.getElementById("claveVisible");
            var claveHash = document.getElementById("claveHash");
            sha256Hex(claveVisible.value).then(function (hash) {
                claveHash.value = hash;
                formulario.submit();
            });
        });
    });
})();
