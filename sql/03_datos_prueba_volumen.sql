-- ============================================================================
-- Sistema de Gestion de Trabajos de Grado - UTS
-- Datos de volumen para probar RNF-08 (rendimiento de busqueda) / CP-09
--
-- Genera 400 estudiantes de prueba (usuario + estudiante), ademas de los 8
-- usuarios de sql/02_datos_prueba.sql. Es SOLO para medir el tiempo de
-- respuesta de la busqueda de RF-30 con volumen real; no se deja cargado de
-- forma permanente en la base de "verdad" del proyecto.
--
-- Uso:
--   mysql --default-character-set=utf8mb4 -u root < sql/03_datos_prueba_volumen.sql
--   (medir la busqueda en mis-proyectos.jsp)
--   mysql --default-character-set=utf8mb4 -u root sistema_tg -e "
--       DELETE FROM estudiante WHERE usuario_id IN (SELECT id FROM usuario WHERE correo LIKE 'estudiante.prueba%@correo.uts.edu.co');
--       DELETE FROM usuario WHERE correo LIKE 'estudiante.prueba%@correo.uts.edu.co';"
--
-- El hash de contrasena es un valor fijo (no es una contraseña real, no se
-- necesita iniciar sesion con estos usuarios para medir la busqueda).
--
-- Requiere MySQL/MariaDB con soporte de CTE recursivo (MariaDB >= 10.2.2,
-- confirmado contra MariaDB 10.4.32 de XAMPP, que es la version local de
-- este proyecto).
-- ============================================================================

USE sistema_tg;

INSERT INTO usuario (nombre_completo, correo, documento_identidad, rol, contrasena_hash, activo)
WITH RECURSIVE numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numeros WHERE n < 400
)
SELECT
    CONCAT('Estudiante Prueba ', LPAD(n, 3, '0')),
    CONCAT('estudiante.prueba', LPAD(n, 3, '0'), '@correo.uts.edu.co'),
    CONCAT('9', LPAD(n, 9, '0')),
    'estudiante',
    REPEAT('0', 64),
    TRUE
FROM numeros;

INSERT INTO estudiante (usuario_id, modalidad, es_pareja, porcentaje_creditos, metodologia_aprobada)
SELECT u.id, 'tecnologico', FALSE, 50.00, TRUE
FROM usuario u
WHERE u.correo LIKE 'estudiante.prueba%@correo.uts.edu.co';
