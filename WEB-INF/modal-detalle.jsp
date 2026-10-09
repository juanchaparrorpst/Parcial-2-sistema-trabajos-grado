<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Modal de detalle reutilizable (una sola instancia por pagina). Un boton
    con clase "boton-ver" y atributos data-titulo-modal / data-etq-N /
    data-val-N (ver WEB-INF/tabla-inicio.jsp) lo abre con esos campos;
    la logica esta en js/modal.js.
--%>
<div id="modalDetalle" class="modal-superposicion oculto">
    <div class="modal-panel" role="dialog" aria-modal="true">
        <button type="button" class="modal-cerrar" aria-label="Cerrar">&times;</button>
        <h2 id="modalDetalleTitulo">Detalle</h2>
        <dl id="modalDetalleContenido" class="modal-campos"></dl>
    </div>
</div>
