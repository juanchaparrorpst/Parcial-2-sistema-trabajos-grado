<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<c:set var="tituloPagina" value="Historico de proyectos - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="historico" scope="request" />
<%-- RF-35: "Como docente y comité, quiero consultar proyectos anteriores".
     Se interpreta "docente" como director o evaluador (los dos roles de
     seguimiento que existen en el sistema); comite y coordinacion entran
     por su rol de supervision general (RF-30/RF-31). No incluye
     administrador ni estudiante -- no estan en la historia de usuario. --%>
<c:set var="rolesPermitidos" value=",comite,coordinacion,director,evaluador," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- RF-35: "el historico muestra solo proyectos cerrados" (estado = finalizado). --%>
<sql:query var="historico" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.modalidad, pr.titulo AS titulo,
           ud.nombre_completo AS director_nombre,
           GROUP_CONCAT(DISTINCT ue.nombre_completo SEPARATOR ', ') AS integrantes
    FROM proyecto py
    JOIN propuesta pr ON pr.id = py.propuesta_id
    LEFT JOIN asignacion a ON a.proyecto_id = py.id
    LEFT JOIN docente dd ON dd.id = a.director_id
    LEFT JOIN usuario ud ON ud.id = dd.usuario_id
    JOIN proyecto_integrante pi ON pi.proyecto_id = py.id
    JOIN estudiante est ON est.id = pi.estudiante_id
    JOIN usuario ue ON ue.id = est.usuario_id
    WHERE py.estado = 'finalizado'
    GROUP BY py.id
    ORDER BY py.anio DESC, py.consecutivo DESC
</sql:query>

<sql:query var="anios" dataSource="${applicationScope.dsSistemaTG}">
    SELECT DISTINCT anio FROM proyecto WHERE estado = 'finalizado' ORDER BY anio DESC
</sql:query>
<sql:query var="modalidades" dataSource="${applicationScope.dsSistemaTG}">
    SELECT DISTINCT modalidad FROM proyecto WHERE estado = 'finalizado' AND modalidad IS NOT NULL ORDER BY modalidad
</sql:query>
<sql:query var="directores" dataSource="${applicationScope.dsSistemaTG}">
    SELECT DISTINCT u.nombre_completo
    FROM proyecto py
    JOIN asignacion a ON a.proyecto_id = py.id
    JOIN docente d ON d.id = a.director_id
    JOIN usuario u ON u.id = d.usuario_id
    WHERE py.estado = 'finalizado'
    ORDER BY u.nombre_completo
</sql:query>

<div class="titulo-pagina">
    <h2>Histórico de <span class="insignia-verde">PROYECTOS</span></h2>
</div>
<p class="ayuda" style="margin-bottom:16px;">
    Proyectos ya cerrados, para consultar temas anteriores y evitar repetirlos (RF-28). Solo se muestran los proyectos en estado "Finalizado".
</p>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<div style="margin-bottom:12px; display:flex; gap:10px; flex-wrap:wrap;">
    <select class="tabla-filtro-extra" data-filtro-campo="anio">
        <option value="">Año: todos</option>
        <c:forEach var="a" items="${anios.rows}">
            <option value="${a.anio}">${a.anio}</option>
        </c:forEach>
    </select>
    <select class="tabla-filtro-extra" data-filtro-campo="modalidad">
        <option value="">Modalidad: todas</option>
        <c:forEach var="m" items="${modalidades.rows}">
            <option value="${m.modalidad}"><c:out value="${m.modalidad}" /></option>
        </c:forEach>
    </select>
    <select class="tabla-filtro-extra" data-filtro-campo="docente">
        <option value="">Director: todos</option>
        <c:forEach var="d" items="${directores.rows}">
            <option value="${d.nombre_completo}"><c:out value="${d.nombre_completo}" /></option>
        </c:forEach>
    </select>
</div>
<table class="tabla-datos">
    <thead>
        <tr>
            <th>Proyecto</th>
            <th>Título</th>
            <th>Modalidad</th>
            <th>Director</th>
            <th>Integrantes</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="p" items="${historico.rows}">
            <tr data-anio="${p.anio}" data-modalidad="${p.modalidad}" data-docente="${p.director_nombre}">
                <td>${p.consecutivo}-${p.anio}</td>
                <td><c:out value="${p.titulo}" /></td>
                <td><c:out value="${p.modalidad}" /></td>
                <td><c:out value="${empty p.director_nombre ? 'Sin asignar' : p.director_nombre}" /></td>
                <td><c:out value="${p.integrantes}" /></td>
            </tr>
        </c:forEach>
        <c:if test="${historico.rowCount == 0}">
            <tr><td colspan="5">Todavía no hay proyectos cerrados.</td></tr>
        </c:if>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
