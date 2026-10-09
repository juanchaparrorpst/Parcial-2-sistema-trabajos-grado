<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="tituloPagina" value="Sesion del comite - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="sesion-comite" scope="request" />
<c:set var="rolesPermitidos" value=",comite,coordinacion," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<%--
    RF-29: agrupa para la sesion del martes todo lo que sigue pendiente de
    decision (propuestas) o de verificacion (pagos). La tabla "propuesta" no
    guarda una fecha de envio (no esta en modelo_datos.dbml), asi que no hay
    forma de separar "llego antes del viernes" de "llego despues": en la
    practica da igual, porque todo lo pendiente sigue siendo agenda de la
    PROXIMA sesion hasta que el comite lo revise -- no hay una sesion anterior
    de la que se haya "quedado por fuera". Ver SEGUIMIENTO_PROYECTO.md.
--%>
<%-- RF-29: viernes de corte y martes de sesion, calculados en SQL (sin
     aritmetica de fechas en Java/JS): WEEKDAY() da 0=lunes..6=domingo, el
     viernes es 4. --%>
<sql:query var="fechasSesion" dataSource="${applicationScope.dsSistemaTG}">
    SELECT
        DATE_ADD(CURDATE(), INTERVAL ((4 - WEEKDAY(CURDATE()) + 7) % 7) DAY) AS corte_viernes,
        DATE_ADD(CURDATE(), INTERVAL ((4 - WEEKDAY(CURDATE()) + 7) % 7 + 4) DAY) AS sesion_martes
</sql:query>
<c:set var="corteViernes" value="${fechasSesion.rows[0].corte_viernes}" />
<c:set var="sesionMartes" value="${fechasSesion.rows[0].sesion_martes}" />

<sql:query var="propuestasPendientes" dataSource="${applicationScope.dsSistemaTG}">
    SELECT pr.id, pr.titulo, pr.linea_investigacion, u.nombre_completo AS lider_nombre
    FROM propuesta pr
    JOIN estudiante e ON e.id = pr.estudiante_lider_id
    JOIN usuario u ON u.id = e.usuario_id
    WHERE pr.estado = 'pendiente'
    ORDER BY pr.id
</sql:query>

<sql:query var="pagosPendientes" dataSource="${applicationScope.dsSistemaTG}">
    SELECT pg.id, py.consecutivo, py.anio, pg.semestre,
           u.nombre_completo AS lider_nombre,
           (SELECT COUNT(*) FROM proyecto_integrante WHERE proyecto_id = py.id) AS num_integrantes,
           (SELECT COUNT(*) FROM documento WHERE proyecto_id = py.id AND tipo = 'pago') AS num_soportes
    FROM pago pg
    JOIN proyecto py ON py.id = pg.proyecto_id
    JOIN proyecto_integrante pi ON pi.proyecto_id = py.id AND pi.es_lider = TRUE
    JOIN estudiante e ON e.id = pi.estudiante_id
    JOIN usuario u ON u.id = e.usuario_id
    WHERE pg.verificado_por IS NULL
    ORDER BY pg.id
</sql:query>

<div class="titulo-pagina">
    <h2>Sesión del <span class="insignia-verde">COMITÉ</span></h2>
</div>

<c:if test="${param.verificado == '1'}">
    <p class="mensaje-ok">Pago verificado correctamente.</p>
</c:if>
<c:if test="${param.verificado == '0'}">
    <p class="mensaje-error">No se puede verificar un pago incompleto.</p>
</c:if>

<p class="ayuda" style="margin-bottom:20px;">
    Corte: viernes <fmt:formatDate value="${corteViernes}" pattern="dd/MM/yyyy" />
    — sesión: martes <fmt:formatDate value="${sesionMartes}" pattern="dd/MM/yyyy" />.
    Todo lo que sigue pendiente aparece aquí, listo para decidir en la sesión.
</p>

<h3 style="margin-bottom:10px;">Propuestas pendientes (${propuestasPendientes.rowCount})</h3>
<div class="tabla-contenedor">
    <table class="tabla-datos" id="tablaPropuestasSesion">
        <thead>
            <tr>
                <th>Título</th>
                <th>Estudiante líder</th>
                <th>Línea de investigación</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="p" items="${propuestasPendientes.rows}">
                <tr>
                    <td><c:out value="${p.titulo}" /></td>
                    <td><c:out value="${p.lider_nombre}" /></td>
                    <td><c:out value="${p.linea_investigacion}" /></td>
                    <td>
                        <a class="boton-revisar" title="Revisar"
                           href="${pageContext.request.contextPath}/propuesta-revisar.jsp?id=${p.id}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12.5l2 2 4-4.5"/><rect x="3.5" y="4" width="17" height="16" rx="2"/></svg>
                        </a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${propuestasPendientes.rowCount == 0}">
                <tr><td colspan="4">No hay propuestas pendientes.</td></tr>
            </c:if>
        </tbody>
    </table>
</div>

<h3 style="margin: 24px 0 10px;">Pagos pendientes de verificar (${pagosPendientes.rowCount})</h3>
<div class="tabla-contenedor">
    <table class="tabla-datos" id="tablaPagosSesion">
        <thead>
            <tr>
                <th>Proyecto</th>
                <th>Estudiante líder</th>
                <th>Semestre</th>
                <th>Soportes</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="pg" items="${pagosPendientes.rows}">
                <c:set var="completo" value="${pg.num_soportes >= pg.num_integrantes}" />
                <tr>
                    <td>${pg.consecutivo}-${pg.anio}</td>
                    <td><c:out value="${pg.lider_nombre}" /></td>
                    <td><c:out value="${pg.semestre}" /></td>
                    <td>
                        <c:choose>
                            <c:when test="${completo}">
                                <span class="insignia-estado aprobada">Completo (${pg.num_soportes}/${pg.num_integrantes})</span>
                            </c:when>
                            <c:otherwise>
                                <span class="insignia-estado pendiente">Incompleto (${pg.num_soportes}/${pg.num_integrantes})</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <form method="post" action="${pageContext.request.contextPath}/procesar-pago-verificar.jsp" style="display:inline;">
                            <input type="hidden" name="pagoId" value="${pg.id}">
                            <button type="submit" class="boton-primario" ${completo ? '' : 'disabled'}>Verificar</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${pagosPendientes.rowCount == 0}">
                <tr><td colspan="5">No hay pagos pendientes de verificar.</td></tr>
            </c:if>
        </tbody>
    </table>
</div>

<div class="formulario-acciones" style="margin-top:16px;">
    <button type="button" id="botonExportarSesion" class="boton-secundario">Exportar agenda a CSV</button>
</div>

<script src="${pageContext.request.contextPath}/js/sesion-comite.js?v=1"></script>

<jsp:include page="/WEB-INF/cierre.jsp" />
