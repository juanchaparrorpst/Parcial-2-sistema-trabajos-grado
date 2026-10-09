<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Abre el bloque de una tabla reutilizable (toolbar con "Mostrar N
    registros por pagina" + buscador). La pagina que lo use debe escribir su
    propia <table class="tabla-datos"> con <thead>/<tbody> justo despues de
    este include, y cerrar el bloque con /WEB-INF/tabla-fin.jsp.

    Cada fila <tr> de la tabla puede traer un boton con clase "boton-ver" y
    atributos data-titulo-modal / data-etq-N / data-val-N para abrir el
    modal de detalle reutilizable con los datos de esa fila (ver
    WEB-INF/modal-detalle.jsp y js/modal.js).

    La busqueda y la paginacion las maneja js/tabla.js en el navegador.
--%>
<div class="tabla-contenedor">
    <div class="tabla-toolbar">
        <label class="tabla-mostrar">
            Mostrar
            <select class="tabla-select-pagina">
                <option value="5">5</option>
                <option value="10" selected>10</option>
                <option value="20">20</option>
            </select>
            registros por página
        </label>
        <label class="tabla-buscar">
            Buscar:
            <input type="text" class="tabla-input-buscar" placeholder="Ingrese una clave">
        </label>
    </div>
