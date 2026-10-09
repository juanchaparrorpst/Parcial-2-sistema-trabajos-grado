// Menu lateral: colapsar/expandir con el boton hamburguesa.
(function () {
    "use strict";

    function alternarMenu() {
        var barra = document.querySelector(".barra-lateral");
        if (barra) {
            barra.classList.toggle("colapsada");
        }
    }

    document.addEventListener("DOMContentLoaded", function () {
        var boton = document.querySelector(".boton-colapsar");
        if (boton) {
            boton.addEventListener("click", alternarMenu);
        }
    });
})();
