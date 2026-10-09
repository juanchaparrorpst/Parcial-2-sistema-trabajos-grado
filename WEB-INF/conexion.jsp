<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%--
    Fragmento de conexion a la base de datos. Se incluye con <jsp:include
    page="/WEB-INF/conexion.jsp" /> desde las paginas que necesiten datos.
    Al estar dentro de WEB-INF, el navegador no puede pedirlo directamente.

    <sql:setDataSource> no abre una conexion real, solo guarda los parametros
    en el DataSource "dsSistemaTG" (applicationScope); por eso no hay problema
    en volver a ejecutarlo en cada inclusion.

    Datos de conexion local (XAMPP): usuario root sin contraseña, base
    "sistema_tg" creada por sql/01_esquema.sql. En produccion (Render +
    Clever Cloud) este archivo se reemplaza por uno que lea las variables
    de entorno (ver Prompt D.2 del plan de implementacion); no se suben
    credenciales de produccion a este repositorio.
--%>
<sql:setDataSource var="dsSistemaTG" scope="application"
    driver="com.mysql.cj.jdbc.Driver"
    url="jdbc:mysql://localhost:3306/sistema_tg?useUnicode=true&characterEncoding=UTF-8&serverTimezone=America/Bogota"
    user="root"
    password="" />
