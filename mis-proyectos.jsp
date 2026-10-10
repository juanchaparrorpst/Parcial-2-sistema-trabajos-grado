<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="tituloPagina" value="Proyectos - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="proyectos" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<%--
    RF-19: cada rol ve los proyectos donde tiene algo que ver.
      - comite/coordinacion: todos (supervision general, RF-30).
      - director/evaluador: donde esta asignado.
      - estudiante: donde es integrante.
--%>
<c:set var="esSupervisor" value="${sessionScope.usuarioRol == 'comite' or sessionScope.usuarioRol == 'coordinacion'}" />

<%--
    RF-30: buscar cualquier proyecto por codigo de estudiante (documento de
    identidad) o nombre. Es una consulta SQL filtrada en el servidor (no un
    filtro de tabla en el navegador) para que la respuesta no dependa de
    cuantos proyectos haya cargados en esa pagina -- importante para RNF-08
    (respuesta en menos de 3 segundos con 400 estudiantes). Las columnas de
    busqueda (usuario.nombre_completo, usuario.documento_identidad) tienen
    indice -- ver sql/01_esquema.sql.
--%>
<c:if test="${esSupervisor and not empty param.q}">
    <sql:query var="resultadoBusqueda" dataSource="${applicationScope.dsSistemaTG}">
        SELECT DISTINCT py.id, py.consecutivo, py.anio, py.fase_actual, py.estado,
               (SELECT estado FROM historial_fase WHERE proyecto_id = py.id AND fase = py.fase_actual ORDER BY id DESC LIMIT 1) AS responsable_fase,
               dd.nombre_completo AS director_nombre,
               de.nombre_completo AS evaluador_nombre
        FROM proyecto py
        JOIN proyecto_integrante pi ON pi.proyecto_id = py.id
        JOIN estudiante est ON est.id = pi.estudiante_id
        JOIN usuario u ON u.id = est.usuario_id
        LEFT JOIN asignacion a ON a.proyecto_id = py.id
        LEFT JOIN docente ddoc ON ddoc.id = a.director_id
        LEFT JOIN usuario dd ON dd.id = ddoc.usuario_id
        LEFT JOIN docente edoc ON edoc.id = a.evaluador_id
        LEFT JOIN usuario de ON de.id = edoc.usuario_id
        WHERE u.nombre_completo LIKE ? OR u.documento_identidad LIKE ?
        ORDER BY py.id DESC
        <sql:param value="%${param.q}%" />
        <sql:param value="%${param.q}%" />
    </sql:query>
</c:if>

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

<%-- RF-30: supervision general. Coordinacion tiene permiso "Si" (ademas de
     ver todos abajo, puede buscar); comite tiene "Consulta" sobre esto mismo
     -- ambos ven el mismo buscador, ninguno modifica nada desde aqui. --%>
<c:if test="${esSupervisor}">
    <form method="get" action="${pageContext.request.contextPath}/mis-proyectos.jsp" class="formulario-busqueda-proyecto">
        <label for="campoQ">Buscar proyecto por nombre o documento de identidad del estudiante</label>
        <div class="formulario-busqueda-proyecto-fila">
            <input type="text" id="campoQ" name="q" value="${fn:escapeXml(param.q)}" placeholder="Ej: Juan Pérez o 1091234567">
            <button type="submit" class="boton-primario">Buscar</button>
            <c:if test="${not empty param.q}">
                <a class="boton-secundario" href="${pageContext.request.contextPath}/mis-proyectos.jsp">Limpiar</a>
            </c:if>
        </div>
    </form>

    <c:if test="${not empty param.q}">
        <h3 style="margin:18px 0 10px;">Resultado de la búsqueda (${resultadoBusqueda.rowCount})</h3>
        <div class="tabla-contenedor" style="margin-bottom:24px;">
            <table class="tabla-datos">
                <thead>
                    <tr><th>Proyecto</th><th>Fase</th><th>Director</th><th>Evaluador</th><th>Acciones</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${resultadoBusqueda.rows}">
                        <tr>
                            <td>${r.consecutivo}-${r.anio}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.estado == 'finalizado'}">
                                        <span class="insignia-estado aprobada">Finalizado</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="insignia-estado pendiente">Fase ${r.fase_actual} — <c:out value="${r.responsable_fase}" /></span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${empty r.director_nombre ? 'Sin asignar' : r.director_nombre}" /></td>
                            <td><c:out value="${empty r.evaluador_nombre ? 'Sin asignar' : r.evaluador_nombre}" /></td>
                            <td>
                                <a class="boton-ver" title="Ver proyecto" href="${pageContext.request.contextPath}/proyecto-detalle.jsp?id=${r.id}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${resultadoBusqueda.rowCount == 0}">
                        <tr><td colspan="5">Ningún proyecto coincide con esa búsqueda.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </c:if>

    <h3 style="margin:18px 0 10px;">Todos los proyectos del sistema</h3>
</c:if>

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
