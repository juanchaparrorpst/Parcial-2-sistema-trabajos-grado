<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Esta comprobacion va antes de incluir menu.jsp, igual que en
     usuario-formulario.jsp: si se redirige con la pagina ya escrita, el
     redirect no tiene efecto. --%>
<sql:query var="resultadoIdea" dataSource="${applicationScope.dsSistemaTG}">
    SELECT i.id, i.titulo, i.objetivo, i.descripcion, i.linea_investigacion, i.nivel, i.estado,
           p.nombre AS periodo_nombre, u.nombre_completo AS docente_nombre
    FROM idea i
    LEFT JOIN periodo p ON p.id = i.periodo_id
    LEFT JOIN docente d ON d.id = i.docente_id
    LEFT JOIN usuario u ON u.id = d.usuario_id
    WHERE i.id = ?
    <sql:param value="${param.id}" />
</sql:query>
<c:if test="${resultadoIdea.rowCount == 0}">
    <jsp:forward page="/banco-ideas.jsp" />
</c:if>
<c:set var="idea" value="${resultadoIdea.rows[0]}" />

<c:set var="tituloPagina" value="Revisar idea - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="banco-ideas" scope="request" />
<c:set var="rolesPermitidos" value=",comite,coordinacion," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Revisar <span class="insignia-verde">IDEA</span></h2>
</div>

<dl class="tarjeta-info" style="margin-bottom:20px;">
    <dt>Título</dt>
    <dd><c:out value="${idea.titulo}" /></dd>
    <dt>Docente responsable</dt>
    <dd><c:out value="${idea.docente_nombre}" /></dd>
    <dt>Línea de investigación</dt>
    <dd><c:out value="${idea.linea_investigacion}" /></dd>
    <dt>Nivel</dt>
    <dd><c:out value="${idea.nivel}" /></dd>
    <dt>Periodo</dt>
    <dd><c:out value="${idea.periodo_nombre}" /></dd>
    <dt>Objetivo</dt>
    <dd><c:out value="${idea.objetivo}" /></dd>
    <dt>Descripción</dt>
    <dd><c:out value="${idea.descripcion}" /></dd>
    <dt>Estado actual</dt>
    <dd><c:out value="${idea.estado}" /></dd>
</dl>

<div class="tabla-contenedor">
    <form method="post" action="${pageContext.request.contextPath}/procesar-idea-estado.jsp">
        <input type="hidden" name="ideaId" value="${idea.id}">

        <div class="campo-formulario">
            <label for="decision">Decisión</label>
            <select id="decision" name="decision" required>
                <option value="aprobada">Aprobada</option>
                <option value="con_correcciones">Con correcciones</option>
                <option value="pendiente">Pendiente</option>
            </select>
        </div>

        <div class="campo-formulario">
            <label for="motivo">Motivo</label>
            <input type="text" id="motivo" name="motivo" required placeholder="Motivo de la decisión, para el acta">
        </div>

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Registrar decisión</button>
            <a href="${pageContext.request.contextPath}/banco-ideas.jsp" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
