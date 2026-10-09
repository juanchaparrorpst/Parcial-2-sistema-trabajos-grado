<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Mi perfil - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="perfil" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Mi <span class="insignia-verde">PERFIL</span></h2>
</div>
<div class="pagina-marcador">
    <p>Esta pantalla mostrará los datos del usuario que inició sesión (nombre, correo, rol, documento de identidad y, según el rol, modalidad o línea de investigación).</p>
    <p>Se conecta al login y a la sesión en el Sprint 1.</p>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
