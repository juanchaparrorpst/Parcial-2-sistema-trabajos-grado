<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or sessionScope.usuarioRol != 'estudiante'}">
    <c:redirect url="/login.jsp" />
</c:if>

<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.fase_actual,
           (SELECT COUNT(*) FROM proyecto_integrante pi JOIN estudiante e ON e.id = pi.estudiante_id
                WHERE pi.proyecto_id = py.id AND e.usuario_id = ?) AS es_integrante_sesion,
           (SELECT COUNT(*) FROM documento WHERE proyecto_id = py.id AND tipo = 'fase4') AS num_documentos
    FROM proyecto py WHERE py.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:set var="py" value="${resultadoProyecto.rows[0]}" />
<c:set var="esValido" value="${resultadoProyecto.rowCount > 0 and py.es_integrante_sesion > 0 and py.fase_actual == 4}" />

<c:choose>
    <c:when test="${!esValido}">
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}" />
    </c:when>

    <%-- RF-25: solo se habilita la carga en la fase 4; cada documento queda
         con fecha y usuario responsable. --%>
    <c:when test="${param.accion == 'subir'}">
        <%-- <c:catch> evita un error 500 si la peticion no llega como multipart/form-data. --%>
        <c:catch var="errorMultipart">
            <c:set var="parte" value="${pageContext.request.getPart('documentoFase4')}" />
        </c:catch>
        <c:set var="nombreOriginal" value="${not empty parte ? fn:toLowerCase(parte.submittedFileName) : ''}" />
        <c:set var="archivoValido" value="${not empty parte and parte.size > 0 and (fn:endsWith(nombreOriginal, '.docx') or fn:endsWith(nombreOriginal, '.pdf'))}" />
        <c:choose>
            <c:when test="${!archivoValido}">
                <c:redirect url="/documentos-fase4.jsp?proyectoId=${param.proyectoId}&error=1" />
            </c:when>
            <c:otherwise>
                <c:set var="rutaUploads" value="${pageContext.servletContext.getRealPath('/uploads/')}" />
                <c:set var="formatoArchivo" value="${fn:endsWith(nombreOriginal, '.docx') ? 'docx' : 'pdf'}" />
                <c:set var="r1" value="${parte.write(rutaUploads.concat(param.nombreArchivo))}" />
                <sql:update dataSource="${applicationScope.dsSistemaTG}">
                    INSERT INTO documento (proyecto_id, tipo, archivo, formato, fecha, usuario_id)
                    VALUES (?, 'fase4', ?, ?, NOW(), ?)
                    <sql:param value="${param.proyectoId}" />
                    <sql:param value="${param.nombreArchivo}" />
                    <sql:param value="${formatoArchivo}" />
                    <sql:param value="${sessionScope.usuarioId}" />
                </sql:update>
                <sql:update dataSource="${applicationScope.dsSistemaTG}">
                    INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
                    VALUES (?, 'cargar_documento_fase4', 'documento', NOW())
                    <sql:param value="${sessionScope.usuarioId}" />
                </sql:update>
                <c:redirect url="/documentos-fase4.jsp?proyectoId=${param.proyectoId}" />
            </c:otherwise>
        </c:choose>
    </c:when>

    <%-- Finalizar fase 4: pasa a la fase 5 (ver SEGUIMIENTO_PROYECTO.md: sin
         descripcion clara, queda como un estado intermedio hasta que
         coordinacion/comite la avance manualmente a la fase 6). --%>
    <c:when test="${param.accion == 'finalizar'}">
        <c:choose>
            <c:when test="${py.num_documentos == 0}">
                <c:redirect url="/documentos-fase4.jsp?proyectoId=${param.proyectoId}&error=2" />
            </c:when>
            <c:otherwise>
                <sql:update dataSource="${applicationScope.dsSistemaTG}">
                    UPDATE proyecto SET fase_actual = 5 WHERE id = ?
                    <sql:param value="${param.proyectoId}" />
                </sql:update>
                <sql:update dataSource="${applicationScope.dsSistemaTG}">
                    INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
                    VALUES (?, 4, 'completada', NOW(), ?)
                    <sql:param value="${param.proyectoId}" />
                    <sql:param value="${sessionScope.usuarioId}" />
                </sql:update>
                <sql:update dataSource="${applicationScope.dsSistemaTG}">
                    INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
                    VALUES (?, 5, 'por definir', NOW(), ?)
                    <sql:param value="${param.proyectoId}" />
                    <sql:param value="${sessionScope.usuarioId}" />
                </sql:update>
                <sql:update dataSource="${applicationScope.dsSistemaTG}">
                    INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
                    VALUES (?, 'finalizar_fase4', 'proyecto', NOW())
                    <sql:param value="${sessionScope.usuarioId}" />
                </sql:update>
                <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}&ok=1" />
            </c:otherwise>
        </c:choose>
    </c:when>

    <c:otherwise>
        <c:redirect url="/proyecto-detalle.jsp?id=${param.proyectoId}" />
    </c:otherwise>
</c:choose>
