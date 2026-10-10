# Sistema de Gestion de Trabajos de Grado - UTS
# Imagen Docker para desplegar el proyecto en Render (Prompt D.3).
#
# El proyecto es 100% JSTL/JS (regla 1): no hay ningun archivo .java propio
# que compilar, asi que "construir el WAR" es solo empaquetar los archivos
# que ya existen con la herramienta "jar" del JDK (parte estandar del JDK,
# no es un build propio ni requiere Maven/Gradle).
#
# Base: Tomcat 9.0. En local (XAMPP) corre Tomcat 8.5.96 con el namespace
# javax.* (Servlet 3.1 / JSP 2.3), que es el que usa JSTL 1.2
# (javax.servlet.jsp.jstl, ver WEB-INF/lib/jstl-1.2.jar). Tomcat 9 sigue
# usando ese mismo namespace javax.* (Servlet 4.0 / JSP 2.3) y es
# totalmente compatible con el web.xml Servlet 3.1 del proyecto, asi que
# el mismo codigo corre igual. Tomcat 8.5 ya no tiene una imagen oficial
# vigente en Docker Hub con JDK moderno; Tomcat 10+ NO sirve porque cambia
# al namespace jakarta.* y rompe JSTL 1.2 (el proyecto tendria que migrar
# todas las paginas a jakarta.servlet.jsp.jstl, algo que no se pidio).

# ---- Etapa 1: empaquetar el proyecto como sistema-tg.war -------------------
FROM tomcat:9.0-jdk17-temurin AS build
WORKDIR /build
COPY . .
# "-C . ." = pararse en el directorio actual y agregar su contenido completo
# al .war, preservando las rutas relativas (WEB-INF/, css/, js/, *.jsp en la
# raiz, etc.) tal como las espera Tomcat. .dockerignore excluye lo que no
# debe quedar servible por HTTP (sql/, scripts/, .git) - ver ese archivo.
RUN jar -cf sistema-tg.war -C . .

# ---- Etapa 2: imagen final, solo con Tomcat + el WAR ya armado -------------
FROM tomcat:9.0-jdk17-temurin

# Tomcat trae una app de ejemplo en ROOT (la pantalla de bienvenida); se
# quita para que http://localhost:8080/ no la muestre en vez del sistema.
RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY --from=build /build/sistema-tg.war /usr/local/tomcat/webapps/sistema-tg.war

# Prompt D.2: activa que Tomcat resuelva ${VARIABLE} dentro de
# META-INF/context.xml contra variables de entorno del sistema operativo
# (CC_MYSQL_HOST, CC_MYSQL_PORT, CC_MYSQL_DB, CC_MYSQL_USER,
# CC_MYSQL_PASSWORD), no solo contra propiedades -D de la JVM.
# EnvironmentPropertySource es una clase que trae el propio Tomcat
# (catalina.jar); esto es solo una bandera de configuracion, no codigo
# propio. catalina.sh/.bat ya agrega CATALINA_OPTS al comando java al
# arrancar -- no hace falta nada mas.
ENV CATALINA_OPTS="-Dorg.apache.tomcat.util.digester.PROPERTY_SOURCE=org.apache.tomcat.util.digester.EnvironmentPropertySource"

# Tomcat despliega automaticamente cualquier .war que encuentre en
# webapps/ al arrancar (unpackWARs=true por defecto) -- no hace falta nada
# mas para que quede en http://localhost:8080/sistema-tg/, igual que con
# el junction de XAMPP en desarrollo local.
EXPOSE 8080
