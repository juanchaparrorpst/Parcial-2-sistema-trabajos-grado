<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Base documental - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="base-documental" scope="request" />
<%-- RF-34: "cualquier rol" consulta, sin permisos especiales -- por eso no
     se fija rolesPermitidos (cualquiera con sesion iniciada entra). --%>
<jsp:include page="/WEB-INF/menu.jsp" />

<div class="titulo-pagina">
    <h2>Base <span class="insignia-verde">DOCUMENTAL</span></h2>
</div>
<p class="ayuda" style="margin-bottom:16px;">
    Formatos institucionales del proceso de trabajo de grado y enlace a la base documental de la UTS.
</p>

<div class="tabla-contenedor" style="margin-bottom:24px;">
    <table class="tabla-datos">
        <thead>
            <tr>
                <th>Formato</th>
                <th>Descripción</th>
                <th>Word</th>
                <th>PDF</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>F-DC-124</td>
                <td>Propuesta o anteproyecto que el estudiante envía al director (RF-21).</td>
                <td><a class="boton-secundario" href="${pageContext.request.contextPath}/formatos/F-DC-124_plantilla.docx">Descargar Word</a></td>
                <td><a class="boton-secundario" href="${pageContext.request.contextPath}/formatos/F-DC-124_plantilla.pdf">Descargar .pdf</a></td>
            </tr>
            <tr>
                <td>F-DC-125</td>
                <td>Formato de evaluación que firma el evaluador al aprobar (RF-24).</td>
                <td><a class="boton-secundario" href="${pageContext.request.contextPath}/formatos/F-DC-125_plantilla.docx">Descargar Word</a></td>
                <td><a class="boton-secundario" href="${pageContext.request.contextPath}/formatos/F-DC-125_plantilla.pdf">Descargar .pdf</a></td>
            </tr>
        </tbody>
    </table>
</div>

<p class="campo-formulario ayuda" style="margin-bottom:16px;">
    Estas plantillas son un <strong>ejemplo para el proyecto académico</strong> (muestran los campos que pide cada formato); no son los documentos oficiales de la UTS. El documento ya diligenciado y firmado se carga desde la pantalla del proyecto correspondiente (formato 124, Turnitin/formato 125, documentos de fase 4).
</p>

<div class="pagina-marcador">
    <p>Los documentos oficiales, resoluciones y demás material de apoyo del proceso de trabajo de grado están en la base documental institucional de la UTS.</p>
    <a class="boton-primario" target="_blank" rel="noopener noreferrer"
       href="https://www.dropbox.com/scl/fo/pudgcaq639agy7t06ahjs/AF-dMByc71OWsxcfY2dLe3A?rlkey=6s0b9ajweteyx2ang7ywvk6xm&e=1&dl=0">
        Abrir base documental institucional de la UTS
    </a>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
