// RF-29: la agenda de la sesion se puede "exportar o consultar". La
// consulta es la tabla misma; la exportacion arma un CSV en el navegador a
// partir de las dos tablas, sin backend ni .java involucrados.
(function () {
    "use strict";

    function filaACsv(celdas) {
        return celdas.map(function (texto) {
            var limpio = (texto || "").replace(/\s+/g, " ").trim();
            return '"' + limpio.replace(/"/g, '""') + '"';
        }).join(",");
    }

    function tablaACsvFilas(tabla, titulo) {
        var filas = [[titulo]];
        var encabezados = Array.prototype.map.call(tabla.querySelectorAll("thead th"), function (th) {
            return th.textContent;
        });
        filas.push(encabezados);
        tabla.querySelectorAll("tbody tr").forEach(function (fila) {
            var celdas = Array.prototype.map.call(fila.querySelectorAll("td"), function (td) {
                return td.textContent;
            });
            if (celdas.length) {
                filas.push(celdas);
            }
        });
        return filas;
    }

    document.addEventListener("DOMContentLoaded", function () {
        var boton = document.getElementById("botonExportarSesion");
        if (!boton) {
            return;
        }
        boton.addEventListener("click", function () {
            var tablaPropuestas = document.getElementById("tablaPropuestasSesion");
            var tablaPagos = document.getElementById("tablaPagosSesion");
            var filas = [].concat(
                tablaACsvFilas(tablaPropuestas, "Propuestas pendientes"),
                [[]],
                tablaACsvFilas(tablaPagos, "Pagos pendientes de verificar")
            );
            var contenido = filas.map(filaACsv).join("\r\n");
            var blob = new Blob(["﻿" + contenido], { type: "text/csv;charset=utf-8;" });
            var enlace = document.createElement("a");
            enlace.href = URL.createObjectURL(blob);
            enlace.download = "sesion-comite-" + new Date().toISOString().slice(0, 10) + ".csv";
            document.body.appendChild(enlace);
            enlace.click();
            document.body.removeChild(enlace);
        });
    });
})();
