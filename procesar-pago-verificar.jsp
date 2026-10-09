<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or (sessionScope.usuarioRol != 'comite' and sessionScope.usuarioRol != 'coordinacion')}">
    <c:redirect url="/login.jsp" />
</c:if>

<%-- RF-15: el comite verifica que el pago este completo (soporte de cada
     integrante) antes de marcarlo verificado. Revalidado en el servidor por
     si se evita el boton deshabilitado del formulario. --%>
<sql:query var="resultadoPago" dataSource="${applicationScope.dsSistemaTG}">
    SELECT pg.id, pg.proyecto_id,
           (SELECT COUNT(*) FROM proyecto_integrante WHERE proyecto_id = pg.proyecto_id) AS num_integrantes,
           (SELECT COUNT(*) FROM documento WHERE proyecto_id = pg.proyecto_id AND tipo = 'pago') AS num_soportes
    FROM pago pg WHERE pg.id = ?
    <sql:param value="${param.pagoId}" />
</sql:query>
<c:set var="pago" value="${resultadoPago.rows[0]}" />
<c:set var="completo" value="${resultadoPago.rowCount > 0 and pago.num_soportes >= pago.num_integrantes}" />

<c:choose>
    <c:when test="${!completo}">
        <c:redirect url="/sesion-comite.jsp?verificado=0" />
    </c:when>
    <c:otherwise>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            UPDATE pago SET verificado_por = ? WHERE id = ?
            <sql:param value="${sessionScope.usuarioId}" />
            <sql:param value="${param.pagoId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'verificar_pago', 'pago', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <c:redirect url="/sesion-comite.jsp?verificado=1" />
    </c:otherwise>
</c:choose>
