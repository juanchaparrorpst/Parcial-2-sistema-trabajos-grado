<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="tituloPagina" value="Verificar requisitos - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="requisitos" scope="request" />
<c:set var="rolesPermitidos" value=",administrador,coordinacion,comite," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<%--
    RF-14: antes de la fase de idea se verifica que el estudiante tenga
    aprobado el 35% de creditos (90% para practica empresarial) y la
    asignatura de metodologia de la investigacion. El "cumple/no cumple" se
    calcula aqui mismo con esos dos datos, no es una columna propia.
--%>
<sql:query var="estudiantes" dataSource="${applicationScope.dsSistemaTG}">
    SELECT e.id, u.nombre_completo, u.documento_identidad, e.modalidad,
           e.porcentaje_creditos, e.metodologia_aprobada
    FROM estudiante e
    JOIN usuario u ON u.id = e.usuario_id
    WHERE u.activo = TRUE
    ORDER BY u.nombre_completo
</sql:query>

<div class="titulo-pagina">
    <h2>Verificar <span class="insignia-verde">REQUISITOS</span></h2>
</div>

<c:if test="${param.actualizado == '1'}">
    <p class="mensaje-ok">Requisitos actualizados correctamente.</p>
</c:if>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<table class="tabla-datos">
    <thead>
        <tr>
            <th>Estudiante</th>
            <th>Documento</th>
            <th>Modalidad</th>
            <th>% créditos</th>
            <th>Metodología aprobada</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="e" items="${estudiantes.rows}">
            <c:set var="umbral" value="${e.modalidad == 'practica' ? 90 : 35}" />
            <c:set var="cumple" value="${not empty e.porcentaje_creditos and e.porcentaje_creditos >= umbral and e.metodologia_aprobada}" />
            <tr>
                <td><c:out value="${e.nombre_completo}" /></td>
                <td><c:out value="${e.documento_identidad}" /></td>
                <td><c:out value="${e.modalidad}" /></td>
                <td><c:out value="${empty e.porcentaje_creditos ? '—' : e.porcentaje_creditos}" />%</td>
                <td><c:out value="${e.metodologia_aprobada ? 'Sí' : 'No'}" /></td>
                <td>
                    <c:choose>
                        <c:when test="${cumple}">
                            <span class="insignia-estado aprobada">Cumple (mín. ${umbral}%)</span>
                        </c:when>
                        <c:otherwise>
                            <span class="insignia-estado pendiente">No cumple (mín. ${umbral}%)</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <a class="boton-editar" title="Actualizar requisitos"
                       href="${pageContext.request.contextPath}/requisitos-formulario.jsp?id=${e.id}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h4L18.5 9.5a2.1 2.1 0 0 0-3-3L5 17v3Z"/><path d="M13.5 7.5l3 3"/></svg>
                    </a>
                </td>
            </tr>
        </c:forEach>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
