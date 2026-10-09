<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="tituloPagina" value="Gestion de usuarios - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="usuarios" scope="request" />
<c:set var="rolesPermitidos" value=",administrador," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<sql:query var="usuarios" dataSource="${applicationScope.dsSistemaTG}">
    SELECT u.id, u.nombre_completo, u.correo, u.documento_identidad, u.rol, u.activo,
           e.modalidad, e.es_pareja,
           d.tipo_vinculacion, d.linea_investigacion
    FROM usuario u
    LEFT JOIN estudiante e ON e.usuario_id = u.id
    LEFT JOIN docente d ON d.usuario_id = u.id
    ORDER BY u.nombre_completo
</sql:query>

<div class="titulo-pagina">
    <h2>Gestión de <span class="insignia-verde">USUARIOS</span></h2>
    <a class="boton-primario boton-nuevo" href="${pageContext.request.contextPath}/usuario-formulario.jsp">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
        Nuevo usuario
    </a>
</div>

<c:if test="${param.creado == '1'}">
    <p class="mensaje-ok">Usuario creado correctamente. La contraseña inicial es su documento de identidad.</p>
</c:if>
<c:if test="${param.actualizado == '1'}">
    <p class="mensaje-ok">Datos actualizados correctamente.</p>
</c:if>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<table class="tabla-datos">
    <thead>
        <tr>
            <th>Nombre completo</th>
            <th>Correo</th>
            <th>Documento</th>
            <th>Rol</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="fila" items="${usuarios.rows}">
            <tr>
                <td><c:out value="${fila.nombre_completo}" /></td>
                <td><c:out value="${fila.correo}" /></td>
                <td><c:out value="${fila.documento_identidad}" /></td>
                <td><c:out value="${fila.rol}" /></td>
                <td>
                    <button type="button" class="boton-ver"
                        data-titulo-modal="Detalles del usuario"
                        data-etq-1="Nombre completo" data-val-1="${fn:escapeXml(fila.nombre_completo)}"
                        data-etq-2="Correo" data-val-2="${fn:escapeXml(fila.correo)}"
                        data-etq-3="Documento de identidad" data-val-3="${fn:escapeXml(fila.documento_identidad)}"
                        data-etq-4="Rol" data-val-4="${fn:escapeXml(fila.rol)}"
                        data-etq-5="Estado" data-val-5="${fila.activo ? 'Activo' : 'Inactivo'}"
                        <c:if test="${fila.rol == 'estudiante'}">
                            data-etq-6="Modalidad" data-val-6="${fn:escapeXml(fila.modalidad)}"
                            data-etq-7="¿Individual o en pareja?" data-val-7="${fila.es_pareja ? 'Pareja' : 'Individual'}"
                        </c:if>
                        <c:if test="${fila.rol == 'comite' or fila.rol == 'director' or fila.rol == 'evaluador'}">
                            data-etq-6="Tipo de vinculación" data-val-6="${fn:escapeXml(fila.tipo_vinculacion)}"
                            data-etq-7="Línea de investigación" data-val-7="${fn:escapeXml(fila.linea_investigacion)}"
                        </c:if>
                        >
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                    </button>
                    <a class="boton-editar" title="Editar"
                       href="${pageContext.request.contextPath}/usuario-formulario.jsp?id=${fila.id}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h4L18.5 9.5a2.1 2.1 0 0 0-3-3L5 17v3Z"/><path d="M13.5 7.5l3 3"/></svg>
                    </a>
                </td>
            </tr>
        </c:forEach>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
