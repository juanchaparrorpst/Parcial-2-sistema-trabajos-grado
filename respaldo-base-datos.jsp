<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="tituloPagina" value="Respaldo de base de datos - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="respaldo" scope="request" />
<%-- RNF-10: "Como coordinacion, quiero configurar y ejecutar copias de
     seguridad". Se agrega administrador porque ya administra el resto de la
     infraestructura (usuarios, roles) en el sistema. --%>
<c:set var="rolesPermitidos" value=",administrador,coordinacion," scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<%--
    RNF-10 no se puede "ejecutar" ni "programar" desde una pagina JSTL/JS:
    correr mysqldump o crear una tarea programada del sistema operativo
    requiere ejecutar un proceso del servidor, y sin .java ni scriptlets no
    hay forma de hacerlo desde dentro de una peticion HTTP (regla 1 del
    proyecto). La solucion -- infraestructura, no codigo de la aplicacion,
    igual que los .bat de Tomcat del Prompt 0.1 -- es scripts/respaldo-bd.ps1
    (PowerShell, usa mysqldump de XAMPP) programado con el Programador de
    tareas de Windows. Esta pagina solo CONSULTA el resultado (los archivos
    que ya existen en WEB-INF/backups/) y documenta como esta programado y
    como se restaura.

    WEB-INF/backups/ no es publica (a diferencia de /uploads/): un volcado
    de la base de datos trae TODOS los datos de la aplicacion, incluidos los
    hashes de contrasena, y no debe quedar servible como archivo estatico.
    Por eso esta pagina solo muestra metadatos (nombre, fecha, tamaño) y
    nunca ofrece un enlace de descarga.

    getResourcePaths(...) + getResource(...).openConnection() son metodos
    estandar de ServletContext/URLConnection (JDK/Servlet API), invocados
    con EL 3.0 igual que request.getPart(...)/.write(...) en las paginas de
    carga de archivos (ver "Decision: carga de archivos sin .java" en
    SEGUIMIENTO_PROYECTO.md) -- no es codigo .java propio.
--%>
<c:set var="rutasBackup" value="${pageContext.request.getServletContext().getResourcePaths('/WEB-INF/backups/')}" />

<div class="titulo-pagina">
    <h2>Respaldo de <span class="insignia-verde">BASE DE DATOS</span></h2>
</div>

<p class="ayuda" style="margin-bottom:16px;">
    Las copias de seguridad de <code>sistema_tg</code> se generan con una tarea programada de Windows que corre
    <code>scripts/respaldo-bd.ps1</code> (usa <code>mysqldump</code>, incluido con XAMPP). Se guardan en el servidor,
    fuera del alcance del navegador, y se conservan las últimas 14.
</p>

<dl class="tarjeta-info" style="margin-bottom:20px;">
    <dt>Programación configurada</dt>
    <dd>Diaria, 02:00 a.m. — tarea de Windows <code>RespaldoSistemaTG</code> (<code>schtasks /Create /SC DAILY /ST 02:00 ...</code>, ver el encabezado de <code>scripts/respaldo-bd.ps1</code>).</dd>
    <dt>Cómo restaurar una copia</dt>
    <dd><code>mysql --default-character-set=utf8mb4 -u root sistema_tg &lt; WEB-INF\backups\archivo.sql</code> (probado como CP-10, ver SEGUIMIENTO_PROYECTO.md).</dd>
</dl>

<h3 style="margin-bottom:10px;">Copias existentes en el servidor</h3>
<div class="tabla-contenedor">
    <table class="tabla-datos">
        <thead>
            <tr><th>Archivo</th><th>Fecha</th><th>Hora</th><th>Tamaño</th></tr>
        </thead>
        <tbody>
            <%-- rutasBackup siempre trae al menos /WEB-INF/backups/.gitkeep (para
                 que Git versione la carpeta vacia), asi que "empty rutasBackup"
                 nunca es cierto -- se cuenta aparte cuantas filas .sql hubo. --%>
            <c:set var="totalCopias" value="0" />
            <c:forEach var="ruta" items="${rutasBackup}">
                <c:if test="${fn:endsWith(ruta, '.sql')}">
                    <c:set var="totalCopias" value="${totalCopias + 1}" />
                    <c:set var="nombre" value="${fn:substringAfter(ruta, '/WEB-INF/backups/')}" />
                    <%-- El nombre ya trae la fecha/hora (sistema_tg_YYYYMMDD_HHMMSS.sql);
                         se recorta con funciones de texto en vez de convertir a
                         java.util.Date, que la EL estandar no sabe construir a
                         partir de un "long" sin .java. --%>
                    <c:set var="marca" value="${fn:substringBefore(fn:substringAfter(nombre, 'sistema_tg_'), '.sql')}" />
                    <c:set var="tamanoBytes" value="${pageContext.servletContext.getResource(ruta).openConnection().getContentLengthLong()}" />
                    <tr>
                        <td><c:out value="${nombre}" /></td>
                        <td>${fn:substring(marca, 6, 8)}/${fn:substring(marca, 4, 6)}/${fn:substring(marca, 0, 4)}</td>
                        <td>${fn:substring(marca, 9, 11)}:${fn:substring(marca, 11, 13)}:${fn:substring(marca, 13, 15)}</td>
                        <td><fmt:formatNumber value="${tamanoBytes / 1024}" maxFractionDigits="1" /> KB</td>
                    </tr>
                </c:if>
            </c:forEach>
            <c:if test="${totalCopias == 0}">
                <tr><td colspan="4">Todavía no hay copias de seguridad generadas en este servidor.</td></tr>
            </c:if>
        </tbody>
    </table>
</div>

<jsp:include page="/WEB-INF/cierre.jsp" />
