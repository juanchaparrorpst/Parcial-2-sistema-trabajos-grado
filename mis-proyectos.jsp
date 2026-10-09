<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<c:set var="tituloPagina" value="Proyectos - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="proyectos" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<%--
    RF-19: cada rol ve los proyectos donde tiene algo que ver.
      - comite/coordinacion: todos (supervision general, adelanto de RF-30).
      - director/evaluador: donde esta asignado.
      - estudiante: donde es integrante.
    No hay fila "modalidad" de PQRSD ni busqueda por codigo todavia -- eso es
    RF-30, Sprint 5.
--%>
<c:choose>
    <c:when test="${sessionScope.usuarioRol == 'comite' or sessionScope.usuarioRol == 'coordinacion'}">
        <sql:query var="proyectos" dataSource="${applicationScope.dsSistemaTG}">
            SELECT py.id, py.consecutivo, py.anio, py.fase_actual, py.estado,
                   (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = py.fase_actual ORDER BY id DESC LIMIT 1) AS responsable,
                   GROUP_CONCAT(u.nombre_completo SEPARATOR ', ') AS integrantes
            FROM proyecto py
            JOIN proyecto_integrante pi ON pi.proyecto_id = py.id
            JOIN estudiante e ON e.id = pi.estudiante_id
            JOIN usuario u ON u.id = e.usuario_id
            GROUP BY py.id
            ORDER BY py.id DESC
        </sql:query>
    </c:when>
    <c:when test="${sessionScope.usuarioRol == 'director' or sessionScope.usuarioRol == 'evaluador'}">
        <sql:query var="proyectos" dataSource="${applicationScope.dsSistemaTG}">
            SELECT py.id, py.consecutivo, py.anio, py.fase_actual, py.estado,
                   (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = py.fase_actual ORDER BY id DESC LIMIT 1) AS responsable,
                   GROUP_CONCAT(u.nombre_completo SEPARATOR ', ') AS integrantes
            FROM proyecto py
            JOIN asignacion a ON a.proyecto_id = py.id
            JOIN docente d ON (d.id = a.director_id OR d.id = a.evaluador_id)
            JOIN proyecto_integrante pi ON pi.proyecto_id = py.id
            JOIN estudiante e ON e.id = pi.estudiante_id
            JOIN usuario u ON u.id = e.usuario_id
            WHERE d.usuario_id = ?
            GROUP BY py.id
            ORDER BY py.id DESC
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:query>
    </c:when>
    <c:otherwise>
        <sql:query var="proyectos" dataSource="${applicationScope.dsSistemaTG}">
            SELECT py.id, py.consecutivo, py.anio, py.fase_actual, py.estado,
                   (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = py.fase_actual ORDER BY id DESC LIMIT 1) AS responsable,
                   GROUP_CONCAT(u.nombre_completo SEPARATOR ', ') AS integrantes
            FROM proyecto py
            JOIN proyecto_integrante pi ON pi.proyecto_id = py.id
            JOIN estudiante e ON e.id = pi.estudiante_id
            JOIN usuario u ON u.id = e.usuario_id
            WHERE py.id IN (
                SELECT pi2.proyecto_id FROM proyecto_integrante pi2
                JOIN estudiante e2 ON e2.id = pi2.estudiante_id
                WHERE e2.usuario_id = ?
            )
            GROUP BY py.id
            ORDER BY py.id DESC
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:query>
    </c:otherwise>
</c:choose>

<div class="titulo-pagina">
    <h2><span class="insignia-verde">PROYECTOS</span></h2>
</div>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<table class="tabla-datos">
    <thead>
        <tr><th>Proyecto</th><th>Integrantes</th><th>Estado</th><th>Acciones</th></tr>
    </thead>
    <tbody>
        <c:forEach var="p" items="${proyectos.rows}">
            <tr>
                <td>${p.consecutivo}-${p.anio}</td>
                <td><c:out value="${p.integrantes}" /></td>
                <td>
                    <c:choose>
                        <c:when test="${p.estado == 'finalizado'}">
                            <span class="insignia-estado aprobada">Finalizado</span>
                        </c:when>
                        <c:otherwise>
                            <span class="insignia-estado pendiente">Fase ${p.fase_actual} — <c:out value="${p.responsable}" /></span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <a class="boton-ver" title="Ver proyecto" href="${pageContext.request.contextPath}/proyecto-detalle.jsp?id=${p.id}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                    </a>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${proyectos.rowCount == 0}">
            <tr><td colspan="4">No hay proyectos todavía.</td></tr>
        </c:if>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
