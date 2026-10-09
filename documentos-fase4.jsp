<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- RF-25: cualquier integrante (lider o pareja) puede cargar documentos, y
     solo mientras el proyecto este en fase 4. --%>
<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.fase_actual,
           (SELECT COUNT(*) FROM proyecto_integrante pi JOIN estudiante e ON e.id = pi.estudiante_id
                WHERE pi.proyecto_id = py.id AND e.usuario_id = ?) AS es_integrante_sesion
    FROM proyecto py WHERE py.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:if test="${resultadoProyecto.rowCount == 0}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />
<c:if test="${py.es_integrante_sesion == 0 or py.fase_actual != 4}">
    <jsp:forward page="/proyecto-detalle.jsp?id=${param.proyectoId}" />
</c:if>

<%-- La fecha se formatea en el SQL (DATE_FORMAT): el driver de MySQL
     devuelve las columnas DATETIME como java.time.LocalDateTime, que
     <fmt:formatDate> no puede convertir. --%>
<sql:query var="documentos" dataSource="${applicationScope.dsSistemaTG}">
    SELECT d.archivo, d.formato, DATE_FORMAT(d.fecha, '%d/%m/%Y %H:%i') AS fecha_formateada, u.nombre_completo AS autor
    FROM documento d LEFT JOIN usuario u ON u.id = d.usuario_id
    WHERE d.proyecto_id = ? AND d.tipo = 'fase4'
    ORDER BY d.fecha DESC
    <sql:param value="${param.proyectoId}" />
</sql:query>

<c:set var="tituloPagina" value="Documentos fase 4 - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="proyectos" scope="request" />
<c:set var="rolesPermitidos" value=",estudiante," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Documentos <span class="insignia-verde">FASE 4</span></h2>
</div>

<c:if test="${param.error == '1'}">
    <p class="mensaje-error">El archivo es obligatorio y debe ser Word o PDF.</p>
</c:if>
<c:if test="${param.error == '2'}">
    <p class="mensaje-error">Carga al menos un documento antes de finalizar la fase 4.</p>
</c:if>

<p class="ayuda" style="margin-bottom:16px;">Proyecto ${py.consecutivo}-${py.anio}.</p>

<div class="tabla-contenedor" style="margin-bottom:20px;">
    <form method="post" action="${pageContext.request.contextPath}/procesar-documentos-fase4.jsp" enctype="multipart/form-data" class="formulario-rejilla">
        <input type="hidden" name="proyectoId" value="${py.id}">
        <input type="hidden" name="accion" value="subir">
        <input type="hidden" name="nombreArchivo" id="nombreArchivo">
        <div class="campo-formulario">
            <label for="documentoFase4">Documento (Word o PDF)</label>
            <input type="file" id="documentoFase4" name="documentoFase4" accept=".docx,application/pdf" required>
        </div>
        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Cargar documento</button>
        </div>
    </form>
</div>

<h3 style="margin-bottom:10px;">Documentos cargados (${documentos.rowCount})</h3>
<div class="tabla-contenedor" style="margin-bottom:20px;">
    <table class="tabla-datos">
        <thead><tr><th>Fecha</th><th>Cargado por</th><th>Documento</th></tr></thead>
        <tbody>
            <c:forEach var="d" items="${documentos.rows}">
                <tr>
                    <td><c:out value="${d.fecha_formateada}" /></td>
                    <td><c:out value="${d.autor}" /></td>
                    <td><a href="${pageContext.request.contextPath}/uploads/${d.archivo}" target="_blank">Ver documento (${d.formato})</a></td>
                </tr>
            </c:forEach>
            <c:if test="${documentos.rowCount == 0}">
                <tr><td colspan="3">Todavía no se ha cargado ningún documento.</td></tr>
            </c:if>
        </tbody>
    </table>
</div>

<form method="post" action="${pageContext.request.contextPath}/procesar-documentos-fase4.jsp">
    <input type="hidden" name="proyectoId" value="${py.id}">
    <input type="hidden" name="accion" value="finalizar">
    <div class="formulario-acciones">
        <button type="submit" class="boton-primario">Finalizar fase 4</button>
        <a href="${pageContext.request.contextPath}/proyecto-detalle.jsp?id=${py.id}" class="boton-secundario">Volver al proyecto</a>
    </div>
</form>

<script src="${pageContext.request.contextPath}/js/subida-archivo-unico.js?v=1" data-input="documentoFase4" data-nombre="nombreArchivo"></script>

<jsp:include page="/WEB-INF/cierre.jsp" />
