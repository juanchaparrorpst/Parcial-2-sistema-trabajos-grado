<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="tituloPagina" value="Propuestas Banco - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="propuestas" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<c:set var="esEstudiante" value="${sessionScope.usuarioRol == 'estudiante'}" />
<c:set var="puedeRevisar" value="${sessionScope.usuarioRol == 'comite' or sessionScope.usuarioRol == 'coordinacion'}" />

<%--
    RF-18: el titulo del proyecto se muestra al estudiante solo despues del
    pago (pg.id no vacio). py.* trae el proyecto que el comite crea al
    aprobar la propuesta (RF-11/RF-12/RF-13, Sprint 3); antes de eso
    (propuesta pendiente o con correcciones) todo eso sale vacio.
    esIntegranteSesion: el estudiante de sesion es lider o pareja de ese
    proyecto (proyecto_integrante), para saber si le toca cargar el pago.
--%>
<sql:query var="propuestas" dataSource="${applicationScope.dsSistemaTG}">
    SELECT pr.id, pr.titulo, pr.objetivo, pr.descripcion, pr.linea_investigacion, pr.estado,
           ue.nombre_completo AS estudiante_nombre, ue.id AS lider_usuario_id,
           py.id AS proyecto_id, py.consecutivo, py.anio, py.nivel,
           pg.id AS pago_id,
           (SELECT COUNT(*) FROM proyecto_integrante pi2
                JOIN estudiante e2 ON e2.id = pi2.estudiante_id
                WHERE pi2.proyecto_id = py.id AND e2.usuario_id = ?) AS es_integrante_sesion,
           (SELECT COUNT(*) FROM proyecto_integrante WHERE proyecto_id = py.id) AS num_integrantes,
           (SELECT COUNT(*) FROM documento WHERE proyecto_id = py.id AND tipo = 'pago') AS num_soportes
    FROM propuesta pr
    JOIN estudiante e ON e.id = pr.estudiante_lider_id
    JOIN usuario ue ON ue.id = e.usuario_id
    LEFT JOIN proyecto py ON py.propuesta_id = pr.id
    LEFT JOIN pago pg ON pg.proyecto_id = py.id
    ORDER BY pr.id DESC
    <sql:param value="${sessionScope.usuarioId}" />
</sql:query>

<div class="titulo-pagina">
    <h2>Propuestas <span class="insignia-verde">BANCO</span></h2>
    <c:if test="${esEstudiante}">
        <a class="boton-primario boton-nuevo" href="${pageContext.request.contextPath}/propuesta-formulario.jsp">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
            Proponer idea propia
        </a>
    </c:if>
</div>

<c:if test="${param.creada == '1'}">
    <p class="mensaje-ok">Propuesta enviada correctamente. Queda en estado Pendiente hasta que el comité la revise.</p>
</c:if>
<c:if test="${param.revisada == '1'}">
    <p class="mensaje-ok">Decisión registrada en el acta.</p>
</c:if>
<c:if test="${param.pagoRegistrado == '1'}">
    <p class="mensaje-ok">Soporte de pago enviado correctamente. El comité lo verificará antes de la sesión.</p>
</c:if>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<table class="tabla-datos">
    <thead>
        <tr>
            <th>Título</th>
            <c:if test="${!esEstudiante}"><th>Estudiante líder</th></c:if>
            <th>Línea de investigación</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="p" items="${propuestas.rows}">
            <c:if test="${!esEstudiante or p.lider_usuario_id == sessionScope.usuarioId}">
                <c:set var="tituloVisible" value="${!esEstudiante or not empty p.pago_id}" />
                <tr>
                    <td>
                        <c:choose>
                            <c:when test="${tituloVisible}"><c:out value="${p.titulo}" /></c:when>
                            <c:otherwise><em>Oculto hasta registrar el pago</em></c:otherwise>
                        </c:choose>
                    </td>
                    <c:if test="${!esEstudiante}"><td><c:out value="${p.estudiante_nombre}" /></td></c:if>
                    <td><c:out value="${p.linea_investigacion}" /></td>
                    <td>
                        <c:choose>
                            <c:when test="${p.estado == 'aprobada'}">
                                <span class="insignia-estado aprobada">Aprobada</span>
                            </c:when>
                            <c:when test="${p.estado == 'con_correcciones'}">
                                <span class="insignia-estado con-correcciones">Con correcciones</span>
                            </c:when>
                            <c:otherwise>
                                <span class="insignia-estado pendiente">Pendiente</span>
                            </c:otherwise>
                        </c:choose>
                        <c:if test="${not empty p.proyecto_id}">
                            <br><span class="ayuda">Proyecto
                            <a href="${pageContext.request.contextPath}/proyecto-detalle.jsp?id=${p.proyecto_id}">${p.consecutivo}-${p.anio}</a></span>
                        </c:if>
                    </td>
                    <td>
                        <button type="button" class="boton-ver"
                            data-titulo-modal="Detalles de la propuesta"
                            data-etq-1="Estudiante líder" data-val-1="${fn:escapeXml(p.estudiante_nombre)}"
                            data-etq-2="Título" data-val-2="${tituloVisible ? fn:escapeXml(p.titulo) : 'Oculto hasta registrar el pago'}"
                            data-etq-3="Línea de investigación" data-val-3="${fn:escapeXml(p.linea_investigacion)}"
                            data-etq-4="Objetivo" data-val-4="${fn:escapeXml(p.objetivo)}"
                            data-etq-5="Descripción" data-val-5="${fn:escapeXml(p.descripcion)}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                        </button>
                        <c:if test="${puedeRevisar and p.estado == 'pendiente'}">
                            <a class="boton-revisar" title="Revisar"
                               href="${pageContext.request.contextPath}/propuesta-revisar.jsp?id=${p.id}">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12.5l2 2 4-4.5"/><rect x="3.5" y="4" width="17" height="16" rx="2"/></svg>
                            </a>
                        </c:if>
                        <c:if test="${esEstudiante and p.es_integrante_sesion > 0 and (empty p.pago_id or p.num_soportes < p.num_integrantes)}">
                            <a class="boton-proponer" title="${empty p.pago_id ? 'Cargar soporte de pago' : 'Completar soporte de pago (falta el de tu compañero)'}"
                               href="${pageContext.request.contextPath}/pago-formulario.jsp?proyectoId=${p.proyecto_id}">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7.5h16v10a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 17.5v-10Z"/><path d="M4 10.5h16"/><path d="M7 14h4"/></svg>
                            </a>
                        </c:if>
                    </td>
                </tr>
            </c:if>
        </c:forEach>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
