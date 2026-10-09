<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- RF-14: antes de la fase de idea se verifica 35%/90% de creditos y
     metodologia de la investigacion aprobada. Se revalida en el servidor
     en procesar-propuesta.jsp por si se evita este chequeo. --%>
<sql:query var="resultadoRequisitos" dataSource="${applicationScope.dsSistemaTG}">
    SELECT modalidad, porcentaje_creditos, metodologia_aprobada
    FROM estudiante WHERE usuario_id = ?
    <sql:param value="${sessionScope.usuarioId}" />
</sql:query>
<c:set var="estudianteSesion" value="${resultadoRequisitos.rows[0]}" />
<c:set var="umbralRequisitos" value="${estudianteSesion.modalidad == 'practica' ? 90 : 35}" />
<c:set var="cumpleRequisitos" value="${not empty estudianteSesion.porcentaje_creditos and estudianteSesion.porcentaje_creditos >= umbralRequisitos and estudianteSesion.metodologia_aprobada}" />

<c:set var="tieneIdeaBase" value="${not empty param.ideaId}" />

<%-- Si viene de "Proponer con esta idea" en el banco, se precarga esa idea. --%>
<c:if test="${tieneIdeaBase}">
    <sql:query var="resultadoIdea" dataSource="${applicationScope.dsSistemaTG}">
        SELECT i.id, i.titulo, i.objetivo, i.descripcion, i.linea_investigacion, i.disponible,
               u.nombre_completo AS docente_nombre
        FROM idea i
        LEFT JOIN docente d ON d.id = i.docente_id
        LEFT JOIN usuario u ON u.id = d.usuario_id
        WHERE i.id = ?
        <sql:param value="${param.ideaId}" />
    </sql:query>
    <c:if test="${resultadoIdea.rowCount == 0 or resultadoIdea.rows[0].disponible != true}">
        <jsp:forward page="/banco-ideas.jsp" />
    </c:if>
    <c:set var="idea" value="${resultadoIdea.rows[0]}" />
</c:if>

<c:set var="tituloPagina" value="Proponer idea - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="propuestas" scope="request" />
<c:set var="rolesPermitidos" value=",estudiante," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2><c:out value="${tieneIdeaBase ? 'Proponer con esta idea' : 'Proponer idea propia'}" /> <span class="insignia-verde">PROPUESTA</span></h2>
</div>

<c:choose>
    <c:when test="${!cumpleRequisitos}">
        <div class="pagina-marcador">
            <p>Todavía no cumples los requisitos de ingreso (RF-14): se necesita el ${umbralRequisitos}%
            de créditos aprobados (tienes registrado:
            <c:out value="${empty estudianteSesion.porcentaje_creditos ? 'sin registrar' : estudianteSesion.porcentaje_creditos}" /><c:if test="${not empty estudianteSesion.porcentaje_creditos}">%</c:if>)
            y la asignatura de metodología de la investigación aprobada
            (<c:out value="${estudianteSesion.metodologia_aprobada ? 'aprobada' : 'sin aprobar'}" />).</p>
            <p>Revisa el estado en <a href="${pageContext.request.contextPath}/mi-perfil.jsp">Mi perfil</a> y pídele a
            coordinación o al comité que lo actualice si ya cumples.</p>
        </div>
    </c:when>
    <c:otherwise>
        <c:if test="${param.error == '1'}">
            <p class="mensaje-error">Todos los campos son obligatorios.</p>
        </c:if>

        <c:if test="${tieneIdeaBase}">
            <div class="pagina-marcador" style="margin-bottom:20px;">
                <p>Estás proponiendo con base en la idea publicada por <strong><c:out value="${idea.docente_nombre}" /></strong>. Puedes ajustar el título, el objetivo y la descripción si lo necesitas.</p>
            </div>
        </c:if>

        <div class="tabla-contenedor">
            <form method="post" action="${pageContext.request.contextPath}/procesar-propuesta.jsp" class="formulario-rejilla">
                <c:if test="${tieneIdeaBase}">
                    <input type="hidden" name="ideaId" value="${idea.id}">
                </c:if>

                <div class="campo-formulario" style="grid-column: 1 / -1;">
                    <label for="titulo">Título</label>
                    <input type="text" id="titulo" name="titulo" required value="${tieneIdeaBase ? idea.titulo : ''}">
                </div>

                <div class="campo-formulario">
                    <label for="lineaInvestigacion">Línea de investigación</label>
                    <input type="text" id="lineaInvestigacion" name="lineaInvestigacion" required value="${tieneIdeaBase ? idea.linea_investigacion : ''}">
                </div>

                <div class="campo-formulario" style="grid-column: 1 / -1;">
                    <label for="objetivo">Objetivo</label>
                    <input type="text" id="objetivo" name="objetivo" required value="${tieneIdeaBase ? idea.objetivo : ''}">
                </div>

                <div class="campo-formulario" style="grid-column: 1 / -1;">
                    <label for="descripcion">Descripción</label>
                    <input type="text" id="descripcion" name="descripcion" required value="${tieneIdeaBase ? idea.descripcion : ''}">
                </div>

                <div class="formulario-acciones">
                    <button type="submit" class="boton-primario">Enviar propuesta</button>
                    <a href="${pageContext.request.contextPath}/banco-ideas.jsp" class="boton-secundario">Cancelar</a>
                </div>
            </form>
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/cierre.jsp" />
