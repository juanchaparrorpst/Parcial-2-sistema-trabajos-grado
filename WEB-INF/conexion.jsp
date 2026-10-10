<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%--
    Fragmento de conexion a la base de datos. Se incluye con <jsp:include
    page="/WEB-INF/conexion.jsp" /> desde las paginas que necesiten datos.
    Al estar dentro de WEB-INF, el navegador no puede pedirlo directamente.

    Desde el Prompt D.2: la conexion real (driver, url, usuario, contraseña)
    ya NO esta escrita aqui. Este archivo solo busca por JNDI el DataSource
    "jdbc/sistemaTG" que declara META-INF/context.xml, que a su vez lee los
    datos de conexion de variables de entorno del sistema operativo (con
    los valores de XAMPP como valor por defecto en desarrollo local). Asi,
    ninguna credencial de produccion queda escrita en el repositorio, y
    este mismo archivo sirve igual para desarrollo local y para produccion
    -- lo unico que cambia entre un entorno y otro son las variables de
    entorno, nunca el codigo.

    <sql:setDataSource dataSource="jdbc/sistemaTG" .../> es sintaxis
    estandar de JSTL: cuando "dataSource" es un String (no un objeto
    DataSource), JSTL lo trata como un nombre JNDI relativo a
    java:comp/env -- no hace falta ningun codigo Java propio para esto.

    useOldAliasMetadataBehavior=true (Prompt 2.1, ahora en META-INF/context.xml):
    <sql:query> de JSTL 1.2 arma el mapa de cada fila con
    ResultSetMetaData.getColumnName(), que por defecto en Connector/J
    devuelve el nombre FISICO de la columna e ignora los alias "AS" de la
    consulta (es un bug/limitacion conocida de esta version de JSTL). Esta
    propiedad hace que Connector/J responda el alias tambien en
    getColumnName(), para poder escribir "SELECT x AS y" y leer ${fila.y}
    tal cual. Sin esto, columnas con el mismo nombre en tablas distintas
    (ej. dos "nombre") se pisan entre si en el mapa de la fila.
--%>
<sql:setDataSource var="dsSistemaTG" scope="application"
    dataSource="jdbc/sistemaTG" />
