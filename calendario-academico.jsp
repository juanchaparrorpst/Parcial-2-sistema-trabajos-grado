<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Calendario academico - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="calendario" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Calendario <span class="insignia-verde">ACADÉMICO</span></h2>
</div>
<div class="pagina-marcador">
    <p>Esta pantalla mostrará los periodos académicos (tabla "periodo"): cuándo está habilitado el banco de ideas, las propuestas y los pagos.</p>
    <p>Se conecta a la base de datos en el Sprint 2.</p>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
