<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<sql:query var="roles" dataSource="${applicationScope.dsSistemaTG}">
    SELECT DISTINCT rol FROM usuario ORDER BY rol
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Prueba de conexion - sistema_tg</title>
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
    <h1>Prueba de conexion a la base de datos</h1>

    <c:choose>
        <c:when test="${roles.rowCount > 0}">
            <p class="ok">Conexion correcta. Roles distintos encontrados en la tabla usuario: <c:out value="${roles.rowCount}" /></p>
            <ul>
                <c:forEach var="fila" items="${roles.rows}">
                    <li><c:out value="${fila.rol}" /></li>
                </c:forEach>
            </ul>
        </c:when>
        <c:otherwise>
            <p>Conexion correcta, pero la tabla usuario no tiene datos todavia.</p>
        </c:otherwise>
    </c:choose>
</body>
</html>
