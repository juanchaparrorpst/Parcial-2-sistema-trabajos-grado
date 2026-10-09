<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<sql:query var="resultado" dataSource="${applicationScope.dsSistemaTG}">
    SELECT id, nombre_completo, correo, rol, contrasena_hash, activo
    FROM usuario
    WHERE correo = ?
    <sql:param value="${param.correo}" />
</sql:query>

<c:choose>
    <c:when test="${resultado.rowCount == 0 or resultado.rows[0].contrasena_hash != param.claveHash}">
        <c:redirect url="/login.jsp?error=1" />
    </c:when>
    <c:when test="${resultado.rows[0].activo == false}">
        <c:redirect url="/login.jsp?error=2" />
    </c:when>
    <c:otherwise>
        <c:set var="usuarioId" value="${resultado.rows[0].id}" scope="session" />
        <c:set var="usuarioNombre" value="${resultado.rows[0].nombre_completo}" scope="session" />
        <c:set var="usuarioCorreo" value="${resultado.rows[0].correo}" scope="session" />
        <c:set var="usuarioRol" value="${resultado.rows[0].rol}" scope="session" />
        <c:redirect url="/index.jsp" />
    </c:otherwise>
</c:choose>
