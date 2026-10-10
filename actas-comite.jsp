<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="tituloPagina" value="Actas del comite - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="actas-comite" scope="request" />
<%-- RF-32: comite = "Si" y coordinacion = "Consulta" en la matriz de permisos
     (seccion 2.2), pero ninguno de los dos edita un acta desde aqui -- el
     criterio de aceptacion dice "una acta cerrada no se puede modificar
     desde la interfaz". Por eso es la misma pantalla de solo consulta para
     ambos roles, sin ningun formulario. --%>
<c:set var="rolesPermitidos" value=",comite,coordinacion," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<%--
    acta.idea_id / acta.propuesta_id: cada acta corresponde a una decision de
    idea (Sprint 2) o de propuesta (Sprint 3), nunca a ambas -- se arman con
    UNION para tener una sola lista numerada. El numero de acta es
    consecutivo global (ver procesar-idea-estado.jsp / procesar-propuesta-estado.jsp).
--%>
<sql:query var="actas" dataSource="${applicationScope.dsSistemaTG}">
    SELECT a.numero, a.fecha, a.decision, a.motivo,
           'Idea' AS tipo, i.titulo AS titulo
    FROM acta a
    JOIN idea i ON i.id = a.idea_id
    WHERE a.idea_id IS NOT NULL
    UNION ALL
    SELECT a.numero, a.fecha, a.decision, a.motivo,
           'Propuesta' AS tipo, p.titulo AS titulo
    FROM acta a
    JOIN propuesta p ON p.id = a.propuesta_id
    WHERE a.propuesta_id IS NOT NULL
    ORDER BY numero DESC
</sql:query>

<div class="titulo-pagina">
    <h2>Actas del <span class="insignia-verde">COMITÉ</span></h2>
</div>
<p class="ayuda" style="margin-bottom:16px;">
    Registro de cada decisión tomada en sesión del comité: número de acta, fecha, decisión y motivo. Una acta no se puede modificar desde esta pantalla.
</p>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<div style="margin-bottom:12px; display:flex; gap:10px; flex-wrap:wrap;">
    <select class="tabla-filtro-extra" data-filtro-campo="tipo">
        <option value="">Tipo: todos</option>
        <option value="Idea">Idea</option>
        <option value="Propuesta">Propuesta</option>
    </select>
    <select class="tabla-filtro-extra" data-filtro-campo="decision">
        <option value="">Decisión: todas</option>
        <option value="aprobada">Aprobada</option>
        <option value="con_correcciones">Con correcciones</option>
        <option value="pendiente">Pendiente</option>
    </select>
</div>
<table class="tabla-datos">
    <thead>
        <tr>
            <th>N.º acta</th>
            <th>Fecha</th>
            <th>Tipo</th>
            <th>Título</th>
            <th>Decisión</th>
            <th>Motivo</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="a" items="${actas.rows}">
            <tr data-tipo="${a.tipo}" data-decision="${a.decision}">
                <td>${a.numero}</td>
                <td><fmt:formatDate value="${a.fecha}" pattern="dd/MM/yyyy" /></td>
                <td><c:out value="${a.tipo}" /></td>
                <td><c:out value="${a.titulo}" /></td>
                <td>
                    <c:choose>
                        <c:when test="${a.decision == 'aprobada'}">
                            <span class="insignia-estado aprobada">Aprobada</span>
                        </c:when>
                        <c:when test="${a.decision == 'con_correcciones'}">
                            <span class="insignia-estado con-correcciones">Con correcciones</span>
                        </c:when>
                        <c:otherwise>
                            <span class="insignia-estado pendiente">Pendiente</span>
                        </c:otherwise>
                    </c:choose>
                </td>
                <td><c:out value="${a.motivo}" /></td>
            </tr>
        </c:forEach>
        <c:if test="${actas.rowCount == 0}">
            <tr><td colspan="6">Todavía no hay actas registradas.</td></tr>
        </c:if>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
