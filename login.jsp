<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    Pagina publica (no pasa por WEB-INF/verificar-sesion.jsp). Si ya hay
    sesion iniciada, manda directo al inicio.
--%>
<c:if test="${not empty sessionScope.usuarioId}">
    <c:redirect url="/index.jsp" />
</c:if>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ingresar - Sistema de Gestion de Trabajos de Grado</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css?v=2">
</head>
<body>
<div class="pagina-login">
    <div class="login-tarjeta">
        <img class="login-logo" src="${pageContext.request.contextPath}/img/logo-uts.jpeg" alt="Universitaria Tecnologica de Santander">
        <h1>Sistema de Gestión de Trabajos de Grado</h1>

        <c:if test="${param.error == '1'}">
            <p class="mensaje-error">Correo o contraseña incorrectos.</p>
        </c:if>
        <c:if test="${param.error == '2'}">
            <p class="mensaje-error">Este usuario está inactivo. Comuníquese con el administrador.</p>
        </c:if>
        <c:if test="${param.sesionCerrada == '1'}">
            <p class="mensaje-ok">Sesión cerrada correctamente.</p>
        </c:if>

        <form id="formularioLogin" method="post" action="${pageContext.request.contextPath}/procesar-login.jsp">
            <div class="campo-formulario">
                <label for="correo">Correo electrónico</label>
                <input type="email" id="correo" name="correo" required autocomplete="username" autofocus>
            </div>
            <div class="campo-formulario">
                <label for="claveVisible">Contraseña</label>
                <input type="password" id="claveVisible" required autocomplete="current-password">
                <input type="hidden" id="claveHash" name="claveHash">
            </div>
            <button type="submit" class="boton-primario ancho-completo">Ingresar</button>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/js/login.js?v=2"></script>
</body>
</html>
