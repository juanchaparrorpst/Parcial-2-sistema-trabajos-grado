// Formulario de alta/edicion de usuario (RF-02, RF-03, RF-04):
//  - Muestra los campos de estudiante o de docente segun el rol elegido.
//  - Obliga a que monografia/practica empresarial sean solo individuales.
//  - Valida que el nombre tenga al menos nombre y apellido.
//  - En modo creacion, calcula el hash de la contrasena inicial (el
//    documento de identidad) en el navegador antes de enviar el formulario.
(function () {
    "use strict";

    var MODALIDADES_SOLO_INDIVIDUAL = ["monografia", "practica"];
    var ROLES_DOCENTE = ["comite", "director", "evaluador"];

    async function sha256Hex(texto) {
        var datos = new TextEncoder().encode(texto);
        var buffer = await crypto.subtle.digest("SHA-256", datos);
        return Array.prototype.map.call(new Uint8Array(buffer), function (b) {
            return b.toString(16).padStart(2, "0");
        }).join("");
    }

    function actualizarBloquesPorRol(rol) {
        var bloqueEstudiante = document.getElementById("camposEstudiante");
        var bloqueDocente = document.getElementById("camposDocente");
        if (!bloqueEstudiante || !bloqueDocente) {
            return;
        }
        bloqueEstudiante.hidden = rol !== "estudiante";
        bloqueDocente.hidden = ROLES_DOCENTE.indexOf(rol) === -1;
    }

    function aplicarRegladModalidadIndividual() {
        var modalidad = document.getElementById("modalidad");
        var opcionIndividual = document.getElementById("opcionIndividual");
        var opcionPareja = document.getElementById("opcionPareja");
        var aviso = document.getElementById("avisoModalidadIndividual");
        if (!modalidad || !opcionIndividual || !opcionPareja) {
            return;
        }

        var soloIndividual = MODALIDADES_SOLO_INDIVIDUAL.indexOf(modalidad.value) !== -1;
        opcionPareja.disabled = soloIndividual;
        if (aviso) {
            aviso.hidden = !soloIndividual;
        }
        if (soloIndividual) {
            opcionIndividual.checked = true;
        }
    }

    function nombreTieneNombreYApellido(nombre) {
        var partes = nombre.trim().split(/\s+/).filter(function (p) { return p.length > 0; });
        return partes.length >= 2;
    }

    document.addEventListener("DOMContentLoaded", function () {
        var selectRol = document.getElementById("rol");
        if (selectRol) {
            // Modo creacion: el select de rol existe y es interactivo.
            selectRol.addEventListener("change", function () {
                actualizarBloquesPorRol(selectRol.value);
            });
            actualizarBloquesPorRol(selectRol.value);
        } else if (typeof ROL_ACTUAL_EDICION !== "undefined" && ROL_ACTUAL_EDICION) {
            // Modo edicion: el rol viene fijo desde la pagina (variable global).
            actualizarBloquesPorRol(ROL_ACTUAL_EDICION);
        }

        var modalidad = document.getElementById("modalidad");
        if (modalidad) {
            modalidad.addEventListener("change", aplicarRegladModalidadIndividual);
            aplicarRegladModalidadIndividual();
        }

        var formulario = document.getElementById("formularioUsuario");
        if (!formulario) {
            return;
        }

        formulario.addEventListener("submit", function (evento) {
            var nombre = document.getElementById("nombreCompleto").value;
            if (!nombreTieneNombreYApellido(nombre)) {
                evento.preventDefault();
                window.alert("El nombre debe tener al menos un nombre y un apellido.");
                return;
            }

            var documentoIdentidad = document.getElementById("documentoIdentidad");
            var claveHashInicial = document.getElementById("claveHashInicial");
            var esCreacion = !!selectRol;

            if (esCreacion && documentoIdentidad && claveHashInicial) {
                evento.preventDefault();
                sha256Hex(documentoIdentidad.value).then(function (hash) {
                    claveHashInicial.value = hash;
                    formulario.submit();
                });
            }
        });
    });
})();
