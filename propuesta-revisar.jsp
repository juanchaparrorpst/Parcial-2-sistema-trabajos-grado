<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Esta comprobacion va antes de incluir menu.jsp, igual que en
     idea-revisar.jsp: si se redirige con la pagina ya escrita, el redirect
     no tiene efecto. --%>
<sql:query var="resultadoPropuesta" dataSource="${applicationScope.dsSistemaTG}">
    SELECT pr.id, pr.titulo, pr.objetivo, pr.descripcion, pr.linea_investigacion, pr.estado, pr.idea_id,
           e.id AS estudiante_lider_id, e.modalidad AS lider_modalidad, e.es_pareja AS lider_es_pareja,
           u.nombre_completo AS lider_nombre,
           idea.nivel AS idea_nivel
    FROM propuesta pr
    JOIN estudiante e ON e.id = pr.estudiante_lider_id
    JOIN usuario u ON u.id = e.usuario_id
    LEFT JOIN idea ON idea.id = pr.idea_id
    WHERE pr.id = ?
    <sql:param value="${param.id}" />
</sql:query>
<c:if test="${resultadoPropuesta.rowCount == 0}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="propuesta" value="${resultadoPropuesta.rows[0]}" />

<%-- RF-28: aviso (no bloqueo duro) si el titulo coincide con un proyecto ya aprobado antes. --%>
<sql:query var="posiblesRepetidos" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.nivel,
           COALESCE(pr2.titulo, id2.titulo) AS titulo_anterior
    FROM proyecto py
    LEFT JOIN propuesta pr2 ON pr2.id = py.propuesta_id
    LEFT JOIN idea id2 ON id2.id = py.idea_id
    WHERE LOWER(COALESCE(pr2.titulo, id2.titulo)) = LOWER(?)
    <sql:param value="${propuesta.titulo}" />
</sql:query>

<%-- Candidatos para director, evaluador y codirector: perfil de docente con el rol correspondiente. --%>
<sql:query var="directores" dataSource="${applicationScope.dsSistemaTG}">
    SELECT d.id, u.nombre_completo FROM docente d JOIN usuario u ON u.id = d.usuario_id
    WHERE u.rol = 'director' AND u.activo = TRUE ORDER BY u.nombre_completo
</sql:query>
<sql:query var="evaluadores" dataSource="${applicationScope.dsSistemaTG}">
    SELECT d.id, u.nombre_completo FROM docente d JOIN usuario u ON u.id = d.usuario_id
    WHERE u.rol = 'evaluador' AND u.activo = TRUE ORDER BY u.nombre_completo
</sql:query>
<sql:query var="codirectores" dataSource="${applicationScope.dsSistemaTG}">
    SELECT d.id, u.nombre_completo FROM docente d JOIN usuario u ON u.id = d.usuario_id
    WHERE u.activo = TRUE ORDER BY u.nombre_completo
</sql:query>

<%-- RF-16: si el lider es modalidad pareja, el comite elige al companero al
     aprobar (la tabla propuesta no tiene columna para guardarlo antes; ver
     SEGUIMIENTO_PROYECTO.md, decision de este sprint). Candidatos: estudiantes
     marcados "pareja" que todavia no estan en ningun proyecto. --%>
<sql:query var="companeros" dataSource="${applicationScope.dsSistemaTG}">
    SELECT e.id, u.nombre_completo FROM estudiante e JOIN usuario u ON u.id = e.usuario_id
    WHERE e.es_pareja = TRUE AND e.id != ?
    AND e.id NOT IN (SELECT estudiante_id FROM proyecto_integrante)
    ORDER BY u.nombre_completo
    <sql:param value="${propuesta.estudiante_lider_id}" />
</sql:query>

<c:set var="tituloPagina" value="Revisar propuesta - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="propuestas" scope="request" />
<c:set var="rolesPermitidos" value=",comite,coordinacion," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Revisar <span class="insignia-verde">PROPUESTA</span></h2>
</div>

<c:if test="${posiblesRepetidos.rowCount > 0}">
    <p class="mensaje-aviso">
        RF-28 — Posible tema repetido: este título coincide con
        <c:forEach var="rep" items="${posiblesRepetidos.rows}" varStatus="st">
            el proyecto <c:out value="${rep.consecutivo}" />-<c:out value="${rep.anio}" /><c:if test="${!st.last}">, </c:if>
        </c:forEach>
        . Puedes confirmar la aprobación de todas formas o devolverla con correcciones.
    </p>
</c:if>

<dl class="tarjeta-info" style="margin-bottom:20px;">
    <dt>Título</dt>
    <dd><c:out value="${propuesta.titulo}" /></dd>
    <dt>Estudiante líder</dt>
    <dd><c:out value="${propuesta.lider_nombre}" /> (modalidad <c:out value="${propuesta.lider_modalidad}" />, <c:out value="${propuesta.lider_es_pareja ? 'pareja' : 'individual'}" />)</dd>
    <dt>Línea de investigación</dt>
    <dd><c:out value="${propuesta.linea_investigacion}" /></dd>
    <dt>Objetivo</dt>
    <dd><c:out value="${propuesta.objetivo}" /></dd>
    <dt>Descripción</dt>
    <dd><c:out value="${propuesta.descripcion}" /></dd>
    <dt>Estado actual</dt>
    <dd><c:out value="${propuesta.estado}" /></dd>
</dl>

<div class="tabla-contenedor">
    <form id="formularioRevisarPropuesta" method="post" action="${pageContext.request.contextPath}/procesar-propuesta-estado.jsp" class="formulario-rejilla">
        <input type="hidden" name="propuestaId" value="${propuesta.id}">

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

        <%-- RF-12/RF-13: solo hace falta al aprobar, se muestra/exige con JS segun la decision. --%>
        <div id="bloqueAprobacion" hidden>
            <div class="campo-formulario">
                <label for="nivel">Nivel (para el consecutivo del proyecto)</label>
                <select id="nivel" name="nivel">
                    <option value="tecnologia" ${propuesta.idea_nivel == 'tecnologia' ? 'selected' : ''}>Tecnología (consecutivo desde 65)</option>
                    <option value="ingenieria" ${propuesta.idea_nivel == 'ingenieria' ? 'selected' : ''}>Ingeniería (consecutivo desde 125)</option>
                </select>
            </div>

            <div class="campo-formulario">
                <label for="directorId">Director</label>
                <select id="directorId" name="directorId">
                    <option value="">Seleccione...</option>
                    <c:forEach var="d" items="${directores.rows}">
                        <option value="${d.id}"><c:out value="${d.nombre_completo}" /></option>
                    </c:forEach>
                </select>
            </div>

            <div class="campo-formulario">
                <label for="evaluadorId">Evaluador</label>
                <select id="evaluadorId" name="evaluadorId">
                    <option value="">Seleccione...</option>
                    <c:forEach var="ev" items="${evaluadores.rows}">
                        <option value="${ev.id}"><c:out value="${ev.nombre_completo}" /></option>
                    </c:forEach>
                </select>
            </div>

            <div class="campo-formulario">
                <label for="codirectorId">Codirector (opcional)</label>
                <select id="codirectorId" name="codirectorId">
                    <option value="">Ninguno</option>
                    <c:forEach var="cd" items="${codirectores.rows}">
                        <option value="${cd.id}"><c:out value="${cd.nombre_completo}" /></option>
                    </c:forEach>
                </select>
            </div>

            <c:if test="${propuesta.lider_es_pareja}">
                <div class="campo-formulario">
                    <label for="companeroId">Compañero(a) de pareja</label>
                    <select id="companeroId" name="companeroId">
                        <option value="">Seleccione...</option>
                        <c:forEach var="c" items="${companeros.rows}">
                            <option value="${c.id}"><c:out value="${c.nombre_completo}" /></option>
                        </c:forEach>
                    </select>
                    <p class="ayuda">El líder registró esta idea como trabajo en pareja (RF-16); hace falta elegir con quién para crear el proyecto.</p>
                </div>
            </c:if>
        </div>

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Registrar decisión</button>
            <a href="${pageContext.request.contextPath}/propuestas-banco.jsp" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script>
    var LIDER_ES_PAREJA = ${propuesta.lider_es_pareja ? 'true' : 'false'};
</script>
<script src="${pageContext.request.contextPath}/js/propuesta-revisar.js?v=1"></script>

<jsp:include page="/WEB-INF/cierre.jsp" />
