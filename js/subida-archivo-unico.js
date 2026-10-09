// Generador de nombre unico para formularios de carga de un solo archivo
// (o varios, cada uno con su propio input + campo oculto), reutilizado por
// formato124-formulario.jsp, turnitin-formulario.jsp, evaluador-revisar.jsp,
// director-revisar.jsp y documentos-fase4.jsp. Mismo mecanismo que
// js/pago-formulario.js, sin la marca de agua: nombre impredecible generado
// en el navegador con crypto.randomUUID(), conserva la extension real del
// archivo para que coincida con RNF-11 (.docx o .pdf).
//
// Uso: <script src=".../subida-archivo-unico.js" data-input="idDelInput"
//      data-nombre="idDelCampoOculto"></script>
// Para varios pares en la misma pagina, agregar un <script> por cada par
// (cada <script> trae su propio data-input/data-nombre).
(function () {
    "use strict";

    var scriptActual = document.currentScript;
    if (!scriptActual) {
        return;
    }
    var idInput = scriptActual.getAttribute("data-input");
    var idNombre = scriptActual.getAttribute("data-nombre");
    if (!idInput || !idNombre) {
        return;
    }

    function extension(nombreArchivo) {
        var m = /\.[^.]+$/.exec(nombreArchivo || "");
        return m ? m[0].toLowerCase() : "";
    }

    function nombreUnico(nombreOriginal) {
        var id = crypto.randomUUID ? crypto.randomUUID() : (Date.now() + "-" + Math.random().toString(16).slice(2));
        return id + extension(nombreOriginal);
    }

    document.addEventListener("DOMContentLoaded", function () {
        var input = document.getElementById(idInput);
        var campoNombre = document.getElementById(idNombre);
        if (!input || !campoNombre) {
            return;
        }
        var formulario = input.form;
        if (!formulario) {
            return;
        }
        formulario.addEventListener("submit", function () {
            if (input.files && input.files[0]) {
                campoNombre.value = nombreUnico(input.files[0].name);
            }
        });
    });
})();
