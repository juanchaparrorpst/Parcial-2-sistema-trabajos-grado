<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<c:set var="tituloPagina" value="Mi perfil - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="perfil" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<sql:query var="perfil" dataSource="${applicationScope.dsSistemaTG}">
    SELECT u.nombre_completo, u.correo, u.documento_identidad, u.rol,
           e.modalidad, e.es_pareja, e.porcentaje_creditos, e.metodologia_aprobada,
           d.tipo_vinculacion, d.linea_investigacion
    FROM usuario u
    LEFT JOIN estudiante e ON e.usuario_id = u.id
    LEFT JOIN docente d ON d.usuario_id = u.id
    WHERE u.id = ?
    <sql:param value="${sessionScope.usuarioId}" />
</sql:query>
<c:set var="p" value="${perfil.rows[0]}" />
<c:set var="umbralRequisitos" value="${p.modalidad == 'practica' ? 90 : 35}" />
<c:set var="cumpleRequisitos" value="${not empty p.porcentaje_creditos and p.porcentaje_creditos >= umbralRequisitos and p.metodologia_aprobada}" />

<div class="titulo-pagina">
    <h2>Mi <span class="insignia-verde">PERFIL</span></h2>
</div>

<dl class="tarjeta-info">
    <dt>Nombre completo</dt>
    <dd><c:out value="${p.nombre_completo}" /></dd>

    <dt>Correo electrónico</dt>
    <dd><c:out value="${p.correo}" /></dd>

    <dt>Documento de identidad</dt>
    <dd><c:out value="${p.documento_identidad}" /></dd>

    <dt>Rol</dt>
    <dd><c:out value="${p.rol}" /></dd>

    <c:if test="${p.rol == 'estudiante'}">
        <dt>Modalidad</dt>
        <dd><c:out value="${p.modalidad}" /></dd>
        <dt>¿Individual o en pareja?</dt>
        <dd><c:out value="${p.es_pareja ? 'Pareja' : 'Individual'}" /></dd>
        <dt>Requisitos de ingreso (RF-14)</dt>
        <dd>
            <c:out value="${empty p.porcentaje_creditos ? 'Sin registrar' : p.porcentaje_creditos}" />% de créditos,
            metodología <c:out value="${p.metodologia_aprobada ? 'aprobada' : 'sin aprobar'}" />
            —
            <c:choose>
                <c:when test="${cumpleRequisitos}">
                    <span class="insignia-estado aprobada">Cumple</span>
                </c:when>
                <c:otherwise>
                    <span class="insignia-estado pendiente">No cumple (mín. ${umbralRequisitos}%)</span>
                </c:otherwise>
            </c:choose>
        </dd>
    </c:if>
    <c:if test="${p.rol == 'comite' or p.rol == 'director' or p.rol == 'evaluador'}">
        <dt>Tipo de vinculación</dt>
        <dd><c:out value="${p.tipo_vinculacion}" /></dd>
        <dt>Línea de investigación</dt>
        <dd><c:out value="${p.linea_investigacion}" /></dd>
    </c:if>
</dl>

<jsp:include page="/WEB-INF/cierre.jsp" />
