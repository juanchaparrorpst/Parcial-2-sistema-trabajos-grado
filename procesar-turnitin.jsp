<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or sessionScope.usuarioRol != 'director'}">
    <c:redirect url="/login.jsp" />
</c:if>

<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.fase_actual,
           (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = 3 ORDER BY id DESC LIMIT 1) AS responsable,
           (SELECT COUNT(*) FROM asignacion a JOIN docente d ON d.id = a.director_id
                WHERE a.proyecto_id = py.id AND d.usuario_id = ?) AS es_director_sesion
    FROM proyecto py WHERE py.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />

<%-- <c:catch> evita un error 500 si la peticion no llega como multipart/form-data. --%>
<c:catch var="errorMultipart">
    <c:set var="parte" value="${pageContext.request.getPart('informeSimilitud')}" />
</c:catch>
<c:set var="nombreOriginal" value="${not empty parte ? fn:toLowerCase(parte.submittedFileName) : ''}" />
<c:set var="archivoValido" value="${not empty parte and parte.size > 0 and (fn:endsWith(nombreOriginal, '.docx') or fn:endsWith(nombreOriginal, '.pdf'))}" />

<c:choose>
    <c:when test="${resultadoProyecto.rowCount == 0 or py.es_director_sesion == 0 or py.fase_actual != 3 or py.responsable != 'director' or !archivoValido}">
        <c:redirect url="/turnitin-formulario.jsp?proyectoId=${param.proyectoId}&error=1" />
    </c:when>
    <c:otherwise>
        <c:set var="rutaUploads" value="${pageContext.servletContext.getRealPath('/uploads/')}" />
        <c:set var="formatoArchivo" value="${fn:endsWith(nombreOriginal, '.docx') ? 'docx' : 'pdf'}" />
        <c:set var="r1" value="${parte.write(rutaUploads.concat(param.nombreArchivo))}" />

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
            VALUES (?, 'informe_similitud', ?, ?, NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${param.nombreArchivo}" />
            <sql:param value="${formatoArchivo}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>

        <%-- RF-23: queda registrado con fecha y responsable (el documento ya
             lo tiene); pasa la mano al evaluador, sigue en fase 3. --%>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 3, 'evaluador', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'cargar_informe_similitud', 'documento', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>

        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}&ok=1" />
    </c:otherwise>
</c:choose>
