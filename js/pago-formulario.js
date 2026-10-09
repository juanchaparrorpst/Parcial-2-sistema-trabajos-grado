// Carga del soporte de pago (RF-15, RNF-11):
//  - Cada archivo se sube con un nombre unico e impredecible generado aqui
//    (crypto.randomUUID), no con su nombre original, para que no se pisen
//    entre si y nadie pueda adivinar la URL de un archivo ajeno (ver
//    SEGUIMIENTO_PROYECTO.md, decision de carga de archivos).
//  - A la liquidacion se le agrega una marca de agua ANTES de subirla, en el
//    navegador, con la libreria pdf-lib (sin backend ni .java involucrados).
//    El archivo ya marcado reemplaza al original en el mismo <input> con un
//    DataTransfer, asi el <form> lo sube con multipart/form-data normal.
//  - Este mismo archivo sirve para el formulario completo (liquidacion +
//    soporte propio [+ soporte del companero]) y para el formulario reducido
//    de "completar" un pago incompleto (CP-04: solo falta el soporte del
//    companero, sin liquidacion ni marca de agua de por medio).
(function () {
    "use strict";

    function esPdf(archivo) {
        return !!archivo && /\.pdf$/i.test(archivo.name);
    }

    function nombreUnico() {
        return (crypto.randomUUID ? crypto.randomUUID() : Date.now() + "-" + Math.random().toString(16).slice(2)) + ".pdf";
    }

    async function marcarAgua(archivo) {
        var bytes = await archivo.arrayBuffer();
        var doc = await PDFLib.PDFDocument.load(bytes);
        var paginas = doc.getPages();
        paginas.forEach(function (pagina) {
            var ancho = pagina.getWidth();
            var alto = pagina.getHeight();
            pagina.drawText("UTS - Sistema de Gestion de Trabajos de Grado - copia de liquidacion", {
                x: ancho * 0.08,
                y: alto / 2,
                size: 16,
                rotate: PDFLib.degrees(45),
                opacity: 0.25,
                color: PDFLib.rgb(0.2, 0.2, 0.2)
            });
        });
        var bytesMarcados = await doc.save();
        return new File([bytesMarcados], archivo.name, { type: "application/pdf" });
    }

    function reemplazarArchivoEnInput(input, archivo) {
        var transferencia = new DataTransfer();
        transferencia.items.add(archivo);
        input.files = transferencia.files;
    }

    document.addEventListener("DOMContentLoaded", function () {
        var formulario = document.getElementById("formularioPago");
        if (!formulario) {
            return;
        }

        var inputLiquidacion = document.getElementById("liquidacion");
        var inputSoportePropio = document.getElementById("soportePropio");
        var inputSoporteCompanero = document.getElementById("soporteCompanero");
        var estadoCarga = document.getElementById("estadoCarga");
        var botonEnviar = document.getElementById("botonEnviarPago");

        var modoCompletar = !inputLiquidacion;

        formulario.addEventListener("submit", function (evento) {
            var soporteCompanero = inputSoporteCompanero ? inputSoporteCompanero.files[0] : null;

            if (modoCompletar) {
                if (!esPdf(soporteCompanero)) {
                    evento.preventDefault();
                    window.alert("El soporte debe ser un archivo PDF.");
                    return;
                }
                document.getElementById("nombreSoporteCompanero").value = nombreUnico();
                return; // envio normal, sin marca de agua.
            }

            var liquidacion = inputLiquidacion.files[0];
            var soportePropio = inputSoportePropio.files[0];

            if (!esPdf(liquidacion) || !esPdf(soportePropio) || (soporteCompanero && !esPdf(soporteCompanero))) {
                evento.preventDefault();
                window.alert("Todos los archivos deben ser PDF.");
                return;
            }

            evento.preventDefault();
            botonEnviar.disabled = true;
            if (estadoCarga) {
                estadoCarga.hidden = false;
            }

            document.getElementById("nombreLiquidacion").value = nombreUnico();
            document.getElementById("nombreSoportePropio").value = nombreUnico();
            if (soporteCompanero) {
                document.getElementById("nombreSoporteCompanero").value = nombreUnico();
            }

            marcarAgua(liquidacion).then(function (archivoMarcado) {
                reemplazarArchivoEnInput(inputLiquidacion, archivoMarcado);
                formulario.submit();
            }).catch(function (error) {
                window.alert("No se pudo aplicar la marca de agua a la liquidación: " + error.message);
                botonEnviar.disabled = false;
                if (estadoCarga) {
                    estadoCarga.hidden = true;
                }
            });
        });
    });
})();
