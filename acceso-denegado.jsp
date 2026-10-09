<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Acceso denegado - Sistema de Gestion de Trabajos de Grado" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Acceso <span class="insignia-verde">DENEGADO</span></h2>
</div>
<div class="pagina-marcador">
    <p>Tu rol (<c:out value="${sessionScope.usuarioRol}" />) no tiene permiso para ver esta pantalla.</p>
    <p>Si crees que esto es un error, comunícate con el administrador del sistema.</p>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
