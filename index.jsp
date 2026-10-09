<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Inicio - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="inicio" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>SISTEMA - TRABAJOS DE <span class="insignia-verde">GRADO</span></h2>
</div>
<p>Bienvenido al portal de trabajos de grado. Aquí podrás acceder a:</p>

<div class="tarjetas-inicio">
    <a class="tarjeta-acceso" href="${pageContext.request.contextPath}/banco-ideas.jsp">
        <span class="tarjeta-icono">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5C5.5 4.6 7.3 4.2 9 4.5c1 .2 2 .6 3 1.2V19c-1-.6-2-1-3-1.2-1.7-.3-3.5.1-5 1V5.5Z"/><path d="M20 5.5c-1.5-.9-3.3-1.3-5-1-1 .2-2 .6-3 1.2V19c1-.6 2-1 3-1.2 1.7-.3 3.5.1 5 1V5.5Z"/></svg>
        </span>
        <h3>Banco de ideas</h3>
        <p>Accede al banco de ideas del periodo actual propuesto por los docentes.</p>
    </a>

    <a class="tarjeta-acceso" href="${pageContext.request.contextPath}/propuestas-banco.jsp">
        <span class="tarjeta-icono">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M5 20V6a2 2 0 0 1 2-2h7l5 5v11a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2Z"/><path d="M14 4v5h5"/><path d="M8.5 13h7M8.5 16.5h5"/></svg>
        </span>
        <h3>Propuestas Banco</h3>
        <p>Propone tu idea de proyecto o consulta el estado de tu propuesta.</p>
    </a>

    <a class="tarjeta-acceso" href="${pageContext.request.contextPath}/base-documental.jsp">
        <span class="tarjeta-icono">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3.5 7.5 6 5h5l2 2.5h7.5v10a1.5 1.5 0 0 1-1.5 1.5H5a1.5 1.5 0 0 1-1.5-1.5v-10Z"/></svg>
        </span>
        <h3>Base Documental</h3>
        <p>Accede a los formatos institucionales y a toda la información documental.</p>
    </a>

    <a class="tarjeta-acceso" href="${pageContext.request.contextPath}/calendario-academico.jsp">
        <span class="tarjeta-icono">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="5.5" width="16" height="14.5" rx="1.8"/><path d="M4 10h16M8 3.5v3.5M16 3.5v3.5"/></svg>
        </span>
        <h3>Calendario Académico</h3>
        <p>Consulta las fechas importantes y los periodos habilitados del proceso.</p>
    </a>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
