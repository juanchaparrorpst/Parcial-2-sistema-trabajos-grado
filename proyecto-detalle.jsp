<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Igual que en otras paginas de detalle: se busca el proyecto y se valida
     el acceso ANTES de incluir menu.jsp (un redirect con la pagina ya
     escrita no tiene efecto). --%>
<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.nivel, py.modalidad, py.fase_actual, py.estado,
           pr.titulo, pr.id AS propuesta_id,
           a.director_id, du.nombre_completo AS director_nombre,
           a.evaluador_id, eu.nombre_completo AS evaluador_nombre,
           a.codirector_id, cu.nombre_completo AS codirector_nombre
    FROM proyecto py
    LEFT JOIN propuesta pr ON pr.id = py.propuesta_id
    LEFT JOIN asignacion a ON a.proyecto_id = py.id
    LEFT JOIN docente dd ON dd.id = a.director_id LEFT JOIN usuario du ON du.id = dd.usuario_id
    LEFT JOIN docente de ON de.id = a.evaluador_id LEFT JOIN usuario eu ON eu.id = de.usuario_id
    LEFT JOIN docente dc ON dc.id = a.codirector_id LEFT JOIN usuario cu ON cu.id = dc.usuario_id
    WHERE py.id = ?
    <sql:param value="${param.id}" />
</sql:query>
<c:if test="${resultadoProyecto.rowCount == 0}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="p" value="${resultadoProyecto.rows[0]}" />

<sql:query var="resultadoIntegrantes" dataSource="${applicationScope.dsSistemaTG}">
    SELECT u.id AS usuario_id, u.nombre_completo, pi.es_lider
    FROM proyecto_integrante pi JOIN estudiante e ON e.id = pi.estudiante_id JOIN usuario u ON u.id = e.usuario_id
    WHERE pi.proyecto_id = ?
    ORDER BY pi.es_lider DESC
    <sql:param value="${param.id}" />
</sql:query>

<%-- Permisos: estudiante integrante, director/evaluador/codirector asignados,
     o comite/coordinacion (supervision general). Nadie mas puede entrar --
     ni siquiera otro estudiante (CP-07, RNF-03). --%>
<c:set var="esIntegrante" value="${false}" />
<c:forEach var="i" items="${resultadoIntegrantes.rows}">
    <c:if test="${i.usuario_id == sessionScope.usuarioId}"><c:set var="esIntegrante" value="${true}" /></c:if>
</c:forEach>
<sql:query var="resultadoDocenteSesion" dataSource="${applicationScope.dsSistemaTG}">
    SELECT id FROM docente WHERE usuario_id = ?
    <sql:param value="${sessionScope.usuarioId}" />
</sql:query>
<c:set var="docenteSesionId" value="${resultadoDocenteSesion.rowCount > 0 ? resultadoDocenteSesion.rows[0].id : -1}" />
<c:set var="esDirector" value="${p.director_id == docenteSesionId}" scope="request" />
<c:set var="esEvaluador" value="${p.evaluador_id == docenteSesionId}" scope="request" />
<c:set var="esCodirector" value="${p.codirector_id == docenteSesionId}" />
<c:set var="esComiteCoord" value="${sessionScope.usuarioRol == 'comite' or sessionScope.usuarioRol == 'coordinacion'}" scope="request" />
<c:if test="${!esIntegrante and !esDirector and !esEvaluador and !esCodirector and !esComiteCoord}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="esEstudianteSesion" value="${sessionScope.usuarioRol == 'estudiante'}" />
<%-- RF-27: el evaluador no se muestra al estudiante. --%>
<c:set var="verEvaluador" value="${!esEstudianteSesion}" />
<c:set var="esLiderSesion" value="${false}" scope="request" />
<c:forEach var="i" items="${resultadoIntegrantes.rows}">
    <c:if test="${i.usuario_id == sessionScope.usuarioId and i.es_lider}"><c:set var="esLiderSesion" value="${true}" scope="request" /></c:if>
</c:forEach>
<c:set var="esIntegrante" value="${esIntegrante}" scope="request" />
<c:set var="proyectoId" value="${param.id}" scope="request" />
<c:set var="faseActual" value="${p.fase_actual}" scope="request" />
<c:set var="estadoProyecto" value="${p.estado}" scope="request" />

<c:set var="tituloPagina" value="Proyecto ${p.consecutivo}-${p.anio} - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="proyectos" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<%-- RF-19: etiqueta de estado = fase + responsable (seccion 3.3 del documento). --%>
<sql:query var="resultadoResponsable" dataSource="${applicationScope.dsSistemaTG}">
    SELECT estado FROM historial_fase WHERE proyecto_id = ? AND fase = ? ORDER BY id DESC LIMIT 1
    <sql:param value="${param.id}" />
    <sql:param value="${p.fase_actual}" />
</sql:query>
<c:set var="responsableActual" value="${resultadoResponsable.rowCount > 0 ? resultadoResponsable.rows[0].estado : 'por definir'}" scope="request" />
<c:set var="nombresFase" value="Idea,Propuesta,Informe y envío,Documentos importantes,Por definir,Cierre" />

<%-- RF-21/3.3: numero de revision = cuantas veces se subio el formato 124. --%>
<sql:query var="resultadoRevision" dataSource="${applicationScope.dsSistemaTG}">
    SELECT COUNT(*) AS total FROM documento WHERE proyecto_id = ? AND tipo = 'F-DC-124'
    <sql:param value="${param.id}" />
</sql:query>
<c:set var="revisionActual" value="${resultadoRevision.rows[0].total}" />

<div class="titulo-pagina">
    <h2>Proyecto <span class="insignia-verde">${p.consecutivo}-${p.anio}</span></h2>
</div>

<c:if test="${param.ok == '1'}"><p class="mensaje-ok">Acción registrada correctamente.</p></c:if>
<c:if test="${param.error == '1'}"><p class="mensaje-error">Faltan datos obligatorios o el archivo no es válido (RNF-11: solo Word o PDF).</p></c:if>

<dl class="tarjeta-info" style="margin-bottom:20px;">
    <dt>Título</dt>
    <dd><c:out value="${p.titulo}" /></dd>
    <dt>Nivel / Modalidad</dt>
    <dd><c:out value="${p.nivel}" /> / <c:out value="${p.modalidad}" /></dd>
    <dt>Integrantes</dt>
    <dd>
        <c:forEach var="i" items="${resultadoIntegrantes.rows}" varStatus="st">
            <c:out value="${i.nombre_completo}" />${i.es_lider ? ' (líder)' : ' (pareja)'}<c:if test="${!st.last}">, </c:if>
        </c:forEach>
    </dd>
    <dt>Director</dt>
    <dd><c:out value="${p.director_nombre}" /></dd>
    <c:if test="${verEvaluador}">
        <dt>Evaluador</dt>
        <dd><c:out value="${p.evaluador_nombre}" /></dd>
    </c:if>
    <c:if test="${not empty p.codirector_nombre}">
        <dt>Codirector</dt>
        <dd><c:out value="${p.codirector_nombre}" /></dd>
    </c:if>
    <dt>Estado actual</dt>
    <dd>
        <c:choose>
            <c:when test="${p.estado == 'finalizado'}">
                <span class="insignia-estado aprobada">Finalizado</span>
            </c:when>
            <c:otherwise>
                <span class="insignia-estado pendiente">Fase ${p.fase_actual} — <c:out value="${responsableActual}" /></span>
                <c:if test="${revisionActual > 1 and p.fase_actual == 2}"> (revisión ${revisionActual})</c:if>
            </c:otherwise>
        </c:choose>
    </dd>
</dl>

<%-- RF-20: historial de fases, cumplidas en verde, pendientes sin marcar. --%>
<h3 style="margin-bottom:10px;">Historial de fases</h3>
<div class="tabla-contenedor" style="margin-bottom:20px;">
    <table class="tabla-datos">
        <thead><tr><th>Fase</th><th>Nombre</th><th>Estado</th></tr></thead>
        <tbody>
            <c:forEach begin="1" end="6" var="numFase">
                <tr>
                    <td>${numFase}</td>
                    <td><c:out value="${fn:split(nombresFase, ',')[numFase-1]}" /></td>
                    <td>
                        <c:choose>
                            <c:when test="${numFase < p.fase_actual or p.estado == 'finalizado'}">
                                <span class="insignia-estado aprobada">Cumplida</span>
                            </c:when>
                            <c:when test="${numFase == p.fase_actual}">
                                <span class="insignia-estado con-correcciones">En curso — <c:out value="${responsableActual}" /></span>
                            </c:when>
                            <c:otherwise>
                                <span class="ayuda">Sin marcar</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<jsp:include page="/WEB-INF/proyecto-acciones.jsp" />

<%-- RF-26: consulta de correcciones, documentos cargados por el director o el
     evaluador. La fecha se formatea en el SQL (DATE_FORMAT): el driver de
     MySQL devuelve las columnas DATETIME como java.time.LocalDateTime, que
     <fmt:formatDate> no puede convertir. --%>
<sql:query var="correcciones" dataSource="${applicationScope.dsSistemaTG}">
    SELECT d.archivo, d.formato, DATE_FORMAT(d.fecha, '%d/%m/%Y %H:%i') AS fecha_formateada, u.nombre_completo AS autor
    FROM documento d LEFT JOIN usuario u ON u.id = d.usuario_id
    WHERE d.proyecto_id = ? AND d.tipo = 'correcciones'
    ORDER BY d.fecha DESC
    <sql:param value="${param.id}" />
</sql:query>
<c:if test="${correcciones.rowCount > 0}">
    <h3 style="margin: 20px 0 10px;">Correcciones</h3>
    <div class="tabla-contenedor">
        <table class="tabla-datos">
            <thead><tr><th>Fecha</th><th>De</th><th>Documento</th></tr></thead>
            <tbody>
                <c:forEach var="c" items="${correcciones.rows}">
                    <tr>
                        <td><c:out value="${c.fecha_formateada}" /></td>
                        <td><c:out value="${c.autor}" /></td>
                        <td><a href="${pageContext.request.contextPath}/uploads/${c.archivo}" target="_blank">Ver documento (${c.formato})</a></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</c:if>

<jsp:include page="/WEB-INF/cierre.jsp" />
