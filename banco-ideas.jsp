<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="tituloPagina" value="Banco de ideas - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="banco-ideas" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<c:set var="puedePublicar" value="${sessionScope.usuarioRol == 'comite' or sessionScope.usuarioRol == 'director' or sessionScope.usuarioRol == 'evaluador'}" />
<c:set var="puedeRevisar" value="${sessionScope.usuarioRol == 'comite' or sessionScope.usuarioRol == 'coordinacion'}" />
<c:set var="esEstudiante" value="${sessionScope.usuarioRol == 'estudiante'}" />

<%-- RF-06 a RF-09: banco de ideas con datos reales, filtros y detalle. --%>
<sql:query var="ideas" dataSource="${applicationScope.dsSistemaTG}">
    SELECT i.id, i.titulo, i.objetivo, i.descripcion, i.linea_investigacion, i.nivel, i.estado, i.disponible,
           p.nombre AS periodo_nombre,
           u.nombre_completo AS docente_nombre
    FROM idea i
    LEFT JOIN periodo p ON p.id = i.periodo_id
    LEFT JOIN docente d ON d.id = i.docente_id
    LEFT JOIN usuario u ON u.id = d.usuario_id
    ORDER BY i.id DESC
</sql:query>
<sql:query var="docentesConIdeas" dataSource="${applicationScope.dsSistemaTG}">
    SELECT DISTINCT u.nombre_completo
    FROM idea i JOIN docente d ON d.id = i.docente_id JOIN usuario u ON u.id = d.usuario_id
    ORDER BY u.nombre_completo
</sql:query>
<sql:query var="periodosConIdeas" dataSource="${applicationScope.dsSistemaTG}">
    SELECT DISTINCT p.nombre
    FROM idea i JOIN periodo p ON p.id = i.periodo_id
    ORDER BY p.nombre
</sql:query>

<div class="titulo-pagina">
    <h2>Banco de <span class="insignia-verde">IDEAS</span></h2>
    <c:if test="${puedePublicar}">
        <a class="boton-primario boton-nuevo" href="${pageContext.request.contextPath}/idea-formulario.jsp">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
            Publicar idea
        </a>
    </c:if>
</div>

<c:if test="${param.publicada == '1'}">
    <p class="mensaje-ok">Idea publicada correctamente, queda en estado Pendiente hasta que comité o coordinación la revisen.</p>
</c:if>
<c:if test="${param.revisada == '1'}">
    <p class="mensaje-ok">Decisión registrada en el acta.</p>
</c:if>
<c:if test="${param.propuesta == '1'}">
    <p class="mensaje-ok">Propuesta enviada correctamente.</p>
</c:if>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<div class="tabla-filtros-extra">
    <select class="tabla-filtro-extra" data-filtro-campo="docente">
        <option value="">Todos los docentes</option>
        <c:forEach var="doc" items="${docentesConIdeas.rows}">
            <option value="${fn:escapeXml(doc.nombre_completo)}"><c:out value="${doc.nombre_completo}" /></option>
        </c:forEach>
    </select>
    <select class="tabla-filtro-extra" data-filtro-campo="periodo">
        <option value="">Todos los periodos</option>
        <c:forEach var="per" items="${periodosConIdeas.rows}">
            <option value="${fn:escapeXml(per.nombre)}"><c:out value="${per.nombre}" /></option>
        </c:forEach>
    </select>
    <select class="tabla-filtro-extra" data-filtro-campo="disponible">
        <option value="">Disponible y no disponible</option>
        <option value="si">Disponible</option>
        <option value="no">No disponible</option>
    </select>
</div>
<table class="tabla-datos">
    <thead>
        <tr>
            <th>Título</th>
            <th>Docente</th>
            <th>Nivel</th>
            <th>Periodo</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="idea" items="${ideas.rows}">
            <tr data-docente="${fn:escapeXml(idea.docente_nombre)}" data-periodo="${fn:escapeXml(idea.periodo_nombre)}" data-disponible="${idea.disponible ? 'si' : 'no'}">
                <td><c:out value="${idea.titulo}" /></td>
                <td><c:out value="${idea.docente_nombre}" /></td>
                <td><c:out value="${idea.nivel}" /></td>
                <td><c:out value="${idea.periodo_nombre}" /></td>
                <td>
                    <c:choose>
                        <c:when test="${idea.estado == 'aprobada'}">
                            <span class="insignia-estado aprobada">Aprobada</span>
                        </c:when>
                        <c:when test="${idea.estado == 'con_correcciones'}">
                            <span class="insignia-estado con-correcciones">Con correcciones</span>
                        </c:when>
                        <c:otherwise>
                            <span class="insignia-estado pendiente">Pendiente</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td>
                    <button type="button" class="boton-ver"
                        data-titulo-modal="Detalles de la idea"
                        data-etq-1="Docente responsable" data-val-1="${fn:escapeXml(idea.docente_nombre)}"
                        data-etq-2="Título" data-val-2="${fn:escapeXml(idea.titulo)}"
                        data-etq-3="Línea de investigación" data-val-3="${fn:escapeXml(idea.linea_investigacion)}"
                        data-etq-4="Nivel" data-val-4="${fn:escapeXml(idea.nivel)}"
                        data-etq-5="Periodo" data-val-5="${fn:escapeXml(idea.periodo_nombre)}"
                        data-etq-6="Objetivo" data-val-6="${fn:escapeXml(idea.objetivo)}"
                        data-etq-7="Descripción" data-val-7="${fn:escapeXml(idea.descripcion)}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                    </button>
                    <c:if test="${puedeRevisar}">
                        <a class="boton-revisar" title="Revisar"
                           href="${pageContext.request.contextPath}/idea-revisar.jsp?id=${idea.id}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12.5l2 2 4-4.5"/><rect x="3.5" y="4" width="17" height="16" rx="2"/></svg>
                        </a>
                    </c:if>
                    <c:if test="${esEstudiante and idea.disponible}">
                        <a class="boton-proponer" title="Proponer con esta idea"
                           href="${pageContext.request.contextPath}/propuesta-formulario.jsp?ideaId=${idea.id}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
                        </a>
                    </c:if>
                </td>
            </tr>
        </c:forEach>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
