<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- Igual que idea-revisar.jsp: se busca el proyecto y se valida que quien
     entra sea de verdad integrante de el, ANTES de incluir menu.jsp. --%>
<sql:query var="resultadoProyecto" dataSource="${applicationScope.dsSistemaTG}">
    SELECT py.id, py.consecutivo, py.anio, py.nivel,
           (SELECT COUNT(*) FROM proyecto_integrante WHERE proyecto_id = py.id) AS num_integrantes,
           (SELECT COUNT(*) FROM documento WHERE proyecto_id = py.id AND tipo = 'pago') AS num_soportes,
           pg.id AS pago_id
    FROM proyecto py
    LEFT JOIN pago pg ON pg.proyecto_id = py.id
    WHERE py.id = ?
    <sql:param value="${param.proyectoId}" />
</sql:query>
<c:if test="${resultadoProyecto.rowCount == 0}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="proyecto" value="${resultadoProyecto.rows[0]}" />

<sql:query var="resultadoIntegrante" dataSource="${applicationScope.dsSistemaTG}">
    SELECT 1 FROM proyecto_integrante pi JOIN estudiante e ON e.id = pi.estudiante_id
    WHERE pi.proyecto_id = ? AND e.usuario_id = ?
    <sql:param value="${param.proyectoId}" />
    <sql:param value="${sessionScope.usuarioId}" />
</sql:query>
<c:set var="completo" value="${not empty proyecto.pago_id and proyecto.num_soportes >= proyecto.num_integrantes}" />
<%-- Solo un integrante del proyecto (lider o pareja) puede cargar el pago; y
     no si ya esta completo (nada que agregar). Si ya existe un pago pero
     incompleto (CP-04: pareja sin el soporte del companero), se entra en
     modo "completar" en vez de bloquear la pantalla. --%>
<c:if test="${resultadoIntegrante.rowCount == 0 or completo}">
    <jsp:forward page="/propuestas-banco.jsp" />
</c:if>
<c:set var="esPareja" value="${proyecto.num_integrantes > 1}" />
<c:set var="modoCompletar" value="${not empty proyecto.pago_id}" />

<c:set var="tituloPagina" value="Cargar soporte de pago - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="propuestas" scope="request" />
<c:set var="rolesPermitidos" value=",estudiante," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Cargar soporte de <span class="insignia-verde">PAGO</span></h2>
</div>

<c:if test="${param.error == '1'}">
    <p class="mensaje-error">La liquidación y tu soporte de pago son obligatorios, y deben ser archivos PDF.</p>
</c:if>

<p class="ayuda" style="margin-bottom:16px;">
    Proyecto ${proyecto.consecutivo}-${proyecto.anio} (<c:out value="${proyecto.nivel}" />).
    <c:if test="${esPareja and !modoCompletar}"> Este trabajo es en pareja: sin el soporte de pago de tu compañero(a), la solicitud queda marcada como incompleta (RF-15, CP-04).</c:if>
</p>

<c:choose>
    <%-- Ya existe un pago pero incompleto (CP-04): solo falta el soporte del
         companero, la liquidacion y el soporte propio ya se subieron. --%>
    <c:when test="${modoCompletar}">
        <p class="mensaje-aviso">Esta solicitud quedó incompleta: falta el soporte de pago de tu compañero(a).</p>
        <div class="tabla-contenedor">
            <form id="formularioPago" method="post" action="${pageContext.request.contextPath}/procesar-pago-completar.jsp" enctype="multipart/form-data" class="formulario-rejilla">
                <input type="hidden" name="pagoId" value="${proyecto.pago_id}">
                <input type="hidden" name="proyectoId" value="${proyecto.id}">
                <input type="hidden" name="nombreSoporteCompanero" id="nombreSoporteCompanero">

                <div class="campo-formulario">
                    <label for="soporteCompanero">Soporte de pago de tu compañero(a) (PDF)</label>
                    <input type="file" id="soporteCompanero" name="soporteCompanero" accept="application/pdf" required>
                </div>

                <div class="formulario-acciones">
                    <button type="submit" id="botonEnviarPago" class="boton-primario">Enviar</button>
                    <a href="${pageContext.request.contextPath}/propuestas-banco.jsp" class="boton-secundario">Cancelar</a>
                </div>
            </form>
        </div>
        <script src="${pageContext.request.contextPath}/js/pago-formulario.js?v=1" data-modo="completar"></script>
    </c:when>

    <c:otherwise>
        <div class="tabla-contenedor">
            <form id="formularioPago" method="post" action="${pageContext.request.contextPath}/procesar-pago.jsp" enctype="multipart/form-data" class="formulario-rejilla">
                <input type="hidden" name="proyectoId" value="${proyecto.id}">
                <input type="hidden" name="nombreLiquidacion" id="nombreLiquidacion">
                <input type="hidden" name="nombreSoportePropio" id="nombreSoportePropio">
                <input type="hidden" name="nombreSoporteCompanero" id="nombreSoporteCompanero">

                <div class="campo-formulario">
                    <label for="semestre">Semestre actual</label>
                    <input type="text" id="semestre" name="semestre" required placeholder="Ej: 2026-2">
                </div>

                <div class="campo-formulario">
                    <label for="liquidacion">Liquidación de pago (PDF)</label>
                    <input type="file" id="liquidacion" name="liquidacion" accept="application/pdf" required>
                    <p class="ayuda">Se le agrega una marca de agua en el navegador antes de subirla (RNF-11).</p>
                </div>

                <div class="campo-formulario">
                    <label for="soportePropio">Tu soporte de pago (PDF)</label>
                    <input type="file" id="soportePropio" name="soportePropio" accept="application/pdf" required>
                </div>

                <c:if test="${esPareja}">
                    <div class="campo-formulario">
                        <label for="soporteCompanero">Soporte de pago de tu compañero(a) (PDF)</label>
                        <input type="file" id="soporteCompanero" name="soporteCompanero" accept="application/pdf">
                    </div>
                </c:if>

                <p id="estadoCarga" class="ayuda" hidden>Aplicando marca de agua y subiendo los archivos...</p>

                <div class="formulario-acciones">
                    <button type="submit" id="botonEnviarPago" class="boton-primario">Enviar</button>
                    <a href="${pageContext.request.contextPath}/propuestas-banco.jsp" class="boton-secundario">Cancelar</a>
                </div>
            </form>
        </div>
        <script src="https://unpkg.com/pdf-lib@1.17.1/dist/pdf-lib.min.js"></script>
        <script src="${pageContext.request.contextPath}/js/pago-formulario.js?v=1"></script>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/cierre.jsp" />
