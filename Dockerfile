

# Usamos una imagen oficial de Tomcat con Java
FROM tomcat:9.0-jdk11

# Eliminamos las aplicaciones por defecto que trae Tomcat para limpiar espacio
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiamos tu proyecto actual (o tu archivo WAR si ya lo generaste) a la ruta de webapps de Tomcat en el contenedor
# Opción A: Si copias la carpeta completa del proyecto renombrándola como ROOT (para que abra en la raíz de la web)
COPY . /usr/local/tomcat/webapps/ROOT/

# Exponemos el puerto 8080 que es el que usa Tomcat por defecto
EXPOSE 8080

# Comando para iniciar Tomcat
CMD ["catalina.sh", "run"]
