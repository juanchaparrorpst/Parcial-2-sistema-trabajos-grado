<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or (sessionScope.usuarioRol != 'comite' and sessionScope.usuarioRol != 'coordinacion')}">
    <c:redirect url="/login.jsp" />
</c:if>

<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT fase_actual, estado FROM proyecto WHERE id = ?
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />

<c:choose>
    <%-- RF-19/Fase 6: la coordinacion (o comite) abre la fase 6 cuando la 5 ya se cumplio. --%>
    <c:when test="${param.accion == 'avanzar6' and resultadoProyecto.rowCount > 0 and py.fase_actual == 5}">
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            UPDATE proyecto SET fase_actual = 6 WHERE id = ?
            <sql:param value="${param.proyectoId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 5, 'completada', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 6, 'coordinacion', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'avanzar_fase6', 'proyecto', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}&ok=1" />
    </c:when>

    <%-- RF-19/Fase 6: la coordinacion cierra el proyecto. --%>
    <c:when test="${param.accion == 'cerrar' and resultadoProyecto.rowCount > 0 and py.fase_actual == 6 and py.estado != 'finalizado'}">
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            UPDATE proyecto SET estado = 'finalizado' WHERE id = ?
            <sql:param value="${param.proyectoId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 6, 'completada', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'cerrar_proyecto', 'proyecto', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}&ok=1" />
    </c:when>

    <c:otherwise>
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}" />
    </c:otherwise>
</c:choose>
