<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="tituloPagina" value="Calendario academico - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="calendario" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<c:set var="puedeConfigurar" value="${sessionScope.usuarioRol == 'comite' or sessionScope.usuarioRol == 'coordinacion'}" />

<%-- RF-05: periodos academicos. El estado (activo/proximo/finalizado) se
     calcula en SQL con CURDATE(), no en Java. --%>
<sql:query var="periodos" dataSource="${applicationScope.dsSistemaTG}">
    SELECT id, nombre, fecha_inicio, fecha_fin, modulo,
        CASE
            WHEN CURDATE() BETWEEN fecha_inicio AND fecha_fin THEN 'activo'
            WHEN CURDATE() < fecha_inicio THEN 'proximo'
            ELSE 'finalizado'
        END AS estado_calculado
    FROM periodo
    ORDER BY fecha_inicio DESC
</sql:query>

<div class="titulo-pagina">
    <h2>Calendario <span class="insignia-verde">ACADÉMICO</span></h2>
    <c:if test="${puedeConfigurar}">
        <a class="boton-primario boton-nuevo" href="${pageContext.request.contextPath}/periodo-formulario.jsp">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
            Nuevo periodo
        </a>
    </c:if>
</div>

<c:if test="${param.creado == '1'}">
    <p class="mensaje-ok">Periodo creado correctamente.</p>
</c:if>
<c:if test="${!puedeConfigurar}">
    <p class="campo-formulario ayuda" style="margin-bottom:16px;">Solo comité o coordinación pueden crear o modificar periodos. Esta vista es de consulta.</p>
</c:if>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<table class="tabla-datos">
    <thead>
        <tr>
            <th>Nombre</th>
            <th>Módulo</th>
            <th>Fecha inicio</th>
            <th>Fecha fin</th>
            <th>Estado</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="p" items="${periodos.rows}">
            <tr>
                <td><c:out value="${p.nombre}" /></td>
                <td><c:out value="${p.modulo}" /></td>
                <td><fmt:formatDate value="${p.fecha_inicio}" pattern="dd/MM/yyyy" /></td>
                <td><fmt:formatDate value="${p.fecha_fin}" pattern="dd/MM/yyyy" /></td>
                <td>
                    <c:choose>
                        <c:when test="${p.estado_calculado == 'activo'}">
                            <span class="insignia-estado aprobada">Activo</span>
                        </c:when>
                        <c:when test="${p.estado_calculado == 'proximo'}">
                            <span class="insignia-estado pendiente">Próximo</span>
                        </c:when>
                        <c:otherwise>
                            <span class="insignia-estado con-correcciones">Finalizado</span>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </c:forEach>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
