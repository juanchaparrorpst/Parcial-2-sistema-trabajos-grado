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

    useOldAliasMetadataBehavior=true (Prompt 2.1): <sql:query> de JSTL 1.2
    arma el mapa de cada fila con ResultSetMetaData.getColumnName(), que por
    defecto en Connector/J devuelve el nombre FISICO de la columna e ignora
    los alias "AS" de la consulta (es un bug/limitacion conocida de esta
    version de JSTL). Esta propiedad hace que Connector/J responda el alias
    tambien en getColumnName(), para poder escribir "SELECT x AS y" y leer
    ${fila.y} tal cual. Sin esto, columnas con el mismo nombre en tablas
    distintas (ej. dos "nombre") se pisan entre si en el mapa de la fila.
--%>
<sql:setDataSource var="dsSistemaTG" scope="application"
    driver="com.mysql.cj.jdbc.Driver"
    url="jdbc:mysql://localhost:3306/sistema_tg?useUnicode=true&characterEncoding=UTF-8&sessionVariables=character_set_client=utf8mb4,character_set_connection=utf8mb4,character_set_results=utf8mb4&useOldAliasMetadataBehavior=true&serverTimezone=America/Bogota"
    user="root"
    password="" />
