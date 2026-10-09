-- ============================================================================
-- Sistema de Gestion de Trabajos de Grado - UTS
-- Datos de prueba
--
-- Requiere haber ejecutado antes 01_esquema.sql sobre una base vacia (los
-- IDs de este script asumen autoincremento empezando en 1, en el mismo orden
-- de insercion de abajo).
--
-- Cubre:
--   - Un usuario de cada rol: administrador, coordinacion, comite, director,
--     evaluador, estudiante (no existe el rol secretaria).
--   - 3 periodos academicos (banco_ideas, propuesta, pago).
--   - 5 ideas en los 3 estados posibles (pendiente, aprobada, con_correcciones).
--   - 2 proyectos en fases distintas (fase 2 y fase 4), uno individual y uno
--     en pareja, con su asignacion de director/evaluador/codirector.
-- ============================================================================

USE sistema_tg;

-- ----------------------------------------------------------------------------
-- usuario (id 1-8): un usuario por rol + 2 estudiantes adicionales para
-- poder mostrar un proyecto en pareja.
-- ----------------------------------------------------------------------------
INSERT INTO usuario (nombre_completo, correo, documento_identidad, rol, activo) VALUES
('Lizeth Karina Montañez Vargas', 'lizeth.montanez@correo.uts.edu.co', '1005123456', 'administrador', TRUE),
('Juan Miguel Chaparro Serrano',  'juan.chaparro@correo.uts.edu.co',   '1005123457', 'coordinacion',  TRUE),
('Olga Patricia Delgado Rueda',   'olga.delgado@correo.uts.edu.co',    '63487521',   'comite',        TRUE),
('Hernán Darío Martínez López',   'hernan.martinez@correo.uts.edu.co', '91234567',   'director',      TRUE),
('Martha Lucía Pinzón Cote',      'martha.pinzon@correo.uts.edu.co',   '37589412',   'evaluador',     TRUE),
('Carlos Andrés Rueda Gómez',     'carlos.rueda@correo.uts.edu.co',    '1098765432', 'estudiante',    TRUE),
('Daniela Fernanda Ortiz Silva',  'daniela.ortiz@correo.uts.edu.co',   '1098765433', 'estudiante',    TRUE),
('Esteban Camilo Vargas Peña',    'esteban.vargas@correo.uts.edu.co',  '1098765434', 'estudiante',    TRUE);

-- ----------------------------------------------------------------------------
-- docente (id 1-3): comite, director y evaluador tambien tienen perfil de
-- docente, porque idea.docente_id y asignacion.director_id/evaluador_id/
-- codirector_id apuntan a esta tabla (ver matriz de permisos: comite,
-- director y evaluador pueden publicar ideas).
-- ----------------------------------------------------------------------------
INSERT INTO docente (usuario_id, tipo_vinculacion, linea_investigacion) VALUES
(3, 'tiempo completo', 'Inteligencia Artificial y Ciencia de Datos'),  -- docente.id = 1 (Olga, comite)
(4, 'tiempo completo', 'Desarrollo de Software'),                     -- docente.id = 2 (Hernán, director)
(5, 'medio tiempo',    'Redes y Telecomunicaciones');                 -- docente.id = 3 (Martha, evaluador)

-- ----------------------------------------------------------------------------
-- estudiante (id 1-3)
-- ----------------------------------------------------------------------------
INSERT INTO estudiante (usuario_id, modalidad, es_pareja, porcentaje_creditos, metodologia_aprobada) VALUES
(6, 'tecnologico',   FALSE, 40.00, TRUE),  -- estudiante.id = 1 (Carlos, individual)
(7, 'investigacion', TRUE,  55.00, TRUE),  -- estudiante.id = 2 (Daniela, lider de pareja)
(8, 'investigacion', TRUE,  52.00, TRUE);  -- estudiante.id = 3 (Esteban, pareja de Daniela)

-- ----------------------------------------------------------------------------
-- periodo (id 1-3)
-- ----------------------------------------------------------------------------
INSERT INTO periodo (nombre, fecha_inicio, fecha_fin, modulo) VALUES
('Banco de ideas 2027-1', '2026-10-26', '2026-12-04', 'banco_ideas'),
('Propuestas 2026-2',     '2026-08-01', '2026-09-15', 'propuesta'),
('Pagos 2026-2',          '2026-07-15', '2026-08-15', 'pago');

-- ----------------------------------------------------------------------------
-- idea (id 1-5): 2 aprobada, 2 pendiente, 1 con_correcciones.
-- Las ideas 1 y 2 ya se convirtieron en propuesta/proyecto -> disponible = FALSE.
-- ----------------------------------------------------------------------------
INSERT INTO idea (titulo, objetivo, descripcion, linea_investigacion, nivel, periodo_id, docente_id, estado, disponible) VALUES
('Sistema de monitoreo de consumo electrico con IoT',
 'Reducir el consumo electrico de los bloques academicos mediante monitoreo en tiempo real.',
 'Red de sensores IoT que reporta el consumo electrico por bloque y genera alertas de consumo anormal.',
 'Internet de las Cosas', 'tecnologia', 1, 2, 'aprobada', FALSE),
('Plataforma de trazabilidad agricola con blockchain',
 'Dar trazabilidad verificable a productos agricolas de pequenos productores de la region.',
 'Plataforma web que registra en blockchain cada etapa de la cadena de produccion agricola.',
 'Blockchain y Cadenas de Suministro', 'ingenieria', 1, 1, 'aprobada', FALSE),
('Aplicativo de gestion de turnos para laboratorios',
 'Organizar el uso de los laboratorios de computo mediante reserva de turnos.',
 'Aplicativo web para que los estudiantes reserven turnos de uso de laboratorio y los docentes los administren.',
 'Ingenieria de Software', 'tecnologia', 1, 3, 'pendiente', TRUE),
('Modelo predictivo de desercion estudiantil',
 'Identificar tempranamente estudiantes en riesgo de desercion.',
 'Modelo de aprendizaje automatico que cruza variables academicas y socioeconomicas para predecir desercion.',
 'Inteligencia Artificial y Ciencia de Datos', 'ingenieria', 1, 1, 'con_correcciones', TRUE),
('Sistema de inventario para laboratorio de redes',
 'Controlar el inventario de equipos del laboratorio de redes.',
 'Sistema web para registrar prestamo, devolucion y estado de los equipos del laboratorio de redes.',
 'Redes y Telecomunicaciones', 'tecnologia', 1, 2, 'pendiente', TRUE);

-- ----------------------------------------------------------------------------
-- propuesta (id 1-2): una por cada idea que ya tiene proyecto.
-- ----------------------------------------------------------------------------
INSERT INTO propuesta (idea_id, titulo, objetivo, descripcion, linea_investigacion, estudiante_lider_id, estado) VALUES
(1, 'Sistema de monitoreo de consumo electrico con IoT para bloques academicos UTS',
 'Reducir el consumo electrico de los bloques academicos mediante monitoreo en tiempo real.',
 'Implementacion de la red de sensores IoT propuesta en la idea original, aplicada a 3 bloques del campus.',
 'Internet de las Cosas', 1, 'aprobada'),
(2, 'Plataforma de trazabilidad agricola con blockchain para pequenos productores de Santander',
 'Dar trazabilidad verificable a productos agricolas de pequenos productores de la region.',
 'Desarrollo de la plataforma de trazabilidad propuesta en la idea original, con productores piloto de Santander.',
 'Blockchain y Cadenas de Suministro', 2, 'aprobada');

-- ----------------------------------------------------------------------------
-- proyecto (id 1-2): uno individual en fase 2, uno en pareja en fase 4.
-- Consecutivo: 65 = primer proyecto de tecnologia, 125 = primer proyecto de
-- ingenieria, segun el glosario del documento de requerimientos.
-- ----------------------------------------------------------------------------
INSERT INTO proyecto (consecutivo, anio, nivel, modalidad, fase_actual, estado, idea_id, propuesta_id) VALUES
(65,  2026, 'tecnologia', 'tecnologico',   2, 'en_fase', 1, 1),
(125, 2026, 'ingenieria', 'investigacion', 4, 'en_fase', 2, 2);

-- ----------------------------------------------------------------------------
-- proyecto_integrante
-- ----------------------------------------------------------------------------
INSERT INTO proyecto_integrante (proyecto_id, estudiante_id, es_lider) VALUES
(1, 1, TRUE),   -- Proyecto 1 (individual): Carlos, lider
(2, 2, TRUE),   -- Proyecto 2 (pareja): Daniela, lider
(2, 3, FALSE);  -- Proyecto 2 (pareja): Esteban

-- ----------------------------------------------------------------------------
-- asignacion
-- ----------------------------------------------------------------------------
INSERT INTO asignacion (proyecto_id, director_id, evaluador_id, codirector_id) VALUES
(1, 2, 3, NULL),  -- Proyecto 1: director Hernán, evaluador Martha, sin codirector
(2, 2, 3, 1);     -- Proyecto 2: director Hernán, evaluador Martha, codirector Olga
