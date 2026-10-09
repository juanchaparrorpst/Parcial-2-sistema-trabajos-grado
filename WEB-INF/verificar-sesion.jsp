<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--
    Guard de sesion y de rol. Debe ser LO PRIMERO que incluye cada pagina
    protegida (antes de cualquier HTML), para poder redirigir antes de que
    la respuesta empiece a enviarse:

        <jsp:include page="/WEB-INF/verificar-sesion.jsp" />

    Variable opcional en request, fijada ANTES del include:
      - rolesPermitidos: string con los roles que pueden ver la pagina,
        separados por coma y con comas al inicio/fin, ej:
        ",administrador,coordinacion,". Si no se fija, cualquier usuario
        con sesion iniciada puede entrar.
--%>
<%--
    Importante: este fragmento siempre se llega por <jsp:include> (nunca es
    la pagina pedida directamente), asi que NO se puede usar <c:redirect>
    aqui: un sendRedirect() emitido dentro de un include anidado lo ignora
    el contenedor (la respuesta la controla la pagina de mas afuera). Por
    eso se usa <jsp:forward>, que si puede tomar el control completo de la
    respuesta aunque se invoque desde un fragmento incluido.
--%>
<c:if test="${empty sessionScope.usuarioId}">
    <jsp:forward page="/login.jsp" />
</c:if>
<c:if test="${not empty rolesPermitidos and not fn:contains(rolesPermitidos, ','.concat(sessionScope.usuarioRol).concat(','))}">
    <%--
        <jsp:forward> reutiliza el MISMO request, asi que "rolesPermitidos"
        (fijado en scope request por la pagina original) seguiria visible
        dentro de acceso-denegado.jsp -> su propio menu.jsp -> este mismo
        archivo, volviendo a fallar el chequeo y reenviando de nuevo: un
        bucle infinito. Por eso se limpia antes de reenviar.
    --%>
    <c:remove var="rolesPermitidos" scope="request" />
    <jsp:forward page="/acceso-denegado.jsp" />
</c:if>
