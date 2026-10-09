<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or sessionScope.usuarioRol != 'estudiante'}">
    <c:redirect url="/login.jsp" />
</c:if>

<%-- Revalida que quien envia sea integrante del proyecto y que no exista ya un pago. --%>
<sql:query var="resultadoIntegrante" dataSource="${applicationScope.dsSistemaTG}">
    SELECT 1 FROM proyecto_integrante pi JOIN estudiante e ON e.id = pi.estudiante_id
    WHERE pi.proyecto_id = ? AND e.usuario_id = ?
    AND NOT EXISTS (SELECT 1 FROM pago WHERE proyecto_id = ?)
    <sql:param value="${param.proyectoId}" />
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>

<%-- RF-15 / RNF-11: la liquidacion y el soporte propio son obligatorios y
     deben ser PDF. <c:catch> evita un error 500 si la peticion no llega como
     multipart/form-data (encontrado en el Sprint 4 probando CP-05 contra un
     endpoint parecido; se corrigio aqui tambien por el mismo motivo). --%>
<c:catch var="errorMultipart">
    <c:set var="parteLiquidacion" value="${pageContext.request.getPart('liquidacion')}" />
    <c:set var="parteSoportePropio" value="${pageContext.request.getPart('soportePropio')}" />
    <c:set var="parteSoporteCompanero" value="${pageContext.request.getPart('soporteCompanero')}" />
</c:catch>

<c:set var="liquidacionValida" value="${not empty parteLiquidacion and parteLiquidacion.size > 0 and fn:endsWith(fn:toLowerCase(parteLiquidacion.submittedFileName), '.pdf')}" />
<c:set var="soportePropioValido" value="${not empty parteSoportePropio and parteSoportePropio.size > 0 and fn:endsWith(fn:toLowerCase(parteSoportePropio.submittedFileName), '.pdf')}" />
<c:set var="hayCompanero" value="${not empty parteSoporteCompanero and parteSoporteCompanero.size > 0}" />
<c:set var="soporteCompaneroValido" value="${!hayCompanero or fn:endsWith(fn:toLowerCase(parteSoporteCompanero.submittedFileName), '.pdf')}" />

<c:choose>
    <c:when test="${resultadoIntegrante.rowCount == 0 or empty fn:trim(param.semestre) or !liquidacionValida or !soportePropioValido or !soporteCompaneroValido}">
        <c:redirect url="/pago-formulario.jsp?proyectoId=${param.proyectoId}&error=1" />
    </c:when>
    <c:otherwise>
        <c:set var="rutaUploads" value="${pageContext.servletContext.getRealPath('/uploads/')}" />

        <c:set var="r1" value="${parteLiquidacion.write(rutaUploads.concat(param.nombreLiquidacion))}" />
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
            VALUES (?, 'liquidacion', ?, 'pdf', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${param.nombreLiquidacion}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:query var="documentoLiquidacion" dataSource="${applicationScope.dsSistemaTG}">
            SELECT id FROM documento WHERE archivo = ?
            <sql:param value="${param.nombreLiquidacion}" />
        </sql:query>

        <c:set var="r2" value="${parteSoportePropio.write(rutaUploads.concat(param.nombreSoportePropio))}" />
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
            VALUES (?, 'pago', ?, 'pdf', NOW(), ?)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${param.nombreSoportePropio}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>

        <c:if test="${hayCompanero}">
            <c:set var="r3" value="${parteSoporteCompanero.write(rutaUploads.concat(param.nombreSoporteCompanero))}" />
            <sql:update dataSource="${applicationScope.dsSistemaTG}">
                INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
                VALUES (?, 'pago', ?, 'pdf', NOW(), ?)
                <sql:param value="${param.proyectoId}" />
                <sql:param value="${param.nombreSoporteCompanero}" />
                <sql:param value="${sessionScope.usuarioId}" />
            </sql:update>
        </c:if>

        <%-- La tabla pago solo referencia un documento (la liquidacion); el o
             los soportes de pago quedan como "documento" tipo 'pago' del
             mismo proyecto, y se cuentan en pago-revisar.jsp para saber si la
             solicitud esta completa (RF-15, CP-04). --%>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO pago (proyecto_id, documento_id, semestre, verificado_por)
            VALUES (?, ?, ?, NULL)
            <sql:param value="${param.proyectoId}" />
            <sql:param value="${documentoLiquidacion.rows[0].id}" />
            <sql:param value="${param.semestre}" />
        </sql:update>

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'cargar_pago', 'pago', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>

        <c:redirect url="/propuestas-banco.jsp?pagoRegistrado=1" />
    </c:otherwise>
</c:choose>
