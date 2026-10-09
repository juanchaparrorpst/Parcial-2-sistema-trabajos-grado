<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Propuestas Banco - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="propuestas" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<%--
    Mismos fragmentos reutilizables que banco-ideas.jsp (tabla-inicio/fin.jsp
    y el modal de detalle), con columnas distintas: la tabla no repite
    marcado, solo cambia el <thead>/<tbody> de cada pagina. Datos de ejemplo
    fijos, se conectan a la tabla "propuesta" en el Sprint 2.
--%>
<div class="titulo-pagina">
    <h2>Propuestas <span class="insignia-verde">BANCO</span></h2>
</div>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<table class="tabla-datos">
    <thead>
        <tr>
            <th>ID</th>
            <th>Descripción</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>PROP-0001</td>
            <td>Sistema de monitoreo de consumo eléctrico con IoT para bloques académicos UTS</td>
            <td><span class="insignia-estado aprobada">Aprobada</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la propuesta"
                    data-etq-1="Estudiante líder" data-val-1="Carlos Andrés Rueda Gómez"
                    data-etq-2="Título de la idea" data-val-2="Sistema de monitoreo de consumo eléctrico con IoT para bloques académicos UTS"
                    data-etq-3="Tipo de modalidad" data-val-3="Desarrollo tecnológico"
                    data-etq-4="Objetivo general de la idea" data-val-4="Reducir el consumo eléctrico de los bloques académicos mediante monitoreo en tiempo real, con una red de sensores IoT aplicada a 3 bloques del campus.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>PROP-0002</td>
            <td>Plataforma de trazabilidad agrícola con blockchain para pequeños productores de Santander</td>
            <td><span class="insignia-estado aprobada">Aprobada</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la propuesta"
                    data-etq-1="Estudiante líder" data-val-1="Daniela Fernanda Ortiz Silva"
                    data-etq-2="Título de la idea" data-val-2="Plataforma de trazabilidad agrícola con blockchain para pequeños productores de Santander"
                    data-etq-3="Tipo de modalidad" data-val-3="Proyecto de investigación"
                    data-etq-4="Objetivo general de la idea" data-val-4="Dar trazabilidad verificable a productos agrícolas de pequeños productores, con productores piloto de la región.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>PROP-0003</td>
            <td>Aplicativo móvil de reserva de turnos para laboratorios de cómputo</td>
            <td><span class="insignia-estado pendiente">Pendiente</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la propuesta"
                    data-etq-1="Estudiante líder" data-val-1="Esteban Camilo Vargas Peña"
                    data-etq-2="Título de la idea" data-val-2="Aplicativo móvil de reserva de turnos para laboratorios de cómputo"
                    data-etq-3="Tipo de modalidad" data-val-3="Desarrollo tecnológico"
                    data-etq-4="Objetivo general de la idea" data-val-4="Organizar el uso de los laboratorios de cómputo mediante reserva de turnos desde una aplicación móvil.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>PROP-0004</td>
            <td>Modelo predictivo de deserción estudiantil con variables socioeconómicas</td>
            <td><span class="insignia-estado con-correcciones">Con correcciones</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la propuesta"
                    data-etq-1="Estudiante líder" data-val-1="Carlos Andrés Rueda Gómez"
                    data-etq-2="Título de la idea" data-val-2="Modelo predictivo de deserción estudiantil con variables socioeconómicas"
                    data-etq-3="Tipo de modalidad" data-val-3="Proyecto de investigación"
                    data-etq-4="Objetivo general de la idea" data-val-4="Identificar tempranamente estudiantes en riesgo de deserción cruzando variables académicas y socioeconómicas.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
