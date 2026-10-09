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
           (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = 2 ORDER BY id DESC LIMIT 1) AS responsable,
           (SELECT COUNT(*) FROM asignacion a JOIN docente d ON d.id = a.director_id
                WHERE a.proyecto_id = py.id AND d.usuario_id = ?) AS es_director_sesion
    FROM proyecto py WHERE py.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />

<%-- RF-22: aplazado exige documento de observaciones (Word o PDF).
     getPart() lanza una excepcion si la peticion no es multipart/form-data
     (por ejemplo, alguien llamando a esta URL directo); <c:catch> evita que
     eso tire un error 500 en vez de la redireccion normal de "invalido". --%>
<c:catch var="errorMultipart">
    <c:set var="parte" value="${pageContext.request.getPart('observaciones')}" />
</c:catch>
<c:set var="nombreOriginal" value="${not empty parte ? fn:toLowerCase(parte.submittedFileName) : ''}" />
<c:set var="adjuntoValido" value="${not empty parte and parte.size > 0 and (fn:endsWith(nombreOriginal, '.docx') or fn:endsWith(nombreOriginal, '.pdf'))}" />
<c:set var="esValido" value="${resultadoProyecto.rowCount > 0 and py.es_director_sesion > 0 and py.fase_actual == 2 and py.responsable == 'director' and (param.decision == 'aprobado' or param.decision == 'aplazado') and (param.decision == 'aprobado' or adjuntoValido)}" />

<c:choose>
    <c:when test="${!esValido}">
        <c:redirect url="/director-revisar.jsp?proyectoId=${param.proyectoId}&error=1" />
    </c:when>

    <%-- Aprobado: la propuesta pasa a fase 3 (Informe y envio), responsable director. --%>
    <c:when test="${param.decision == 'aprobado'}">
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            UPDATE proyecto SET fase_actual = 3 WHERE id = ?
            <sql:param value="${param.proyectoId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 2, 'completada', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
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
            VALUES (?, 'aprobar_formato124', 'documento', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}&ok=1" />
    </c:when>

    <%-- Aplazado: se queda en fase 2, vuelve al estudiante con las observaciones. --%>
    <c:otherwise>
        <c:set var="rutaUploads" value="${pageContext.servletContext.getRealPath('/uploads/')}" />
        <c:set var="formatoArchivo" value="${fn:endsWith(nombreOriginal, '.docx') ? 'docx' : 'pdf'}" />
        <c:set var="r1" value="${parte.write(rutaUploads.concat(param.nombreObservaciones))}" />

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
            VALUES (?, 'correcciones', ?, ?, NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${param.nombreObservaciones}" />
            <sql:param value="${formatoArchivo}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 2, 'estudiante', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'aplazar_formato124', 'documento', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}&ok=1" />
    </c:otherwise>
</c:choose>
