<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- RF-24: solo el evaluador asignado, solo en fase 3 con el evaluador como responsable. --%>
<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.fase_actual,
           (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = 3 ORDER BY id DESC LIMIT 1) AS responsable,
           (SELECT COUNT(*) FROM asignacion a JOIN docente d ON d.id = a.evaluador_id
                WHERE a.proyecto_id = py.id AND d.usuario_id = ?) AS es_evaluador_sesion
    FROM proyecto py WHERE py.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:if test="${resultadoProyecto.rowCount == 0}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />
<c:if test="${py.es_evaluador_sesion == 0 or py.fase_actual != 3 or py.responsable != 'evaluador'}">
    <jsp:forward page="/proyecto-detalle.jsp?id=${param.proyectoId}" />
</c:if>

<sql:query var="resultadoFormato" dataSource="${applicationScope.dsSistemaTG}">
    SELECT archivo, formato, fecha FROM documento
    WHERE proyecto_id = ? AND tipo = 'F-DC-124' ORDER BY id DESC LIMIT 1
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:set var="formato124" value="${resultadoFormato.rows[0]}" />
<sql:query var="resultadoInforme" dataSource="${applicationScope.dsSistemaTG}">
    SELECT archivo, formato, fecha FROM documento
    WHERE proyecto_id = ? AND tipo = 'informe_similitud' ORDER BY id DESC LIMIT 1
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:set var="informe" value="${resultadoInforme.rows[0]}" />

<c:set var="tituloPagina" value="Revisar propuesta - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="proyectos" scope="request" />
<c:set var="rolesPermitidos" value=",evaluador," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Revisión del <span class="insignia-verde">EVALUADOR</span></h2>
</div>

<c:if test="${param.error == '1'}">
    <p class="mensaje-error">Si apruebas, el formato 125 firmado es obligatorio; si aplazas, el documento de correcciones es obligatorio. Ambos deben ser Word o PDF.</p>
</c:if>

<p class="ayuda" style="margin-bottom:16px;">
    Proyecto ${py.consecutivo}-${py.anio} —
    <a href="${pageContext.request.contextPath}/uploads/${formato124.archivo}" target="_blank">ver formato 124 (${formato124.formato})</a>
    y
    <a href="${pageContext.request.contextPath}/uploads/${informe.archivo}" target="_blank">informe de similitud (${informe.formato})</a>.
</p>

<div class="tabla-contenedor">
    <form method="post" action="${pageContext.request.contextPath}/procesar-evaluador-revisar.jsp" enctype="multipart/form-data" class="formulario-rejilla">
        <input type="hidden" name="proyectoId" value="${py.id}">
        <input type="hidden" name="nombreArchivo" id="nombreArchivo">

        <div class="campo-formulario">
            <label for="decision">Decisión</label>
            <select id="decision" name="decision" required>
                <option value="aprobado">Aprobado</option>
                <option value="aplazado">Aplazado</option>
            </select>
        </div>

        <div id="bloqueAprobado" class="campo-formulario">
            <label for="formato125">Formato 125 firmado (RF-24)</label>
            <input type="file" id="formato125" name="archivo" accept=".docx,application/pdf">
        </div>

        <div id="bloqueAplazado" class="campo-formulario" hidden>
            <label for="correccionesEvaluador">Documento de correcciones</label>
            <input type="file" id="correccionesEvaluador" name="archivoAplazado" accept=".docx,application/pdf">
        </div>

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Registrar decisión</button>
            <a href="${pageContext.request.contextPath}/proyecto-detalle.jsp?id=${py.id}" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/evaluador-revisar.js?v=1"></script>

<jsp:include page="/WEB-INF/cierre.jsp" />
