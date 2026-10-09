// Formularios de revision con un adjunto condicional (director-revisar.jsp,
// evaluador-revisar.jsp): un <select> de decision que, cuando vale
// data-aplazado, muestra y exige el campo de archivo (data-input dentro del
// bloque data-bloque) -- RF-22/RF-24 piden que el documento de observaciones
// o correcciones sea obligatorio solo al aplazar. Tambien genera el nombre
// unico del archivo antes de enviar, igual que subida-archivo-unico.js.
//
// Uso: <script src=".../revision-con-adjunto.js"
//   data-decision="idDelSelect" data-aplazado="valorQueActivaElBloque"
//   data-bloque="idDelBloqueAMostrar" data-input="idDelInputArchivo"
//   data-nombre="idDelCampoOculto"></script>
(function () {
    "use strict";

    var scriptActual = document.currentScript;
    if (!scriptActual) {
        return;
    }
    var idDecision = scriptActual.getAttribute("data-decision");
    var valorAplazado = scriptActual.getAttribute("data-aplazado");
    var idBloque = scriptActual.getAttribute("data-bloque");
    var idInput = scriptActual.getAttribute("data-input");
    var idNombre = scriptActual.getAttribute("data-nombre");

    function extension(nombreArchivo) {
        var m = /\.[^.]+$/.exec(nombreArchivo || "");
        return m ? m[0].toLowerCase() : "";
    }

    function nombreUnico(nombreOriginal) {
        var id = crypto.randomUUID ? crypto.randomUUID() : (Date.now() + "-" + Math.random().toString(16).slice(2));
        return id + extension(nombreOriginal);
    }

    document.addEventListener("DOMContentLoaded", function () {
        var decision = document.getElementById(idDecision);
        var bloque = document.getElementById(idBloque);
        var input = document.getElementById(idInput);
        var campoNombre = document.getElementById(idNombre);
        if (!decision || !bloque || !input) {
            return;
        }

        function actualizar() {
            var requiereAdjunto = decision.value === valorAplazado;
            bloque.hidden = !requiereAdjunto;
            input.required = requiereAdjunto;
        }
        decision.addEventListener("change", actualizar);
        actualizar();

        var formulario = decision.form;
        if (formulario && campoNombre) {
            formulario.addEventListener("submit", function () {
                if (input.files && input.files[0]) {
                    campoNombre.value = nombreUnico(input.files[0].name);
                }
            });
        }
    });
})();
