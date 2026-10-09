<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or sessionScope.usuarioRol != 'administrador'}">
    <c:redirect url="/login.jsp" />
</c:if>

<%--
    RNF-05: eliminacion logica. No hay una accion para borrar usuarios -- se
    marcan como inactivos (usuario.activo = FALSE) en vez de borrarlos de la
    base de datos, para conservar el historial (actas, documentos,
    asignaciones, auditoria siguen apuntando a ellos). procesar-login.jsp ya
    rechaza el ingreso de un usuario inactivo desde el Prompt 1.1.
--%>
<sql:update dataSource="${applicationScope.dsSistemaTG}">
    UPDATE usuario SET activo = ? WHERE id = ?
    <sql:param value="${param.activar == 'true'}" />
    <sql:param value="${param.id}" />
</sql:update>

<sql:update dataSource="${applicationScope.dsSistemaTG}">
    INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
    VALUES (?, ?, 'usuario', NOW())
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.activar == 'true' ? 'activar' : 'desactivar'}:${param.id}" />
</sql:update>

<c:redirect url="/gestion-usuarios.jsp?estadoCambiado=1" />
