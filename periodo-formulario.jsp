<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Nuevo periodo - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="calendario" scope="request" />
<c:set var="rolesPermitidos" value=",comite,coordinacion," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Nuevo <span class="insignia-verde">PERIODO</span></h2>
</div>

<c:if test="${param.error == '1'}">
    <p class="mensaje-error">La fecha de inicio debe ser anterior a la fecha de fin.</p>
</c:if>

<div class="tabla-contenedor">
    <form id="formularioPeriodo" method="post" action="${pageContext.request.contextPath}/procesar-periodo.jsp" class="formulario-rejilla">
        <div class="campo-formulario">
            <label for="nombre">Nombre del periodo</label>
            <input type="text" id="nombre" name="nombre" required placeholder="Ej: Banco de ideas 2027-1">
        </div>

        <div class="campo-formulario">
            <label for="modulo">Módulo</label>
            <select id="modulo" name="modulo" required>
                <option value="banco_ideas">Banco de ideas</option>
                <option value="modalidad">Modalidad</option>
                <option value="propuesta">Propuesta</option>
                <option value="pago">Pago</option>
            </select>
        </div>

        <div class="campo-formulario">
            <label for="fechaInicio">Fecha de inicio</label>
            <input type="date" id="fechaInicio" name="fechaInicio" required>
        </div>

        <div class="campo-formulario">
            <label for="fechaFin">Fecha de fin</label>
            <input type="date" id="fechaFin" name="fechaFin" required>
        </div>

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Guardar</button>
            <a href="${pageContext.request.contextPath}/calendario-academico.jsp" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script>
    document.getElementById("formularioPeriodo").addEventListener("submit", function (evento) {
        var inicio = document.getElementById("fechaInicio").value;
        var fin = document.getElementById("fechaFin").value;
        if (inicio && fin && inicio > fin) {
            evento.preventDefault();
            window.alert("La fecha de inicio debe ser anterior a la fecha de fin.");
        }
    });
</script>

<jsp:include page="/WEB-INF/cierre.jsp" />
