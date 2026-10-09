<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="tituloPagina" value="Banco de ideas - Sistema de Gestion de Trabajos de Grado" scope="request" />
<c:set var="menuActivo" value="banco-ideas" scope="request" />
<jsp:include page="/WEB-INF/menu.jsp" />

<%--
    Datos de ejemplo FIJOS, solo para probar el diseño (tabla reutilizable +
    modal de detalle). Se reemplazan por <sql:query> sobre la tabla "idea"
    cuando se implemente el Sprint 2 (banco de ideas real).
--%>
<div class="titulo-pagina">
    <h2>Banco de <span class="insignia-verde">IDEAS</span></h2>
</div>

<jsp:include page="/WEB-INF/tabla-inicio.jsp" />
<table class="tabla-datos">
    <thead>
        <tr>
            <th>Código</th>
            <th>Título</th>
            <th>Modalidad</th>
            <th>Estado</th>
            <th>Acciones</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>IDEA-001</td>
            <td>Sistema de monitoreo de consumo eléctrico con IoT</td>
            <td>Desarrollo tecnológico</td>
            <td><span class="insignia-estado aprobada">Aprobada</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Hernán Darío Martínez López"
                    data-etq-2="Título" data-val-2="Sistema de monitoreo de consumo eléctrico con IoT"
                    data-etq-3="Línea de investigación" data-val-3="Internet de las Cosas"
                    data-etq-4="Modalidad" data-val-4="Desarrollo tecnológico"
                    data-etq-5="Objetivo" data-val-5="Reducir el consumo eléctrico de los bloques académicos mediante monitoreo en tiempo real.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-002</td>
            <td>Plataforma de trazabilidad agrícola con blockchain</td>
            <td>Proyecto de investigación</td>
            <td><span class="insignia-estado aprobada">Aprobada</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Olga Patricia Delgado Rueda"
                    data-etq-2="Título" data-val-2="Plataforma de trazabilidad agrícola con blockchain"
                    data-etq-3="Línea de investigación" data-val-3="Blockchain y Cadenas de Suministro"
                    data-etq-4="Modalidad" data-val-4="Proyecto de investigación"
                    data-etq-5="Objetivo" data-val-5="Dar trazabilidad verificable a productos agrícolas de pequeños productores de la región.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-003</td>
            <td>Aplicativo de gestión de turnos para laboratorios</td>
            <td>Desarrollo tecnológico</td>
            <td><span class="insignia-estado pendiente">Pendiente</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Martha Lucía Pinzón Cote"
                    data-etq-2="Título" data-val-2="Aplicativo de gestión de turnos para laboratorios"
                    data-etq-3="Línea de investigación" data-val-3="Ingeniería de Software"
                    data-etq-4="Modalidad" data-val-4="Desarrollo tecnológico"
                    data-etq-5="Objetivo" data-val-5="Organizar el uso de los laboratorios de cómputo mediante reserva de turnos.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-004</td>
            <td>Modelo predictivo de deserción estudiantil</td>
            <td>Proyecto de investigación</td>
            <td><span class="insignia-estado con-correcciones">Con correcciones</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Olga Patricia Delgado Rueda"
                    data-etq-2="Título" data-val-2="Modelo predictivo de deserción estudiantil"
                    data-etq-3="Línea de investigación" data-val-3="Inteligencia Artificial y Ciencia de Datos"
                    data-etq-4="Modalidad" data-val-4="Proyecto de investigación"
                    data-etq-5="Objetivo" data-val-5="Identificar tempranamente estudiantes en riesgo de deserción.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-005</td>
            <td>Sistema de inventario para laboratorio de redes</td>
            <td>Desarrollo tecnológico</td>
            <td><span class="insignia-estado pendiente">Pendiente</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Hernán Darío Martínez López"
                    data-etq-2="Título" data-val-2="Sistema de inventario para laboratorio de redes"
                    data-etq-3="Línea de investigación" data-val-3="Redes y Telecomunicaciones"
                    data-etq-4="Modalidad" data-val-4="Desarrollo tecnológico"
                    data-etq-5="Objetivo" data-val-5="Controlar el inventario de equipos del laboratorio de redes.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-006</td>
            <td>Chatbot de orientación para estudiantes nuevos</td>
            <td>Emprendimiento</td>
            <td><span class="insignia-estado aprobada">Aprobada</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Martha Lucía Pinzón Cote"
                    data-etq-2="Título" data-val-2="Chatbot de orientación para estudiantes nuevos"
                    data-etq-3="Línea de investigación" data-val-3="Inteligencia Artificial y Ciencia de Datos"
                    data-etq-4="Modalidad" data-val-4="Emprendimiento"
                    data-etq-5="Objetivo" data-val-5="Orientar a estudiantes de primer semestre en trámites y servicios institucionales.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-007</td>
            <td>Portal de seguimiento a prácticas empresariales</td>
            <td>Práctica empresarial</td>
            <td><span class="insignia-estado pendiente">Pendiente</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Olga Patricia Delgado Rueda"
                    data-etq-2="Título" data-val-2="Portal de seguimiento a prácticas empresariales"
                    data-etq-3="Línea de investigación" data-val-3="Ingeniería de Software"
                    data-etq-4="Modalidad" data-val-4="Práctica empresarial"
                    data-etq-5="Objetivo" data-val-5="Centralizar el seguimiento de los estudiantes en práctica con las empresas aliadas.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-008</td>
            <td>Optimización de rutas para transporte universitario</td>
            <td>Proyecto de investigación</td>
            <td><span class="insignia-estado con-correcciones">Con correcciones</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Hernán Darío Martínez López"
                    data-etq-2="Título" data-val-2="Optimización de rutas para transporte universitario"
                    data-etq-3="Línea de investigación" data-val-3="Investigación de Operaciones"
                    data-etq-4="Modalidad" data-val-4="Proyecto de investigación"
                    data-etq-5="Objetivo" data-val-5="Reducir los tiempos de recorrido de las rutas de transporte universitario.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-009</td>
            <td>Sistema de reconocimiento de asistencia por QR</td>
            <td>Desarrollo tecnológico</td>
            <td><span class="insignia-estado aprobada">Aprobada</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Martha Lucía Pinzón Cote"
                    data-etq-2="Título" data-val-2="Sistema de reconocimiento de asistencia por QR"
                    data-etq-3="Línea de investigación" data-val-3="Ingeniería de Software"
                    data-etq-4="Modalidad" data-val-4="Desarrollo tecnológico"
                    data-etq-5="Objetivo" data-val-5="Agilizar el registro de asistencia a clase mediante códigos QR.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-010</td>
            <td>Banco de horas para tutorías entre pares</td>
            <td>Emprendimiento</td>
            <td><span class="insignia-estado pendiente">Pendiente</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Olga Patricia Delgado Rueda"
                    data-etq-2="Título" data-val-2="Banco de horas para tutorías entre pares"
                    data-etq-3="Línea de investigación" data-val-3="Gestión Educativa"
                    data-etq-4="Modalidad" data-val-4="Emprendimiento"
                    data-etq-5="Objetivo" data-val-5="Conectar estudiantes que necesitan refuerzo académico con compañeros tutores.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-011</td>
            <td>Dashboard de indicadores de bienestar universitario</td>
            <td>Proyecto de investigación</td>
            <td><span class="insignia-estado aprobada">Aprobada</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Hernán Darío Martínez López"
                    data-etq-2="Título" data-val-2="Dashboard de indicadores de bienestar universitario"
                    data-etq-3="Línea de investigación" data-val-3="Inteligencia Artificial y Ciencia de Datos"
                    data-etq-4="Modalidad" data-val-4="Proyecto de investigación"
                    data-etq-5="Objetivo" data-val-5="Visualizar indicadores de bienestar estudiantil para apoyar decisiones de Bienestar Universitario.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
        <tr>
            <td>IDEA-012</td>
            <td>Catálogo digital de proyectos de grado finalizados</td>
            <td>Desarrollo tecnológico</td>
            <td><span class="insignia-estado pendiente">Pendiente</span></td>
            <td>
                <button type="button" class="boton-ver"
                    data-titulo-modal="Detalles de la idea"
                    data-etq-1="Docente responsable" data-val-1="Martha Lucía Pinzón Cote"
                    data-etq-2="Título" data-val-2="Catálogo digital de proyectos de grado finalizados"
                    data-etq-3="Línea de investigación" data-val-3="Ingeniería de Software"
                    data-etq-4="Modalidad" data-val-4="Desarrollo tecnológico"
                    data-etq-5="Objetivo" data-val-5="Dar consulta pública a los proyectos de grado ya sustentados del programa.">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3.8-7 10-7 10 7 10 7-3.8 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="2.6"/></svg>
                </button>
            </td>
        </tr>
    </tbody>
</table>
<jsp:include page="/WEB-INF/tabla-fin.jsp" />

<jsp:include page="/WEB-INF/cierre.jsp" />
