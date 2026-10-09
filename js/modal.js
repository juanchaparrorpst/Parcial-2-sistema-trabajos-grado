// Modal de detalle reutilizable. Cualquier boton con la clase "boton-ver" y
// atributos data-titulo-modal / data-etq-N / data-val-N abre el modal con
// esos campos. Se usa en varias pantallas (banco de ideas, propuestas, etc).
(function () {
    "use strict";

    function abrirModalDesdeBoton(boton) {
        var modal = document.getElementById("modalDetalle");
        var tituloEl = document.getElementById("modalDetalleTitulo");
        var contenedor = document.getElementById("modalDetalleContenido");
        if (!modal || !tituloEl || !contenedor) {
            return;
        }

        tituloEl.textContent = boton.getAttribute("data-titulo-modal") || "Detalle";
        contenedor.innerHTML = "";

        var indice = 1;
        while (boton.hasAttribute("data-etq-" + indice)) {
            var etiqueta = boton.getAttribute("data-etq-" + indice);
            var valor = boton.getAttribute("data-val-" + indice);

            var dt = document.createElement("dt");
            dt.textContent = etiqueta;
            var dd = document.createElement("dd");
            dd.textContent = valor;

            contenedor.appendChild(dt);
            contenedor.appendChild(dd);
            indice++;
        }

        modal.classList.remove("oculto");
    }

    function cerrarModal() {
        var modal = document.getElementById("modalDetalle");
        if (modal) {
            modal.classList.add("oculto");
        }
    }

    document.addEventListener("DOMContentLoaded", function () {
        document.querySelectorAll(".boton-ver").forEach(function (boton) {
            boton.addEventListener("click", function () {
                abrirModalDesdeBoton(boton);
            });
        });

        var modal = document.getElementById("modalDetalle");
        if (!modal) {
            return;
        }

        var botonCerrar = modal.querySelector(".modal-cerrar");
        if (botonCerrar) {
            botonCerrar.addEventListener("click", cerrarModal);
        }

        modal.addEventListener("click", function (evento) {
            if (evento.target === modal) {
                cerrarModal();
            }
        });

        document.addEventListener("keydown", function (evento) {
            if (evento.key === "Escape") {
                cerrarModal();
            }
        });
    });
})();
