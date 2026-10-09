// Revision del evaluador (RF-24): segun la decision, se exige un archivo
// distinto -- formato 125 firmado si aprueba, documento de correcciones si
// aplaza -- pero solo uno de los dos se envia, asi que comparten el mismo
// campo oculto de nombre unico (nombreArchivo).
(function () {
    "use strict";

    document.addEventListener("DOMContentLoaded", function () {
        var decision = document.getElementById("decision");
        var bloqueAprobado = document.getElementById("bloqueAprobado");
        var bloqueAplazado = document.getElementById("bloqueAplazado");
        var inputAprobado = document.getElementById("formato125");
        var inputAplazado = document.getElementById("correccionesEvaluador");
        var campoNombre = document.getElementById("nombreArchivo");
        var formulario = decision ? decision.form : null;
        if (!decision || !formulario) {
            return;
        }

        function actualizar() {
            var aprobado = decision.value === "aprobado";
            bloqueAprobado.hidden = !aprobado;
            bloqueAplazado.hidden = aprobado;
            inputAprobado.required = aprobado;
            inputAplazado.required = !aprobado;
        }
        decision.addEventListener("change", actualizar);
        actualizar();

        function extension(nombreArchivo) {
            var m = /\.[^.]+$/.exec(nombreArchivo || "");
            return m ? m[0].toLowerCase() : "";
        }
        function nombreUnico(nombreOriginal) {
            var id = crypto.randomUUID ? crypto.randomUUID() : (Date.now() + "-" + Math.random().toString(16).slice(2));
            return id + extension(nombreOriginal);
        }

        formulario.addEventListener("submit", function () {
            var activo = decision.value === "aprobado" ? inputAprobado : inputAplazado;
            if (activo.files && activo.files[0]) {
                campoNombre.value = nombreUnico(activo.files[0].name);
            }
        });
    });
})();
