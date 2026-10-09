<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- RF-23: solo el director asignado, solo en fase 3 con el director como responsable. --%>
<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.fase_actual,
           (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = 3 ORDER BY id DESC LIMIT 1) AS responsable,
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
<c:if test="${py.es_director_sesion == 0 or py.fase_actual != 3 or py.responsable != 'director'}">
    <jsp:forward page="/proyecto-detalle.jsp?id=${param.proyectoId}" />
</c:if>

<c:set var="tituloPagina" value="Informe de similitud - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="proyectos" scope="request" />
<c:set var="rolesPermitidos" value=",director," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Informe de <span class="insignia-verde">SIMILITUD</span></h2>
</div>

<c:if test="${param.error == '1'}">
    <p class="mensaje-error">El informe de similitud es obligatorio y debe ser Word o PDF.</p>
</c:if>

<p class="ayuda" style="margin-bottom:16px;">
    Proyecto ${py.consecutivo}-${py.anio}. El envío al evaluador no se habilita sin este informe (RF-23).
</p>

<div class="tabla-contenedor">
    <form method="post" action="${pageContext.request.contextPath}/procesar-turnitin.jsp" enctype="multipart/form-data" class="formulario-rejilla">
        <input type="hidden" name="proyectoId" value="${py.id}">
        <input type="hidden" name="nombreArchivo" id="nombreArchivo">

        <div class="campo-formulario">
            <label for="informeSimilitud">Informe de similitud de Turnitin (Word o PDF)</label>
            <input type="file" id="informeSimilitud" name="informeSimilitud" accept=".docx,application/pdf" required>
        </div>

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Cargar y enviar al evaluador</button>
            <a href="${pageContext.request.contextPath}/proyecto-detalle.jsp?id=${py.id}" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/js/subida-archivo-unico.js?v=1" data-input="informeSimilitud" data-nombre="nombreArchivo"></script>

<jsp:include page="/WEB-INF/cierre.jsp" />
