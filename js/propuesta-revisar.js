// Revisión de propuestas por el comité (RF-11, RF-12, RF-13, RF-16): el
// bloque de nivel/director/evaluador/compañero solo hace falta si la
// decisión es "Aprobada", porque solo ahí se crea el proyecto. Se muestra y
// se vuelve obligatorio con JS; el servidor (procesar-propuesta-estado.jsp)
// vuelve a exigirlo por si se evita este chequeo.
(function () {
    "use strict";

    document.addEventListener("DOMContentLoaded", function () {
        var decision = document.getElementById("decision");
        var bloqueAprobacion = document.getElementById("bloqueAprobacion");
        var nivel = document.getElementById("nivel");
        var directorId = document.getElementById("directorId");
        var evaluadorId = document.getElementById("evaluadorId");
        var companeroId = document.getElementById("companeroId");
        if (!decision || !bloqueAprobacion) {
            return;
        }

        function actualizar() {
            var esAprobada = decision.value === "aprobada";
            bloqueAprobacion.hidden = !esAprobada;
            if (nivel) nivel.required = esAprobada;
            if (directorId) directorId.required = esAprobada;
            if (evaluadorId) evaluadorId.required = esAprobada;
            // LIDER_ES_PAREJA lo fija propuesta-revisar.jsp en un <script> antes de este archivo.
            if (companeroId) companeroId.required = esAprobada && typeof LIDER_ES_PAREJA !== "undefined" && LIDER_ES_PAREJA;
        }

        decision.addEventListener("change", actualizar);
        actualizar();
    });
})();
