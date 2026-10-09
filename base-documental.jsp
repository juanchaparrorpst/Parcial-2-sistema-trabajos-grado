<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Base documental - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="base-documental" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Base <span class="insignia-verde">DOCUMENTAL</span></h2>
</div>
<div class="pagina-marcador">
    <p>Esta pantalla reunirá los formatos institucionales (F-DC-124, F-DC-125) y los documentos cargados por proyecto: liquidación, informe de similitud, correcciones y documentos de fase 4.</p>
    <p>Usará la misma tabla reutilizable de esta pantalla base. Se implementa en el Sprint 4/5.</p>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
