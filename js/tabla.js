// Tabla reutilizable: buscador + "Mostrar N registros por pagina" + paginacion.
// Funciona sobre cualquier bloque .tabla-contenedor que tenga dentro una
// .tabla-datos con <tbody><tr>...</tr></tbody>. Es solo filtrado/paginado en
// el navegador (los datos de ejemplo de esta pantalla son fijos); cuando las
// paginas se conecten a la base de datos, esto se puede adaptar a paginacion
// del lado del servidor sin cambiar el marcado.
(function () {
    "use strict";

    function inicializarTabla(contenedor) {
        var selectPagina = contenedor.querySelector(".tabla-select-pagina");
        var inputBuscar = contenedor.querySelector(".tabla-input-buscar");
        var tabla = contenedor.querySelector(".tabla-datos");
        var filas = tabla ? Array.prototype.slice.call(tabla.querySelectorAll("tbody tr")) : [];
        var infoEl = contenedor.querySelector(".tabla-paginacion-info");
        var numerosEl = contenedor.querySelector(".pag-numeros");
        var sinResultados = contenedor.querySelector(".tabla-sin-resultados");
        var botonPrimera = contenedor.querySelector(".pag-primera");
        var botonAnterior = contenedor.querySelector(".pag-anterior");
        var botonSiguiente = contenedor.querySelector(".pag-siguiente");
        var botonUltima = contenedor.querySelector(".pag-ultima");

        var paginaActual = 1;

        function filasVisiblesPorBusqueda() {
            var termino = inputBuscar ? inputBuscar.value.trim().toLowerCase() : "";
            return filas.filter(function (fila) {
                var coincide = termino === "" || fila.textContent.toLowerCase().indexOf(termino) !== -1;
                fila.classList.toggle("fila-oculta", !coincide);
                return coincide;
            });
        }

        function render() {
            var coincidentes = filasVisiblesPorBusqueda();
            var porPagina = selectPagina ? parseInt(selectPagina.value, 10) : coincidentes.length || 1;
            if (!porPagina || porPagina < 1) {
                porPagina = coincidentes.length || 1;
            }

            var totalPaginas = Math.max(1, Math.ceil(coincidentes.length / porPagina));
            if (paginaActual > totalPaginas) {
                paginaActual = totalPaginas;
            }

            // Oculta todas las filas que coinciden con la busqueda y vuelve a
            // mostrar solo las de la pagina actual.
            coincidentes.forEach(function (fila, indice) {
                var inicio = (paginaActual - 1) * porPagina;
                var fin = inicio + porPagina;
                fila.classList.toggle("fila-oculta", indice < inicio || indice >= fin);
            });

            if (sinResultados) {
                sinResultados.classList.toggle("visible", coincidentes.length === 0);
            }
            if (tabla) {
                tabla.style.display = coincidentes.length === 0 ? "none" : "";
            }

            if (infoEl) {
                infoEl.textContent = coincidentes.length === 0
                    ? "Sin resultados"
                    : "Mostrando la pagina " + paginaActual + " de " + totalPaginas;
            }

            if (botonPrimera) botonPrimera.disabled = paginaActual === 1;
            if (botonAnterior) botonAnterior.disabled = paginaActual === 1;
            if (botonSiguiente) botonSiguiente.disabled = paginaActual === totalPaginas;
            if (botonUltima) botonUltima.disabled = paginaActual === totalPaginas;

            if (numerosEl) {
                numerosEl.innerHTML = "";
                for (var n = 1; n <= totalPaginas; n++) {
                    (function (numeroPagina) {
                        var boton = document.createElement("button");
                        boton.type = "button";
                        boton.className = "pag-numero" + (numeroPagina === paginaActual ? " activo" : "");
                        boton.textContent = String(numeroPagina);
                        boton.addEventListener("click", function () {
                            paginaActual = numeroPagina;
                            render();
                        });
                        numerosEl.appendChild(boton);
                    })(n);
                }
            }
        }

        if (selectPagina) {
            selectPagina.addEventListener("change", function () {
                paginaActual = 1;
                render();
            });
        }
        if (inputBuscar) {
            inputBuscar.addEventListener("input", function () {
                paginaActual = 1;
                render();
            });
        }
        if (botonPrimera) botonPrimera.addEventListener("click", function () { paginaActual = 1; render(); });
        if (botonAnterior) botonAnterior.addEventListener("click", function () { paginaActual--; render(); });
        if (botonSiguiente) botonSiguiente.addEventListener("click", function () { paginaActual++; render(); });
        if (botonUltima) botonUltima.addEventListener("click", function () {
            paginaActual = Number.MAX_SAFE_INTEGER;
            render();
        });

        render();
    }

    document.addEventListener("DOMContentLoaded", function () {
        document.querySelectorAll(".tabla-contenedor").forEach(inicializarTabla);
    });
})();
