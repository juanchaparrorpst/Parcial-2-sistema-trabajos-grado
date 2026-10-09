<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or (sessionScope.usuarioRol != 'administrador' and sessionScope.usuarioRol != 'coordinacion' and sessionScope.usuarioRol != 'comite')}">
    <c:redirect url="/login.jsp" />
</c:if>

<sql:update dataSource="${applicationScope.dsSistemaTG}">
    UPDATE estudiante SET porcentaje_creditos = ?, metodologia_aprobada = ? WHERE id = ?
    <sql:param value="${param.porcentajeCreditos}" />
    <sql:param value="${not empty param.metodologiaAprobada}" />
    <sql:param value="${param.id}" />
</sql:update>

<c:redirect url="/verificar-requisitos.jsp?actualizado=1" />
