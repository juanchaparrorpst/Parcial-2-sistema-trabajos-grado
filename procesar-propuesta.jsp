<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or sessionScope.usuarioRol != 'estudiante'}">
    <c:redirect url="/login.jsp" />
</c:if>

<%-- RF-10 / CP-03: todos los campos son obligatorios. --%>
<c:set var="camposCompletos" value="${not empty fn:trim(param.titulo) and not empty fn:trim(param.objetivo) and not empty fn:trim(param.descripcion) and not empty fn:trim(param.lineaInvestigacion)}" />

<c:choose>
    <c:when test="${!camposCompletos}">
        <c:redirect url="/propuesta-formulario.jsp?error=1${not empty param.ideaId ? '&ideaId='.concat(param.ideaId) : ''}" />
    </c:when>
    <c:otherwise>
        <sql:query var="estudianteActual" dataSource="${applicationScope.dsSistemaTG}">
            SELECT id FROM estudiante WHERE usuario_id = ?
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:query>

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO propuesta (idea_id, titulo, objetivo, descripcion, linea_investigacion, estudiante_lider_id, estado)
            VALUES (?, ?, ?, ?, ?, ?, 'pendiente')
            <sql:param value="${empty param.ideaId ? null : param.ideaId}" />
            <sql:param value="${param.titulo}" />
            <sql:param value="${param.objetivo}" />
            <sql:param value="${param.descripcion}" />
            <sql:param value="${param.lineaInvestigacion}" />
            <sql:param value="${estudianteActual.rows[0].id}" />
        </sql:update>

        <%-- La idea elegida del banco deja de estar disponible para otros. --%>
        <c:if test="${not empty param.ideaId}">
            <sql:update dataSource="${applicationScope.dsSistemaTG}">
                UPDATE idea SET disponible = FALSE WHERE id = ?
                <sql:param value="${param.ideaId}" />
            </sql:update>
        </c:if>

        <c:redirect url="/propuestas-banco.jsp?creada=1" />
    </c:otherwise>
</c:choose>
