<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<jsp:include page="/WEB-INF/conexion.jsp" />

<c:set var="modoEdicion" value="${not empty param.id}" />

<%-- Esta comprobacion va ANTES de incluir menu.jsp: si se redirige con una
     pagina ya escrita, el redirect no tiene efecto (ver el comentario en
     WEB-INF/verificar-sesion.jsp). --%>
<c:if test="${modoEdicion}">
    <sql:query var="resultadoUsuario" dataSource="${applicationScope.dsSistemaTG}">
        SELECT u.id, u.nombre_completo, u.correo, u.documento_identidad, u.rol,
               e.modalidad, e.es_pareja,
               d.tipo_vinculacion, d.linea_investigacion
        FROM usuario u
        LEFT JOIN estudiante e ON e.usuario_id = u.id
        LEFT JOIN docente d ON d.usuario_id = u.id
        WHERE u.id = ?
        <sql:param value="${param.id}" />
    </sql:query>
    <c:if test="${resultadoUsuario.rowCount == 0}">
        <jsp:forward page="/gestion-usuarios.jsp" />
    </c:if>
    <c:set var="u" value="${resultadoUsuario.rows[0]}" />
</c:if>

<c:set var="tituloPagina" value="Usuario - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="usuarios" scope="request" />
<c:set var="rolesPermitidos" value=",administrador," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2><c:out value="${modoEdicion ? 'Editar' : 'Nuevo'}" /> <span class="insignia-verde">USUARIO</span></h2>
</div>

<c:if test="${param.error == '1'}">
    <p class="mensaje-error">El nombre debe tener al menos un nombre y un apellido.</p>
</c:if>
<c:if test="${param.error == '2'}">
    <p class="mensaje-error">Ya existe un usuario con ese correo electrónico.</p>
</c:if>
<c:if test="${param.error == '3'}">
    <p class="mensaje-error">Ya existe un usuario con ese documento de identidad.</p>
</c:if>
<c:if test="${param.error == '4'}">
    <p class="mensaje-error">Monografía y práctica empresarial solo admiten modalidad individual.</p>
</c:if>
<c:if test="${param.error == '5'}">
    <p class="mensaje-error">Seleccione un rol.</p>
</c:if>

<div class="tabla-contenedor">
    <form id="formularioUsuario" method="post" action="${pageContext.request.contextPath}/procesar-usuario.jsp" class="formulario-rejilla">
        <c:if test="${modoEdicion}">
            <input type="hidden" name="id" value="${u.id}">
            <input type="hidden" name="rolActual" value="${u.rol}">
        </c:if>

        <div class="campo-formulario">
            <label for="nombreCompleto">Nombre completo</label>
            <input type="text" id="nombreCompleto" name="nombreCompleto" required
                   value="${modoEdicion ? u.nombre_completo : ''}">
            <p class="ayuda">Debe incluir al menos un nombre y un apellido (para evitar homónimos).</p>
        </div>

        <div class="campo-formulario">
            <label for="correo">Correo electrónico</label>
            <input type="email" id="correo" name="correo" required
                   value="${modoEdicion ? u.correo : ''}">
        </div>

        <div class="campo-formulario">
            <label for="documentoIdentidad">Documento de identidad</label>
            <input type="text" id="documentoIdentidad" name="documentoIdentidad" required
                   value="${modoEdicion ? u.documento_identidad : ''}">
            <c:if test="${!modoEdicion}">
                <p class="ayuda">Será también la contraseña inicial del usuario.</p>
            </c:if>
        </div>

        <div class="campo-formulario">
            <label for="rol">Rol</label>
            <c:choose>
                <c:when test="${modoEdicion}">
                    <input type="text" value="${u.rol}" disabled>
                    <p class="ayuda">El rol no se puede cambiar después de crear el usuario.</p>
                </c:when>
                <c:otherwise>
                    <select id="rol" name="rol" required>
                        <option value="">Seleccione...</option>
                        <option value="estudiante">Estudiante</option>
                        <option value="comite">Docente - Comité</option>
                        <option value="director">Docente - Director</option>
                        <option value="evaluador">Docente - Evaluador</option>
                        <option value="coordinacion">Coordinación</option>
                    </select>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- Campos adicionales para estudiante (RF-04) --%>
        <div id="camposEstudiante" class="campo-formulario" hidden>
            <label for="modalidad">Modalidad</label>
            <select id="modalidad" name="modalidad">
                <option value="tecnologico" ${modoEdicion && u.modalidad == 'tecnologico' ? 'selected' : ''}>Desarrollo tecnológico</option>
                <option value="investigacion" ${modoEdicion && u.modalidad == 'investigacion' ? 'selected' : ''}>Proyecto de investigación</option>
                <option value="monografia" ${modoEdicion && u.modalidad == 'monografia' ? 'selected' : ''}>Monografía</option>
                <option value="emprendimiento" ${modoEdicion && u.modalidad == 'emprendimiento' ? 'selected' : ''}>Emprendimiento</option>
                <option value="practica" ${modoEdicion && u.modalidad == 'practica' ? 'selected' : ''}>Práctica empresarial</option>
            </select>

            <label style="margin-top:14px;">¿Individual o en pareja?</label>
            <div class="grupo-opciones">
                <label><input type="radio" name="esPareja" value="false" id="opcionIndividual" ${!modoEdicion || u.es_pareja != true ? 'checked' : ''}> Individual</label>
                <label><input type="radio" name="esPareja" value="true" id="opcionPareja" ${modoEdicion && u.es_pareja == true ? 'checked' : ''}> Pareja</label>
            </div>
            <p class="ayuda" id="avisoModalidadIndividual" hidden>Monografía y práctica empresarial solo admiten modalidad individual.</p>
        </div>

        <%-- Campos adicionales para docente: comite/director/evaluador (RF-02) --%>
        <div id="camposDocente" class="campo-formulario" hidden>
            <label for="tipoVinculacion">Tipo de vinculación</label>
            <select id="tipoVinculacion" name="tipoVinculacion">
                <option value="tiempo completo" ${modoEdicion && u.tipo_vinculacion == 'tiempo completo' ? 'selected' : ''}>Tiempo completo</option>
                <option value="medio tiempo" ${modoEdicion && u.tipo_vinculacion == 'medio tiempo' ? 'selected' : ''}>Medio tiempo</option>
            </select>

            <label for="lineaInvestigacion" style="margin-top:14px;">Línea de investigación</label>
            <input type="text" id="lineaInvestigacion" name="lineaInvestigacion"
                   value="${modoEdicion ? u.linea_investigacion : ''}">
        </div>

        <input type="hidden" id="claveHashInicial" name="claveHashInicial">

        <div class="formulario-acciones">
            <button type="submit" class="boton-primario">Guardar</button>
            <a href="${pageContext.request.contextPath}/gestion-usuarios.jsp" class="boton-secundario">Cancelar</a>
        </div>
    </form>
</div>

<script>
    // El modo de edicion y el rol actual (si aplica) para que
    // usuario-formulario.js sepa que bloque de campos mostrar al cargar.
    var ROL_ACTUAL_EDICION = "${modoEdicion ? u.rol : ''}";
</script>
<script src="${pageContext.request.contextPath}/js/usuario-formulario.js"></script>

<jsp:include page="/WEB-INF/cierre.jsp" />
