<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Guard manual (esta pagina no incluye menu.jsp, no tiene HTML propio) --%>
<c:if test="${empty sessionScope.usuarioId or (sessionScope.usuarioRol != 'comite' and sessionScope.usuarioRol != 'coordinacion')}">
    <c:redirect url="/login.jsp" />
</c:if>

<sql:query var="propuestaActual" dataSource="${applicationScope.dsSistemaTG}">
    SELECT pr.id, pr.titulo, pr.idea_id, e.id AS estudiante_lider_id, e.modalidad AS lider_modalidad, e.es_pareja AS lider_es_pareja
    FROM propuesta pr JOIN estudiante e ON e.id = pr.estudiante_lider_id
    WHERE pr.id = ?
    <sql:param value="${param.propuestaId}" />
</sql:query>
<c:set var="propuesta" value="${propuestaActual.rows[0]}" />

<c:choose>
    <c:when test="${empty fn:trim(param.motivo) or propuestaActual.rowCount == 0}">
        <c:redirect url="/propuesta-revisar.jsp?id=${param.propuestaId}" />
    </c:when>

    <%-- RF-11: devolver con correcciones o dejar pendiente no crea proyecto, solo cambia el estado. --%>
    <c:when test="${param.decision != 'aprobada'}">
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            UPDATE propuesta SET estado = ? WHERE id = ?
            <sql:param value="${param.decision}" />
            <sql:param value="${param.propuestaId}" />
        </sql:update>

        <sql:query var="siguienteActa" dataSource="${applicationScope.dsSistemaTG}">
            SELECT COALESCE(MAX(numero), 0) + 1 AS siguiente FROM acta
        </sql:query>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO acta (numero, fecha, decision, motivo, propuesta_id)
            VALUES (?, CURDATE(), ?, ?, ?)
            <sql:param value="${siguienteActa.rows[0].siguiente}" />
            <sql:param value="${param.decision}" />
            <sql:param value="${param.motivo}" />
            <sql:param value="${param.propuestaId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, ?, 'propuesta', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
            <sql:param value="cambiar_estado:${param.decision}" />
        </sql:update>

        <c:redirect url="/propuestas-banco.jsp?revisada=1" />
    </c:when>

    <%-- RF-13: director y evaluador son obligatorios al aprobar; RF-16: si el
         lider es pareja, tambien hace falta elegir companero. Revalidado en
         el servidor por si se evita el chequeo del formulario. --%>
    <c:when test="${empty param.nivel or empty param.directorId or empty param.evaluadorId or (propuesta.lider_es_pareja and empty param.companeroId)}">
        <c:redirect url="/propuesta-revisar.jsp?id=${param.propuestaId}" />
    </c:when>

    <c:otherwise>
        <%-- RF-12: consecutivo anual, 65 tecnologia / 125 ingenieria, no se repite. --%>
        <sql:query var="siguienteConsecutivo" dataSource="${applicationScope.dsSistemaTG}">
            SELECT COALESCE(MAX(consecutivo), ${param.nivel == 'tecnologia' ? 64 : 124}) + 1 AS siguiente
            FROM proyecto WHERE nivel = ? AND anio = YEAR(CURDATE())
            <sql:param value="${param.nivel}" />
        </sql:query>

        <%-- RF-19: el proyecto entra directo en fase 2 ("Propuesta", responsable
             estudiante) porque la fase 1 ("Idea", responsable comite -- elegir/
             aprobar la idea y asignar director/evaluador/codirector) es
             exactamente lo que este formulario acaba de hacer; no tendria
             sentido que un proyecto recien creado mostrara la fase 1 como
             pendiente cuando ya se cumplio. --%>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO proyecto (consecutivo, anio, nivel, modalidad, fase_actual, estado, idea_id, propuesta_id)
            VALUES (?, YEAR(CURDATE()), ?, ?, 2, 'en_fase', ?, ?)
            <sql:param value="${siguienteConsecutivo.rows[0].siguiente}" />
            <sql:param value="${param.nivel}" />
            <sql:param value="${propuesta.lider_modalidad}" />
            <sql:param value="${propuesta.idea_id}" />
            <sql:param value="${param.propuestaId}" />
        </sql:update>

        <%-- No se usa LAST_INSERT_ID(): <sql:update> no garantiza la misma
             conexion para la siguiente consulta (pool de conexiones), asi que
             se busca el proyecto recien creado por su propuesta_id, que es
             unico porque cada propuesta se aprueba una sola vez. --%>
        <sql:query var="proyectoCreado" dataSource="${applicationScope.dsSistemaTG}">
            SELECT id FROM proyecto WHERE propuesta_id = ?
            <sql:param value="${param.propuestaId}" />
        </sql:query>
        <c:set var="proyectoId" value="${proyectoCreado.rows[0].id}" />

        <%-- RF-16: lider + companero (si aplica) como integrantes del proyecto. --%>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO proyecto_integrante (proyecto_id, estudiante_id, es_lider) VALUES (?, ?, TRUE)
            <sql:param value="${proyectoId}" />
            <sql:param value="${propuesta.estudiante_lider_id}" />
        </sql:update>
        <c:if test="${not empty param.companeroId}">
            <sql:update dataSource="${applicationScope.dsSistemaTG}">
                INSERT INTO proyecto_integrante (proyecto_id, estudiante_id, es_lider) VALUES (?, ?, FALSE)
                <sql:param value="${proyectoId}" />
                <sql:param value="${param.companeroId}" />
            </sql:update>
        </c:if>

        <%-- RF-13: director y evaluador obligatorios, codirector opcional. --%>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO asignacion (proyecto_id, director_id, evaluador_id, codirector_id)
            VALUES (?, ?, ?, ?)
            <sql:param value="${proyectoId}" />
            <sql:param value="${param.directorId}" />
            <sql:param value="${param.evaluadorId}" />
            <sql:param value="${empty param.codirectorId ? null : param.codirectorId}" />
        </sql:update>

        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            UPDATE propuesta SET estado = 'aprobada' WHERE id = ?
            <sql:param value="${param.propuestaId}" />
        </sql:update>

        <sql:query var="siguienteActa2" dataSource="${applicationScope.dsSistemaTG}">
            SELECT COALESCE(MAX(numero), 0) + 1 AS siguiente FROM acta
        </sql:query>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO acta (numero, fecha, decision, motivo, propuesta_id)
            VALUES (?, CURDATE(), 'aprobada', ?, ?)
            <sql:param value="${siguienteActa2.rows[0].siguiente}" />
            <sql:param value="${param.motivo}" />
            <sql:param value="${param.propuestaId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO auditoria (usuario_id, accion, entidad, fecha)
            VALUES (?, 'cambiar_estado:aprobada', 'propuesta', NOW())
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <%-- Historial: fase 1 (Idea) queda completada por esta misma aprobacion;
             el proyecto arranca en fase 2 esperando que el estudiante suba el
             formato 124 (RF-20, RF-21). --%>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 1, 'completada', NOW(), ?)
            <sql:param value="${proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>
        <sql:update dataSource="${applicationScope.dsSistemaTG}">
            INSERT INTO historial_fase (proyecto_id, fase, estado, fecha, usuario_id)
            VALUES (?, 2, 'estudiante', NOW(), ?)
            <sql:param value="${proyectoId}" />
            <sql:param value="${sessionScope.usuarioId}" />
        </sql:update>

        <c:redirect url="/propuestas-banco.jsp?revisada=1" />
    </c:otherwise>
</c:choose>
