<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%--
    Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio).
    Nota sobre las URLs de esta pagina: <c:redirect url="/algo"> ya antepone
    el context path por su cuenta (igual que <c:url>); por eso aqui NUNCA
    se concatena ${pageContext.request.contextPath} a mano - hacerlo
    duplicaria el path (/sistema-tg/sistema-tg/...).
--%>
<c:if test="${empty sessionScope.usuarioId or sessionScope.usuarioRol != 'administrador'}">
    <c:redirect url="/login.jsp" />
</c:if>

<c:set var="modoEdicion" value="${not empty param.id}" />
<c:set var="volverAlFormulario" value="/usuario-formulario.jsp${modoEdicion ? '?id='.concat(param.id).concat('&error=') : '?error='}" />
<c:set var="nombreValido" value="${fn:contains(fn:trim(param.nombreCompleto), ' ')}" />

<c:choose>
    <%-- RF-03: el nombre debe tener nombre y apellido --%>
    <c:when test="${!nombreValido}">
        <c:redirect url="${volverAlFormulario}1" />
    </c:when>

    <%-- ================= EDICION ================= --%>
    <c:when test="${modoEdicion}">
        <sql:query var="dupCorreo" dataSource="${applicationScope.dsSistemaTG}">
            SELECT id FROM usuario WHERE correo = ? AND id != ?
            <sql:param value="${param.correo}" />
            <sql:param value="${param.id}" />
        </sql:query>
        <sql:query var="dupDocumento" dataSource="${applicationScope.dsSistemaTG}">
            SELECT id FROM usuario WHERE documento_identidad = ? AND id != ?
            <sql:param value="${param.documentoIdentidad}" />
            <sql:param value="${param.id}" />
        </sql:query>

        <c:choose>
            <c:when test="${dupCorreo.rowCount > 0}">
                <c:redirect url="${volverAlFormulario}2" />
            </c:when>
            <c:when test="${dupDocumento.rowCount > 0}">
                <c:redirect url="${volverAlFormulario}3" />
            </c:when>
            <c:when test="${param.rolActual == 'estudiante' and param.esPareja == 'true' and (param.modalidad == 'monografia' or param.modalidad == 'practica')}">
                <c:redirect url="${volverAlFormulario}4" />
            </c:when>
            <c:otherwise>
                <sql:update dataSource="${applicationScope.dsSistemaTG}">
                    UPDATE usuario SET nombre_completo = ?, correo = ?, documento_identidad = ?
                    WHERE id = ?
                    <sql:param value="${param.nombreCompleto}" />
                    <sql:param value="${param.correo}" />
                    <sql:param value="${param.documentoIdentidad}" />
                    <sql:param value="${param.id}" />
                </sql:update>

                <c:if test="${param.rolActual == 'estudiante'}">
                    <sql:update dataSource="${applicationScope.dsSistemaTG}">
                        UPDATE estudiante SET modalidad = ?, es_pareja = ? WHERE usuario_id = ?
                        <sql:param value="${param.modalidad}" />
                        <sql:param value="${param.esPareja == 'true'}" />
                        <sql:param value="${param.id}" />
                    </sql:update>
                </c:if>
                <c:if test="${param.rolActual == 'comite' or param.rolActual == 'director' or param.rolActual == 'evaluador'}">
                    <sql:update dataSource="${applicationScope.dsSistemaTG}">
                        UPDATE docente SET tipo_vinculacion = ?, linea_investigacion = ? WHERE usuario_id = ?
                        <sql:param value="${param.tipoVinculacion}" />
                        <sql:param value="${param.lineaInvestigacion}" />
                        <sql:param value="${param.id}" />
                    </sql:update>
                </c:if>

                <c:redirect url="/gestion-usuarios.jsp?actualizado=1" />
            </c:otherwise>
        </c:choose>
    </c:when>

    <%-- ================= CREACION ================= --%>
    <c:otherwise>
        <c:choose>
            <c:when test="${empty param.rol}">
                <c:redirect url="${volverAlFormulario}5" />
            </c:when>
            <c:when test="${param.rol == 'estudiante' and param.esPareja == 'true' and (param.modalidad == 'monografia' or param.modalidad == 'practica')}">
                <c:redirect url="${volverAlFormulario}4" />
            </c:when>
            <c:otherwise>
                <sql:query var="dupCorreo" dataSource="${applicationScope.dsSistemaTG}">
                    SELECT id FROM usuario WHERE correo = ?
                    <sql:param value="${param.correo}" />
                </sql:query>
                <sql:query var="dupDocumento" dataSource="${applicationScope.dsSistemaTG}">
                    SELECT id FROM usuario WHERE documento_identidad = ?
                    <sql:param value="${param.documentoIdentidad}" />
                </sql:query>

                <c:choose>
                    <c:when test="${dupCorreo.rowCount > 0}">
                        <c:redirect url="${volverAlFormulario}2" />
                    </c:when>
                    <c:when test="${dupDocumento.rowCount > 0}">
                        <c:redirect url="${volverAlFormulario}3" />
                    </c:when>
                    <c:otherwise>
                        <sql:update dataSource="${applicationScope.dsSistemaTG}">
                            INSERT INTO usuario (nombre_completo, correo, documento_identidad, rol, contrasena_hash, activo)
                            VALUES (?, ?, ?, ?, ?, TRUE)
                            <sql:param value="${param.nombreCompleto}" />
                            <sql:param value="${param.correo}" />
                            <sql:param value="${param.documentoIdentidad}" />
                            <sql:param value="${param.rol}" />
                            <sql:param value="${param.claveHashInicial}" />
                        </sql:update>

                        <sql:query var="nuevoUsuario" dataSource="${applicationScope.dsSistemaTG}">
                            SELECT id FROM usuario WHERE correo = ?
                            <sql:param value="${param.correo}" />
                        </sql:query>
                        <c:set var="nuevoId" value="${nuevoUsuario.rows[0].id}" />

                        <c:if test="${param.rol == 'estudiante'}">
                            <sql:update dataSource="${applicationScope.dsSistemaTG}">
                                INSERT INTO estudiante (usuario_id, modalidad, es_pareja)
                                VALUES (?, ?, ?)
                                <sql:param value="${nuevoId}" />
                                <sql:param value="${param.modalidad}" />
                                <sql:param value="${param.esPareja == 'true'}" />
                            </sql:update>
                        </c:if>
                        <c:if test="${param.rol == 'comite' or param.rol == 'director' or param.rol == 'evaluador'}">
                            <sql:update dataSource="${applicationScope.dsSistemaTG}">
                                INSERT INTO docente (usuario_id, tipo_vinculacion, linea_investigacion)
                                VALUES (?, ?, ?)
                                <sql:param value="${nuevoId}" />
                                <sql:param value="${param.tipoVinculacion}" />
                                <sql:param value="${param.lineaInvestigacion}" />
                            </sql:update>
                        </c:if>

                        <c:redirect url="/gestion-usuarios.jsp?creado=1" />
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>
