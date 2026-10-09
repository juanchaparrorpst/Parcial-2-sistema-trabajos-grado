<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or (sessionScope.usuarioRol != 'comite' and sessionScope.usuarioRol != 'coordinacion')}">
    <c:redirect url="/login.jsp" />
</c:if>

<%-- RF-05: no se permiten fechas invertidas --%>
<c:choose>
    <c:when test="${param.fechaInicio > param.fechaFin}">
        <c:redirect url="/periodo-formulario.jsp?error=1" />
    </c:when>
    <c:otherwise>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO periodo (nombre, fecha_inicio, fecha_fin, modulo)
            VALUES (?, ?, ?, ?)
            <sql:param value="${param.nombre}" />
            <sql:param value="${param.fechaInicio}" />
            <sql:param value="${param.fechaFin}" />
            <sql:param value="${param.modulo}" />
        </sql:update>
        <c:redirect url="/calendario-academico.jsp?creado=1" />
    </c:otherwise>
</c:choose>
