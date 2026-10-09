<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or sessionScope.usuarioRol != 'evaluador'}">
    <c:redirect url="/login.jsp" />
</c:if>

<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.fase_actual,
           (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = 3 ORDER BY id DESC LIMIT 1) AS responsable,
           (SELECT COUNT(*) FROM asignacion a JOIN docente d ON d.id = a.evaluador_id
                WHERE a.proyecto_id = py.id AND d.usuario_id = ?) AS es_evaluador_sesion
    FROM proyecto py WHERE py.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />
<c:set var="esAprobado" value="${param.decision == 'aprobado'}" />

<%-- <c:catch> evita un error 500 si la peticion no llega como multipart/form-data. --%>
<c:catch var="errorMultipart">
    <c:set var="parte" value="${esAprobado ? pageContext.request.getPart('archivo') : pageContext.request.getPart('archivoAplazado')}" />
</c:catch>
<c:set var="nombreOriginal" value="${not empty parte ? fn:toLowerCase(parte.submittedFileName) : ''}" />
<c:set var="archivoValido" value="${not empty parte and parte.size > 0 and (fn:endsWith(nombreOriginal, '.docx') or fn:endsWith(nombreOriginal, '.pdf'))}" />
<c:set var="esValido" value="${resultadoProyecto.rowCount > 0 and py.es_evaluador_sesion > 0 and py.fase_actual == 3 and py.responsable == 'evaluador' and (param.decision == 'aprobado' or param.decision == 'aplazado') and archivoValido}" />

<c:choose>
    <c:when test="${!esValido}">
        <c:redirect url="/evaluador-revisar.jsp?proyectoId=${param.proyectoId}&error=1" />
    </c:when>

    <%-- Aprobado: formato 125 firmado queda registrado, pasa a fase 4 (estudiante). --%>
    <c:when test="${esAprobado}">
        <c:set var="rutaUploads" value="${pageContext.servletContext.getRealPath('/uploads/')}" />
        <c:set var="formatoArchivo" value="${fn:endsWith(nombreOriginal, '.docx') ? 'docx' : 'pdf'}" />
        <c:set var="r1" value="${parte.write(rutaUploads.concat(param.nombreArchivo))}" />

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
            VALUES (?, 'F-DC-125', ?, ?, NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${param.nombreArchivo}" />
            <sql:param value="${formatoArchivo}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            UPDATE proyecto SET fase_actual = 4 WHERE id = ?
            <sql:param value="${param.proyectoId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 3, 'completada', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 4, 'estudiante', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'aprobar_formato125', 'documento', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}&ok=1" />
    </c:when>

    <%-- Aplazado: vuelve al director (RF-24 no especifica a quien corrige
         directamente, pero es el director quien coordina el envio al
         evaluador y el reenvio del informe -- ver SEGUIMIENTO_PROYECTO.md). --%>
    <c:otherwise>
        <c:set var="rutaUploads" value="${pageContext.servletContext.getRealPath('/uploads/')}" />
        <c:set var="formatoArchivo" value="${fn:endsWith(nombreOriginal, '.docx') ? 'docx' : 'pdf'}" />
        <c:set var="r1" value="${parte.write(rutaUploads.concat(param.nombreArchivo))}" />

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
            VALUES (?, 'correcciones', ?, ?, NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${param.nombreArchivo}" />
            <sql:param value="${formatoArchivo}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 3, 'director', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'aplazar_formato125', 'documento', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}&ok=1" />
    </c:otherwise>
</c:choose>
