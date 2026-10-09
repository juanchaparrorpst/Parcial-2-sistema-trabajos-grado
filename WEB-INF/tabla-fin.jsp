<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Cierra el bloque abierto por /WEB-INF/tabla-inicio.jsp: mensaje de "sin
    resultados" (lo activa js/tabla.js cuando el buscador no encuentra
    nada) y la barra de paginacion.
--%>
    <p class="tabla-sin-resultados">No se encontraron registros con ese criterio de búsqueda.</p>

    <div class="tabla-paginacion">
        <span class="tabla-paginacion-info">Mostrando la página 1 de 1</span>
        <div class="tabla-paginacion-botones">
            <button type="button" class="pag-primera" title="Primera página">&laquo;</button>
            <button type="button" class="pag-anterior" title="Página anterior">&lsaquo;</button>
            <span class="pag-numeros"></span>
            <button type="button" class="pag-siguiente" title="Página siguiente">&rsaquo;</button>
            <button type="button" class="pag-ultima" title="Última página">&raquo;</button>
        </div>
    </div>
</div>
