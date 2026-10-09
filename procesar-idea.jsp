<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or (sessionScope.usuarioRol != 'comite' and sessionScope.usuarioRol != 'director' and sessionScope.usuarioRol != 'evaluador')}">
    <c:redirect url="/login.jsp" />
</c:if>

<c:set var="camposCompletos" value="${not empty fn:trim(param.titulo) and not empty fn:trim(param.objetivo) and not empty fn:trim(param.descripcion) and not empty fn:trim(param.lineaInvestigacion) and not empty param.nivel and not empty param.periodoId}" />

<c:choose>
    <c:when test="${!camposCompletos}">
        <c:redirect url="/idea-formulario.jsp?error=1" />
    </c:when>
    <c:otherwise>
        <%-- RF-06 / CP-11: revalidar en el servidor que el periodo elegido sea
             de banco_ideas y este vigente hoy, por si se evita la validacion
             del formulario. --%>
        <sql:query var="periodoValido" dataSource="${applicationScope.dsSistemaTG}">
            SELECT id FROM periodo
            WHERE id = ? AND modulo = 'banco_ideas' AND CURDATE() BETWEEN fecha_inicio AND fecha_fin
            <sql:param value="${param.periodoId}" />
        </sql:query>

        <sql:query var="docenteActual" dataSource="${applicationScope.dsSistemaTG}">
            SELECT id FROM docente WHERE usuario_id = ?
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:query>

        <c:choose>
            <c:when test="${periodoValido.rowCount == 0}">
                <c:redirect url="/idea-formulario.jsp" />
            </c:when>
            <c:otherwise>
                <sql:update dataSource="${applicationScope.dsSistemaTG}">
                    INSERT INTO idea (titulo, objetivo, descripcion, linea_investigacion, nivel, periodo_id, docente_id, estado, disponible)
                    VALUES (?, ?, ?, ?, ?, ?, ?, 'pendiente', TRUE)
                    <sql:param value="${param.titulo}" />
                    <sql:param value="${param.objetivo}" />
                    <sql:param value="${param.descripcion}" />
                    <sql:param value="${param.lineaInvestigacion}" />
                    <sql:param value="${param.nivel}" />
                    <sql:param value="${param.periodoId}" />
                    <sql:param value="${docenteActual.rows[0].id}" />
                </sql:update>
                <c:redirect url="/banco-ideas.jsp?publicada=1" />
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>
