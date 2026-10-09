<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or (sessionScope.usuarioRol != 'comite' and sessionScope.usuarioRol != 'coordinacion')}">
    <c:redirect url="/login.jsp" />
</c:if>

<c:choose>
    <c:when test="${empty fn:trim(param.motivo)}">
        <c:redirect url="/idea-revisar.jsp?id=${param.ideaId}" />
    </c:when>
    <c:otherwise>
        <%-- RF-07: el cambio de estado de la idea queda en el acta (numero,
             fecha, decision, motivo) y en auditoria (quien lo hizo). --%>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            UPDATE idea SET estado = ? WHERE id = ?
            <sql:param value="${param.decision}" />
            <sql:param value="${param.ideaId}" />
        </sql:update>

        <sql:query var="siguienteActa" dataSource="${applicationScope.dsSistemaTG}">
            SELECT COALESCE(MAX(numero), 0) + 1 AS siguiente FROM acta
        </sql:query>

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO acta (numero, fecha, decision, motivo, idea_id)
            VALUES (?, CURDATE(), ?, ?, ?)
            <sql:param value="${siguienteActa.rows[0].siguiente}" />
            <sql:param value="${param.decision}" />
            <sql:param value="${param.motivo}" />
            <sql:param value="${param.ideaId}" />
        </sql:update>

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, ?, 'idea', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
            <sql:param value="cambiar_estado:${param.decision}" />
        </sql:update>

        <c:redirect url="/banco-ideas.jsp?revisada=1" />
    </c:otherwise>
</c:choose>
