<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<c:set var="tituloPagina" value="Publicar idea - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="banco-ideas" scope="request" />
<c:set var="rolesPermitidos" value=",comite,director,evaluador," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />
<jsp:include page="/WEB-INF/conexion.jsp" />

<%-- RF-06 / CP-11: solo se puede publicar dentro de un periodo de banco_ideas vigente hoy. --%>
<sql:query var="periodosVigentes" dataSource="${applicationScope.dsSistemaTG}">
    SELECT id, nombre FROM periodo
    WHERE modulo = 'banco_ideas' AND CURDATE() BETWEEN fecha_inicio AND fecha_fin
    ORDER BY fecha_inicio
</sql:query>

<div class="titulo-pagina">
    <h2>Publicar <span class="insignia-verde">IDEA</span></h2>
</div>

<c:choose>
    <c:when test="${periodosVigentes.rowCount == 0}">
        <div class="pagina-marcador">
            <p>No hay un periodo de banco de ideas vigente hoy. Según la sección 1.7 del documento de requerimientos, el banco de ideas se habilita entre finales de octubre y la primera semana de diciembre.</p>
            <p>Pídele a comité o coordinación que configure el periodo correspondiente en <a href="${pageContext.request.contextPath}/calendario-academico.jsp">Calendario académico</a>.</p>
        </div>
    </c:when>
    <c:otherwise>
        <c:if test="${param.error == '1'}">
            <p class="mensaje-error">Todos los campos son obligatorios.</p>
        </c:if>

        <div class="tabla-contenedor">
            <form method="post" action="${pageContext.request.contextPath}/procesar-idea.jsp" class="formulario-rejilla">
                <div class="campo-formulario">
                    <label for="titulo">Título</label>
                    <input type="text" id="titulo" name="titulo" required>
                </div>

                <div class="campo-formulario">
                    <label for="nivel">Nivel</label>
                    <select id="nivel" name="nivel" required>
                        <option value="tecnologia">Tecnología</option>
                        <option value="ingenieria">Ingeniería</option>
                    </select>
                </div>

                <div class="campo-formulario">
                    <label for="lineaInvestigacion">Línea de investigación</label>
                    <input type="text" id="lineaInvestigacion" name="lineaInvestigacion" required>
                </div>

                <div class="campo-formulario">
                    <label for="periodoId">Periodo</label>
                    <select id="periodoId" name="periodoId" required>
                        <c:forEach var="per" items="${periodosVigentes.rows}">
                            <option value="${per.id}"><c:out value="${per.nombre}" /></option>
                        </c:forEach>
                    </select>
                </div>

                <div class="campo-formulario" style="grid-column: 1 / -1;">
                    <label for="objetivo">Objetivo</label>
                    <input type="text" id="objetivo" name="objetivo" required>
                </div>

                <div class="campo-formulario" style="grid-column: 1 / -1;">
                    <label for="descripcion">Descripción</label>
                    <input type="text" id="descripcion" name="descripcion" required>
                </div>

                <div class="formulario-acciones">
                    <button type="submit" class="boton-primario">Publicar</button>
                    <a href="${pageContext.request.contextPath}/banco-ideas.jsp" class="boton-secundario">Cancelar</a>
                </div>
            </form>
        </div>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/cierre.jsp" />
