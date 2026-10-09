-- ============================================================================
-- Sistema de Gestion de Trabajos de Grado - UTS
-- Esquema de base de datos (MySQL / MariaDB), traducido de modelo_datos.dbml
--
-- Fuente: modelo_datos.dbml (raiz del proyecto). Se respetaron los nombres de
-- tablas, columnas y relaciones, y los modificadores [pk], [increment], [unique],
-- [not null] y [default: ...] tal como estan en ese archivo. Donde el DBML NO
-- marca una columna como [not null], aqui queda NULL-able (no se endurecio
-- nada por cuenta propia).
--
-- El DBML no especifica motor de base de datos, charset ni longitud de los
-- VARCHAR, asi que aqui se tomaron estas decisiones minimas e inevitables:
--   - Motor InnoDB (necesario para llaves foraneas).
--   - Charset utf8mb4 / collation utf8mb4_unicode_ci (tildes y enies,
--     compatible con MySQL y MariaDB).
--   - Una longitud razonable por columna VARCHAR (ver comentario en cada una).
-- No se agrego ninguna columna que no estuviera en el DBML.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS sistema_tg
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sistema_tg;

-- Permite volver a ejecutar este script desde cero sin errores.
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS auditoria;
DROP TABLE IF EXISTS historial_fase;
DROP TABLE IF EXISTS acta;
DROP TABLE IF EXISTS pago;
DROP TABLE IF EXISTS documento;
DROP TABLE IF EXISTS asignacion;
DROP TABLE IF EXISTS proyecto_integrante;
DROP TABLE IF EXISTS proyecto;
DROP TABLE IF EXISTS propuesta;
DROP TABLE IF EXISTS idea;
DROP TABLE IF EXISTS docente;
DROP TABLE IF EXISTS estudiante;
DROP TABLE IF EXISTS periodo;
DROP TABLE IF EXISTS usuario;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- usuario
-- ----------------------------------------------------------------------------
CREATE TABLE usuario (
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo      VARCHAR(150),
    correo               VARCHAR(150) UNIQUE,
    documento_identidad  VARCHAR(20)  UNIQUE,
    -- valores esperados: administrador, coordinacion, comite, director, evaluador, estudiante
    rol                  VARCHAR(20),
    activo               BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- periodo
-- ----------------------------------------------------------------------------
CREATE TABLE periodo (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100),
    fecha_inicio  DATE,
    fecha_fin     DATE,
    -- valores esperados: banco_ideas, modalidad, propuesta, pago
    modulo        VARCHAR(30)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- estudiante
-- ----------------------------------------------------------------------------
CREATE TABLE estudiante (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id             INT NOT NULL UNIQUE,
    -- valores esperados: tecnologico, investigacion, monografia, emprendimiento, practica
    modalidad              VARCHAR(30),
    es_pareja              BOOLEAN DEFAULT FALSE,
    porcentaje_creditos    DECIMAL(5,2),
    metodologia_aprobada   BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_estudiante_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- docente
-- ----------------------------------------------------------------------------
CREATE TABLE docente (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id          INT NOT NULL UNIQUE,
    -- valores esperados: tiempo completo, medio tiempo
    tipo_vinculacion    VARCHAR(30),
    linea_investigacion VARCHAR(150),
    CONSTRAINT fk_docente_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- idea
-- ----------------------------------------------------------------------------
CREATE TABLE idea (
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    titulo               VARCHAR(200),
    objetivo             TEXT,
    descripcion          TEXT,
    linea_investigacion  VARCHAR(150),
    -- valores esperados: tecnologia, ingenieria
    nivel                VARCHAR(20),
    periodo_id           INT,
    docente_id           INT,
    -- valores esperados: pendiente, aprobada, con_correcciones
    estado               VARCHAR(20),
    disponible           BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_idea_periodo FOREIGN KEY (periodo_id) REFERENCES periodo(id),
    CONSTRAINT fk_idea_docente FOREIGN KEY (docente_id) REFERENCES docente(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- propuesta
-- ----------------------------------------------------------------------------
CREATE TABLE propuesta (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    idea_id                INT,
    titulo                 VARCHAR(200),
    objetivo               TEXT,
    descripcion            TEXT,
    linea_investigacion    VARCHAR(150),
    estudiante_lider_id    INT NOT NULL,
    -- valores esperados: pendiente, aprobada, con_correcciones
    estado                 VARCHAR(20),
    CONSTRAINT fk_propuesta_idea FOREIGN KEY (idea_id) REFERENCES idea(id),
    CONSTRAINT fk_propuesta_estudiante FOREIGN KEY (estudiante_lider_id) REFERENCES estudiante(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- proyecto
-- ----------------------------------------------------------------------------
CREATE TABLE proyecto (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    consecutivo    INT,
    anio           INT,
    nivel          VARCHAR(20),
    modalidad      VARCHAR(30),
    -- 1 a 6
    fase_actual    INT DEFAULT 1,
    -- valores esperados: en_fase, finalizado, no_aprobado
    estado         VARCHAR(20),
    idea_id        INT,
    propuesta_id   INT,
    CONSTRAINT fk_proyecto_idea FOREIGN KEY (idea_id) REFERENCES idea(id),
    CONSTRAINT fk_proyecto_propuesta FOREIGN KEY (propuesta_id) REFERENCES propuesta(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- proyecto_integrante (llave primaria compuesta, segun el DBML)
-- ----------------------------------------------------------------------------
CREATE TABLE proyecto_integrante (
    proyecto_id    INT NOT NULL,
    estudiante_id  INT NOT NULL,
    es_lider       BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (proyecto_id, estudiante_id),
    CONSTRAINT fk_integrante_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyecto(id),
    CONSTRAINT fk_integrante_estudiante FOREIGN KEY (estudiante_id) REFERENCES estudiante(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- asignacion (relacion 1 a 1 con proyecto, segun el DBML)
-- ----------------------------------------------------------------------------
CREATE TABLE asignacion (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    proyecto_id     INT NOT NULL UNIQUE,
    director_id     INT,
    evaluador_id    INT,
    codirector_id   INT,
    CONSTRAINT fk_asignacion_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyecto(id),
    CONSTRAINT fk_asignacion_director FOREIGN KEY (director_id) REFERENCES docente(id),
    CONSTRAINT fk_asignacion_evaluador FOREIGN KEY (evaluador_id) REFERENCES docente(id),
    CONSTRAINT fk_asignacion_codirector FOREIGN KEY (codirector_id) REFERENCES docente(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- documento
-- ----------------------------------------------------------------------------
CREATE TABLE documento (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    proyecto_id   INT NOT NULL,
    -- valores esperados: F-DC-124, F-DC-125, liquidacion, informe_similitud, correcciones, fase4
    tipo          VARCHAR(30),
    archivo       VARCHAR(255),
    -- valores esperados: docx, pdf
    formato       VARCHAR(10),
    fecha         DATETIME,
    usuario_id    INT,
    CONSTRAINT fk_documento_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyecto(id),
    CONSTRAINT fk_documento_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- pago
-- ----------------------------------------------------------------------------
CREATE TABLE pago (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    proyecto_id     INT NOT NULL,
    documento_id    INT,
    semestre        VARCHAR(20),
    verificado_por  INT,
    CONSTRAINT fk_pago_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyecto(id),
    CONSTRAINT fk_pago_documento FOREIGN KEY (documento_id) REFERENCES documento(id),
    CONSTRAINT fk_pago_verificador FOREIGN KEY (verificado_por) REFERENCES usuario(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- acta
-- ----------------------------------------------------------------------------
CREATE TABLE acta (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    numero        INT,
    fecha         DATE,
    decision      VARCHAR(30),
    motivo        TEXT,
    idea_id       INT,
    propuesta_id  INT,
    CONSTRAINT fk_acta_idea FOREIGN KEY (idea_id) REFERENCES idea(id),
    CONSTRAINT fk_acta_propuesta FOREIGN KEY (propuesta_id) REFERENCES propuesta(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- historial_fase
-- ----------------------------------------------------------------------------
CREATE TABLE historial_fase (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    proyecto_id  INT NOT NULL,
    fase         INT,
    estado       VARCHAR(30),
    fecha        DATETIME,
    usuario_id   INT,
    CONSTRAINT fk_historial_proyecto FOREIGN KEY (proyecto_id) REFERENCES proyecto(id),
    CONSTRAINT fk_historial_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- auditoria
-- ----------------------------------------------------------------------------
CREATE TABLE auditoria (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id  INT,
    accion      VARCHAR(100),
    entidad     VARCHAR(50),
    fecha       DATETIME,
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id)
) ENGINE=InnoDB;
