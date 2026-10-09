<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- RF-22: solo el director asignado, solo en fase 2 con el director como responsable. --%>
<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.fase_actual,
           (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = 2 ORDER BY id DESC LIMIT 1) AS responsable,
           (SELECT COUNT(*) FROM asignacion a JOIN docente d ON d.id = a.director_id
                WHERE a.proyecto_id = py.id AND d.usuario_id = ?) AS es_director_sesion
    FROM proyecto py WHERE py.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:if test="${resultadoProyecto.rowCount == 0}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />
<c:if test="${py.es_director_sesion == 0 or py.fase_actual != 2 or py.responsable != 'director'}">
    <jsp:forward page="/proyecto-detalle.jsp?id=${param.proyectoId}" />
</c:if>

<%-- El ultimo formato 124 que subio el estudiante, para revisar. La fecha se
     formatea en el propio SQL (DATE_FORMAT) en vez de con <fmt:formatDate>:
     el driver de MySQL devuelve las columnas DATETIME como
     java.time.LocalDateTime, que <fmt:formatDate> no puede convertir (a
     diferencia de las columnas DATE, que si llegan como java.sql.Date). --%>
<sql:query var="resultadoFormato" dataSource="${applicationScope.dsSistemaTG}">
    SELECT archivo, formato, DATE_FORMAT(fecha, '%d/%m/%Y %H:%i') AS fecha_formateada FROM documento
    WHERE proyecto_id = ? AND tipo = 'F-DC-124' ORDER BY id DESC LIMIT 1
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:set var="formato124" value="${resultadoFormato.rows[0]}" />

<c:set var="tituloPagina" value="Revisar formato 124 - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="proyectos" scope="request" />
<c:set var="rolesPermitidos" value=",director," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Revisar formato <span class="insignia-verde">124</span></h2>
</div>

<c:if test="${param.error == '1'}">
    <p class="mensaje-error">Si aplazas, el documento de observaciones es obligatorio (Word o PDF).</p>
</c:if>

<p class="ayuda" style="margin-bottom:16px;">
    Proyecto ${py.consecutivo}-${py.anio} —
    <a href="${pageContext.request.contextPath}/uploads/${formato124.archivo}" target="_blank">ver formato 124 (${formato124.formato})</a>,
    subido el <c:out value="${formato124.fecha_formateada}" />.
</p>

<div class="tabla-contenedor">
    <form id="formularioDirector" method="post" action="${pageContext.request.contextPath}/procesar-director-revisar.jsp" enctype="multipart/form-data" class="formulario-rejilla">
        <input type="hidden" name="proyectoId" value="${py.id}">
        <input type="hidden" name="nombreObservaciones" id="nombreObservaciones">

        <div class="campo-formulario">
            <label for="decision">Decisión</label>
            <select id="decision" name="decision" required>
                <option value="aprobado">Aprobado</option>
                <option value="aplazado">Aplazado</option>
            </select>
        </div>

        <div id="bloqueObservaciones" class="campo-formulario" hidden>
            <label for="observaciones">Documento de observaciones (Word o PDF)</label>
            <input type="file" id="observaciones" name="observaciones" accept=".docx,application/pdf">
        </div>

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Registrar decisión</button>
            <a href="${pageContext.request.contextPath}/proyecto-detalle.jsp?id=${py.id}" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/revision-con-adjunto.js?v=1"
    data-input="observaciones" data-nombre="nombreObservaciones"
    data-decision="decision" data-aplazado="aplazado" data-bloque="bloqueObservaciones"></script>

<jsp:include page="/WEB-INF/cierre.jsp" />
