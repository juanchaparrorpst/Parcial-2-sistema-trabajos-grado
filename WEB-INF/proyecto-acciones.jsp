<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    Fragmento incluido desde proyecto-detalle.jsp: muestra la accion que le
    toca a QUIEN esta viendo la pagina, segun la fase actual y el responsable
    (seccion 3.3 del documento). Usa variables de scope "request" fijadas por
    proyecto-detalle.jsp antes de este include: proyectoId, faseActual,
    estadoProyecto, responsableActual, esIntegrante, esLiderSesion,
    esDirector, esEvaluador, esComiteCoord.

    Si nada de lo de abajo aplica (por ejemplo, un director mirando un
    proyecto en fase 4), no se muestra ninguna accion -- la pagina sigue
    siendo de solo consulta para el, que es el comportamiento correcto.
--%>
<c:if test="${estadoProyecto != 'finalizado'}">
    <div class="tabla-contenedor" style="margin-bottom:20px;">
        <c:choose>
            <%-- Fase 2 (Propuesta): responsable alterna estudiante <-> director. --%>
            <c:when test="${faseActual == 2 and responsableActual == 'estudiante' and esLiderSesion}">
                <p class="ayuda">Te corresponde subir el formato F-DC-124 (RF-21).</p>
                <a class="boton-primario" href="${pageContext.request.contextPath}/formato124-formulario.jsp?proyectoId=${proyectoId}">Subir formato 124</a>
            </c:when>
            <c:when test="${faseActual == 2 and responsableActual == 'director' and esDirector}">
                <p class="ayuda">Tienes un formato 124 pendiente de revisar (RF-22).</p>
                <a class="boton-primario" href="${pageContext.request.contextPath}/director-revisar.jsp?proyectoId=${proyectoId}">Revisar formato 124</a>
            </c:when>

            <%-- Fase 3 (Informe y envio): responsable alterna director <-> evaluador. --%>
            <c:when test="${faseActual == 3 and responsableActual == 'director' and esDirector}">
                <p class="ayuda">Te corresponde cargar el informe de similitud de Turnitin y enviarlo al evaluador (RF-23).</p>
                <a class="boton-primario" href="${pageContext.request.contextPath}/turnitin-formulario.jsp?proyectoId=${proyectoId}">Cargar informe de similitud</a>
            </c:when>
            <c:when test="${faseActual == 3 and responsableActual == 'evaluador' and esEvaluador}">
                <p class="ayuda">Tienes un formato 124 con informe de similitud pendiente de revisar (RF-24).</p>
                <a class="boton-primario" href="${pageContext.request.contextPath}/evaluador-revisar.jsp?proyectoId=${proyectoId}">Revisar y responder</a>
            </c:when>

            <%-- Fase 4 (Documentos importantes): responsable estudiante (cualquier integrante). --%>
            <c:when test="${faseActual == 4 and esIntegrante}">
                <p class="ayuda">Puedes cargar los documentos importantes de esta fase (RF-25).</p>
                <a class="boton-primario" href="${pageContext.request.contextPath}/documentos-fase4.jsp?proyectoId=${proyectoId}">Cargar documentos de la fase 4</a>
            </c:when>

            <%-- Fase 5 (por definir, ver SEGUIMIENTO_PROYECTO.md): coordinacion/comite avanza manualmente. --%>
            <c:when test="${faseActual == 5 and esComiteCoord}">
                <p class="ayuda">La fase 5 no tiene una descripción clara en el documento de requerimientos; coordinación o comité la avanza manualmente cuando corresponda.</p>
                <form method="post" action="${pageContext.request.contextPath}/procesar-avanzar-fase.jsp">
                    <input type="hidden" name="proyectoId" value="${proyectoId}">
                    <input type="hidden" name="accion" value="avanzar6">
                    <button type="submit" class="boton-primario">Avanzar a fase 6 (Cierre)</button>
                </form>
            </c:when>

            <%-- Fase 6 (Cierre): coordinacion abre y cierra. --%>
            <c:when test="${faseActual == 6 and esComiteCoord}">
                <p class="ayuda">Todas las fases anteriores están cumplidas. Coordinación cierra el proyecto (RF-19, fase 6).</p>
                <form method="post" action="${pageContext.request.contextPath}/procesar-avanzar-fase.jsp">
                    <input type="hidden" name="proyectoId" value="${proyectoId}">
                    <input type="hidden" name="accion" value="cerrar">
                    <button type="submit" class="boton-primario">Cerrar proyecto</button>
                </form>
            </c:when>

            <c:otherwise>
                <p class="ayuda">No tienes ninguna acción pendiente en este proyecto por ahora.</p>
            </c:otherwise>
        </c:choose>
    </div>
</c:if>
