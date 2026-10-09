<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- RF-21: solo el lider, solo en fase 2 con el estudiante como responsable
     (si ya lo envio y esta esperando al director, no puede modificarlo --
     criterio de aceptacion de RF-21). --%>
<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.fase_actual,
           (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = 2 ORDER BY id DESC LIMIT 1) AS responsable,
           (SELECT COUNT(*) FROM proyecto_integrante pi JOIN estudiante e ON e.id = pi.estudiante_id
                WHERE pi.proyecto_id = py.id AND e.usuario_id = ? AND pi.es_lider = TRUE) AS es_lider_sesion,
           (SELECT COUNT(*) FROM documento WHERE proyecto_id = py.id AND tipo = 'F-DC-124') AS num_envios
    FROM proyecto py WHERE py.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:if test="${resultadoProyecto.rowCount == 0}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />
<c:if test="${py.es_lider_sesion == 0 or py.fase_actual != 2 or py.responsable != 'estudiante'}">
    <jsp:forward page="/proyecto-detalle.jsp?id=${param.proyectoId}" />
</c:if>

<c:set var="tituloPagina" value="Formato 124 - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="proyectos" scope="request" />
<c:set var="rolesPermitidos" value=",estudiante," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Formato <span class="insignia-verde">124</span></h2>
</div>

<c:if test="${param.error == '1'}">
    <p class="mensaje-error">El formato 124 es obligatorio y debe ser un archivo Word (.docx) o PDF.</p>
</c:if>

<p class="ayuda" style="margin-bottom:16px;">
    Proyecto ${py.consecutivo}-${py.anio}.
    <c:if test="${py.num_envios > 0}"> Esta será la revisión ${py.num_envios + 1}.</c:if>
</p>

<div class="tabla-contenedor">
    <form id="formularioFormato124" method="post" action="${pageContext.request.contextPath}/procesar-formato124.jsp" enctype="multipart/form-data" class="formulario-rejilla">
        <input type="hidden" name="proyectoId" value="${py.id}">
        <input type="hidden" name="nombreArchivo" id="nombreArchivo">

        <div class="campo-formulario">
            <label for="formato124">Formato F-DC-124 (Word o PDF)</label>
            <input type="file" id="formato124" name="formato124" accept=".docx,application/pdf" required>
        </div>

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Enviar al director</button>
            <a href="${pageContext.request.contextPath}/proyecto-detalle.jsp?id=${py.id}" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/subida-archivo-unico.js?v=1" data-input="formato124" data-nombre="nombreArchivo"></script>

<jsp:include page="/WEB-INF/cierre.jsp" />
