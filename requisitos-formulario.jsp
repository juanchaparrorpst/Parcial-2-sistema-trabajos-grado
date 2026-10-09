<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Igual que usuario-formulario.jsp: se busca el registro ANTES de incluir
     menu.jsp, porque un <jsp:forward> ya con HTML escrito no tiene efecto. --%>
<sql:query var="resultado" dataSource="${applicationScope.dsSistemaTG}">
    SELECT e.id, u.nombre_completo, e.modalidad, e.porcentaje_creditos, e.metodologia_aprobada
    FROM estudiante e
    JOIN usuario u ON u.id = e.usuario_id
    WHERE e.id = ?
    <sql:param value="${param.id}" />
</sql:query>
<c:if test="${resultado.rowCount == 0}">
    <jsp:forward page="/verificar-requisitos.jsp" />
</c:if>
<c:set var="e" value="${resultado.rows[0]}" />
<c:set var="umbral" value="${e.modalidad == 'practica' ? 90 : 35}" />

<c:set var="tituloPagina" value="Verificar requisitos - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="requisitos" scope="request" />
<c:set var="rolesPermitidos" value=",administrador,coordinacion,comite," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Requisitos de <span class="insignia-verde">INGRESO</span></h2>
</div>

<div class="tabla-contenedor">
    <p class="ayuda" style="margin-bottom:16px;">
        <strong><c:out value="${e.nombre_completo}" /></strong> — modalidad <c:out value="${e.modalidad}" />.
        Umbral requerido: <strong>${umbral}%</strong> de créditos aprobados
        (90% es solo para práctica empresarial, 35% para las demás modalidades).
    </p>

    <form method="post" action="${pageContext.request.contextPath}/procesar-requisitos.jsp" class="formulario-rejilla">
        <input type="hidden" name="id" value="${e.id}">

        <div class="campo-formulario">
            <label for="porcentajeCreditos">% de créditos aprobados</label>
            <input type="number" id="porcentajeCreditos" name="porcentajeCreditos" min="0" max="100" step="0.01" required
                   value="${e.porcentaje_creditos}">
        </div>

        <div class="campo-formulario">
            <label class="campo-casilla">
                <input type="checkbox" id="metodologiaAprobada" name="metodologiaAprobada" value="true" ${e.metodologia_aprobada ? 'checked' : ''}>
                Metodología de la investigación aprobada
            </label>
        </div>

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Guardar</button>
            <a href="${pageContext.request.contextPath}/verificar-requisitos.jsp" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
