<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="appNombre" value="Sistema de Gestion de Trabajos de Grado - UTS" />
<c:set var="tomcatOk" value="${true}" />
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><c:out value="${appNombre}" /></title>
    <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
    <h1><c:out value="${appNombre}" /></h1>

    <c:if test="${tomcatOk}">
        <p class="ok">Tomcat 8.5.96 (XAMPP) + JSTL 1.2 funcionando correctamente.</p>
    </c:if>

    <ul>
        <c:forEach var="n" begin="1" end="3">
            <li>Prueba de &lt;c:forEach&gt; - iteracion <c:out value="${n}" /></li>
        </c:forEach>
    </ul>

    <script src="js/app.js"></script>
</body>
</html>
