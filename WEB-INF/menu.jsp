<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    Encabezado + menu lateral, comun a todas las pantallas. Se incluye con
    <jsp:include page="/WEB-INF/menu.jsp" /> al principio de cada pagina;
    la pagina cierra lo que este fragmento abre incluyendo despues
    /WEB-INF/cierre.jsp.

    Este fragmento verifica la sesion internamente (incluye
    verificar-sesion.jsp): si nadie ha iniciado sesion, redirige a
    login.jsp antes de dibujar nada. Por eso toda pagina que incluya
    menu.jsp queda protegida automaticamente, sin tener que acordarse de
    agregar el guard por separado.

    Variables que la pagina puede fijar en request ANTES de este include:
      - tituloPagina: texto para la etiqueta <title> (por defecto el nombre
        del sistema).
      - menuActivo: uno de "inicio", "perfil", "banco-ideas", "propuestas",
        "base-documental", "calendario", "usuarios" - resalta esa opcion
        del menu.
      - rolesPermitidos: ver WEB-INF/verificar-sesion.jsp. Si la pagina no
        la fija, cualquier usuario con sesion iniciada puede entrar.

    El menu lateral es el mismo para todos los roles, salvo "Gestión de
    usuarios" que solo ve el administrador.
--%>
<jsp:include page="/WEB-INF/verificar-sesion.jsp" />
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${empty tituloPagina ? 'Sistema de Gestion de Trabajos de Grado - UTS' : tituloPagina}" /></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css?v=5">
</head>
<body>
<div class="app-layout">

    <aside class="barra-lateral">
        <div class="barra-lateral-encabezado">
            <div class="barra-lateral-logo">
                <img src="${pageContext.request.contextPath}/img/logo-uts.jpeg" alt="Universitaria Tecnologica de Santander">
            </div>
            <button type="button" class="boton-colapsar" aria-label="Mostrar u ocultar menu">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><path d="M3 6h18M3 12h18M3 18h18"/></svg>
            </button>
        </div>

        <ul class="menu-lateral">
            <li class="${menuActivo == 'inicio' ? 'activo' : ''}">
                <a href="${pageContext.request.contextPath}/index.jsp">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 11.5 12 4l8 7.5"/><path d="M6 10v9h12v-9"/></svg>
                    <span class="menu-etiqueta">Inicio</span>
                </a>
            </li>
            <li class="${menuActivo == 'perfil' ? 'activo' : ''}">
                <a href="${pageContext.request.contextPath}/mi-perfil.jsp">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3.3"/><path d="M5 20c1.2-3.6 4-5.4 7-5.4s5.8 1.8 7 5.4"/></svg>
                    <span class="menu-etiqueta">Mi perfil</span>
                </a>
            </li>
            <li class="${menuActivo == 'banco-ideas' ? 'activo' : ''}">
                <a href="${pageContext.request.contextPath}/banco-ideas.jsp">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5C5.5 4.6 7.3 4.2 9 4.5c1 .2 2 .6 3 1.2V19c-1-.6-2-1-3-1.2-1.7-.3-3.5.1-5 1V5.5Z"/><path d="M20 5.5c-1.5-.9-3.3-1.3-5-1-1 .2-2 .6-3 1.2V19c1-.6 2-1 3-1.2 1.7-.3 3.5.1 5 1V5.5Z"/></svg>
                    <span class="menu-etiqueta">Banco de ideas</span>
                </a>
            </li>
            <li class="${menuActivo == 'propuestas' ? 'activo' : ''}">
                <a href="${pageContext.request.contextPath}/propuestas-banco.jsp">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M5 20V6a2 2 0 0 1 2-2h7l5 5v11a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2Z"/><path d="M14 4v5h5"/><path d="M8.5 13h7M8.5 16.5h5"/></svg>
                    <span class="menu-etiqueta">Propuestas Banco</span>
                </a>
            </li>
            <c:if test="${sessionScope.usuarioRol != 'administrador'}">
                <li class="${menuActivo == 'proyectos' ? 'activo' : ''}">
                    <a href="${pageContext.request.contextPath}/mis-proyectos.jsp">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="4" width="17" height="16" rx="2"/><path d="M8 9h8M8 13h8M8 17h5"/></svg>
                        <span class="menu-etiqueta">Proyectos</span>
                    </a>
                </li>
            </c:if>
            <li class="${menuActivo == 'base-documental' ? 'activo' : ''}">
                <a href="${pageContext.request.contextPath}/base-documental.jsp">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3.5 7.5 6 5h5l2 2.5h7.5v10a1.5 1.5 0 0 1-1.5 1.5H5a1.5 1.5 0 0 1-1.5-1.5v-10Z"/></svg>
                    <span class="menu-etiqueta">Base documental</span>
                </a>
            </li>
            <li class="${menuActivo == 'calendario' ? 'activo' : ''}">
                <a href="${pageContext.request.contextPath}/calendario-academico.jsp">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="5.5" width="16" height="14.5" rx="1.8"/><path d="M4 10h16M8 3.5v3.5M16 3.5v3.5"/></svg>
                    <span class="menu-etiqueta">Calendario académico</span>
                </a>
            </li>
            <c:if test="${sessionScope.usuarioRol == 'administrador'}">
                <li class="${menuActivo == 'usuarios' ? 'activo' : ''}">
                    <a href="${pageContext.request.contextPath}/gestion-usuarios.jsp">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3"/><path d="M3.5 19c.9-3 3-4.6 5.5-4.6s4.6 1.6 5.5 4.6"/><circle cx="17" cy="8.5" r="2.3"/><path d="M15.5 14.6c1.9.4 3.3 1.8 4 4.4"/></svg>
                        <span class="menu-etiqueta">Gestión de usuarios</span>
                    </a>
                </li>
            </c:if>
            <c:if test="${sessionScope.usuarioRol == 'administrador' or sessionScope.usuarioRol == 'coordinacion' or sessionScope.usuarioRol == 'comite'}">
                <li class="${menuActivo == 'requisitos' ? 'activo' : ''}">
                    <a href="${pageContext.request.contextPath}/verificar-requisitos.jsp">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12.5l2 2 4-4.5"/><rect x="3.5" y="4" width="17" height="16" rx="2"/></svg>
                        <span class="menu-etiqueta">Verificar requisitos</span>
                    </a>
                </li>
            </c:if>
            <c:if test="${sessionScope.usuarioRol == 'coordinacion' or sessionScope.usuarioRol == 'comite'}">
                <li class="${menuActivo == 'sesion-comite' ? 'activo' : ''}">
                    <a href="${pageContext.request.contextPath}/sesion-comite.jsp">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/></svg>
                        <span class="menu-etiqueta">Sesión del comité</span>
                    </a>
                </li>
                <li class="${menuActivo == 'actas-comite' ? 'activo' : ''}">
                    <a href="${pageContext.request.contextPath}/actas-comite.jsp">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M6 3.5h9l3 3v14H6z"/><path d="M9 9h6M9 12.5h6M9 16h4"/></svg>
                        <span class="menu-etiqueta">Actas del comité</span>
                    </a>
                </li>
            </c:if>
            <c:if test="${sessionScope.usuarioRol == 'comite' or sessionScope.usuarioRol == 'coordinacion' or sessionScope.usuarioRol == 'director' or sessionScope.usuarioRol == 'evaluador'}">
                <li class="${menuActivo == 'historico' ? 'activo' : ''}">
                    <a href="${pageContext.request.contextPath}/historico-proyectos.jsp">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="12" r="7.5"/><path d="M11 7.5V12l3.2 2M4 5l2.2 1.6M18 5l-2.2 1.6"/></svg>
                        <span class="menu-etiqueta">Histórico de proyectos</span>
                    </a>
                </li>
            </c:if>
            <c:if test="${sessionScope.usuarioRol == 'administrador' or sessionScope.usuarioRol == 'coordinacion'}">
                <li class="${menuActivo == 'respaldo' ? 'activo' : ''}">
                    <a href="${pageContext.request.contextPath}/respaldo-base-datos.jsp">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="6" rx="7.5" ry="2.8"/><path d="M4.5 6v12c0 1.5 3.4 2.8 7.5 2.8s7.5-1.3 7.5-2.8V6"/><path d="M4.5 12c0 1.5 3.4 2.8 7.5 2.8s7.5-1.3 7.5-2.8"/></svg>
                        <span class="menu-etiqueta">Respaldo de base de datos</span>
                    </a>
                </li>
            </c:if>
        </ul>
    </aside>

    <div class="columna-principal">
        <header class="encabezado-superior">
            <h1>Bienvenido</h1>
            <div class="usuario-sesion">
                <span class="avatar">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3.3"/><path d="M5 20c1.2-3.6 4-5.4 7-5.4s5.8 1.8 7 5.4"/></svg>
                </span>
                <span>
                    <c:out value="${sessionScope.usuarioNombre}" />
                    <span class="usuario-rol">
                        <c:out value="${sessionScope.usuarioRol}" />
                        &middot;
                        <a class="enlace-cerrar-sesion" href="${pageContext.request.contextPath}/cerrar-sesion.jsp">Cerrar sesión</a>
                    </span>
                </span>
            </div>
        </header>

        <main class="contenido">