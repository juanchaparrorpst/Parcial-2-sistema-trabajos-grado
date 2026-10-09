<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or sessionScope.usuarioRol != 'estudiante'}">
    <c:redirect url="/login.jsp" />
</c:if>

<%-- CP-04: completar un pago que quedo incompleto, agregando solo el
     soporte del companero que faltaba. Revalida integrante + que de verdad
     siga incompleto, por si se evita el chequeo del formulario. --%>
<sql:query var="resultadoIntegrante" dataSource="${applicationScope.dsSistemaTG}">
    SELECT 1 FROM proyecto_integrante pi JOIN estudiante e ON e.id = pi.estudiante_id
    WHERE pi.proyecto_id = ? AND e.usuario_id = ?
    AND EXISTS (SELECT 1 FROM pago WHERE id = ? AND proyecto_id = ?)
    AND (SELECT COUNT(*) FROM documento WHERE proyecto_id = ? AND tipo = 'pago')
        < (SELECT COUNT(*) FROM proyecto_integrante WHERE proyecto_id = ?)
    <sql:param value="${param.proyectoId}" />
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.pagoId}" />
    <sql:param value="${param.proyectoId}" />
    <sql:param value="${param.proyectoId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>

<%-- <c:catch> evita un error 500 si la peticion no llega como multipart/form-data. --%>
<c:catch var="errorMultipart">
    <c:set var="parteSoporteCompanero" value="${pageContext.request.getPart('soporteCompanero')}" />
</c:catch>
<c:set var="soporteValido" value="${not empty parteSoporteCompanero and parteSoporteCompanero.size > 0 and fn:endsWith(fn:toLowerCase(parteSoporteCompanero.submittedFileName), '.pdf')}" />

<c:choose>
    <c:when test="${resultadoIntegrante.rowCount == 0 or !soporteValido}">
        <c:redirect url="/pago-formulario.jsp?proyectoId=${param.proyectoId}&error=1" />
    </c:when>
    <c:otherwise>
        <c:set var="rutaUploads" value="${pageContext.servletContext.getRealPath('/uploads/')}" />
        <c:set var="r1" value="${parteSoporteCompanero.write(rutaUploads.concat(param.nombreSoporteCompanero))}" />
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
            VALUES (?, 'pago', ?, 'pdf', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${param.nombreSoporteCompanero}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'completar_pago', 'pago', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <c:redirect url="/propuestas-banco.jsp?pagoRegistrado=1" />
    </c:otherwise>
</c:choose>
