<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="tituloPagina" value="Propuestas Banco - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="propuestas" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<c:set var="esEstudiante" value="${sessionScope.usuarioRol == 'estudiante'}" />

<%--
    RF-18: el titulo del proyecto se muestra al estudiante solo despues del
    pago. El pago se registra sobre un "proyecto" (tabla proyecto), que
    recien se crea cuando el comite aprueba la propuesta (RF-11, Sprint 3);
    por ahora pago_id siempre sale vacio y el titulo queda oculto para el
    estudiante, tal como corresponde antes de que exista ese flujo.
--%>
<sql:query var="propuestas" dataSource="${applicationScope.dsSistemaTG}">
    SELECT pr.id, pr.titulo, pr.objetivo, pr.descripcion, pr.linea_investigacion, pr.estado,
           ue.nombre_completo AS estudiante_nombre, ue.id AS lider_usuario_id,
           pg.id AS pago_id
    FROM propuesta pr
    JOIN estudiante e ON e.id = pr.estudiante_lider_id
    JOIN usuario ue ON ue.id = e.usuario_id
    LEFT JOIN proyecto py ON py.propuesta_id = pr.id
    LEFT JOIN pago pg ON pg.proyecto_id = py.id
    ORDER BY pr.id DESC
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
                    </td>
                </tr>
            </c:if>
        </c:forEach>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
