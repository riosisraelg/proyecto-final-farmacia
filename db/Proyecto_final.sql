-- ============================================================================
-- PROYECTO FINAL - FARMACIA CON CONSULTORIO MEDICO
-- ============================================================================
DROP DATABASE IF EXISTS proyecto_final_data_base;
CREATE DATABASE proyecto_final_data_base;
USE proyecto_final_data_base;

-- ============================================================================
-- 1. EMPLEADOS
-- Información general de trabajadores del consultorio y farmacia.
-- ============================================================================

CREATE TABLE Empleados (
    id_empleado VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    puesto VARCHAR(60) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(100),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_ingreso DATE NOT NULL
);


-- ============================================================================
-- 2. MEDICOS
-- Extensión de Empleados.
-- Un médico corresponde a un único empleado.
-- ============================================================================

CREATE TABLE Medicos (
    id_medico VARCHAR(10) PRIMARY KEY,
    empleado VARCHAR(10) NOT NULL UNIQUE,
    cedula_profesional VARCHAR(20) NOT NULL UNIQUE,
    cedula_vigencia DATE NOT NULL,
    especialidad VARCHAR(80),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_medicos_empleados
        FOREIGN KEY (empleado)
        REFERENCES Empleados(id_empleado)
);


-- ============================================================================
-- 3. PACIENTES
-- Información principal del paciente.
-- ============================================================================

CREATE TABLE Pacientes (
    id_paciente VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    correo VARCHAR(100),
    direccion VARCHAR(150),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro DATETIME NOT NULL
);


-- ============================================================================
-- 4. HISTORIALES CLINICOS
-- Cada paciente tiene un historial clínico principal.
-- ============================================================================

CREATE TABLE Historiales_Clinicos (
    id_historial VARCHAR(10) PRIMARY KEY,
    paciente VARCHAR(10) NOT NULL UNIQUE,
    antecedentes TEXT,
    observaciones TEXT,
    fecha_actualizacion DATETIME NOT NULL,
    CONSTRAINT fk_historiales_pacientes
        FOREIGN KEY (paciente)
        REFERENCES Pacientes(id_paciente)
);


-- ============================================================================
-- 5. CONDICIONES CLINICAS
--
-- Una condición puede ser:
-- - alergia
-- - contraindicacion
-- ============================================================================

CREATE TABLE Condiciones_Clinicas (
    id_condicion VARCHAR(10) PRIMARY KEY,
    tipo ENUM('alergia', 'contraindicacion') NOT NULL,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    activa BOOLEAN NOT NULL DEFAULT TRUE
);


-- ============================================================================
-- 6. HISTORIAL DE CONDICIONES
--
-- Relaciona el historial clínico con alergias o contraindicaciones.
-- ============================================================================

CREATE TABLE Historial_Condicion (
    historial VARCHAR(10) NOT NULL,
    condicion VARCHAR(10) NOT NULL,
    reaccion VARCHAR(150),
    severidad ENUM('leve', 'moderada', 'severa'),
    observaciones VARCHAR(255),
    fecha_registro DATE NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (historial, condicion),
    CONSTRAINT fk_historial_condicion_historial
        FOREIGN KEY (historial)
        REFERENCES Historiales_Clinicos(id_historial),
    CONSTRAINT fk_historial_condicion_condicion
        FOREIGN KEY (condicion)
        REFERENCES Condiciones_Clinicas(id_condicion)
);


-- ============================================================================
-- 7. DIAGNOSTICOS
-- Catálogo de diagnósticos.
--
-- Se crea antes de Consultas porque Consultas tiene una FK hacia esta tabla.
-- ============================================================================

CREATE TABLE Diagnosticos (
    id_diagnostico VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);


-- ============================================================================
-- 8. CONSULTAS
-- Cada consulta pertenece a un paciente y es atendida por un médico.
-- ============================================================================

CREATE TABLE Consultas (
    id_consulta VARCHAR(10) PRIMARY KEY,
    paciente VARCHAR(10) NOT NULL,
    medico VARCHAR(10) NOT NULL,
    diagnostico VARCHAR(10) NOT NULL,
    fecha DATETIME NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    costo_consulta DECIMAL(10,2) NOT NULL,
    tratamiento_indicado TEXT,
    observaciones TEXT,
    CONSTRAINT fk_consultas_pacientes
        FOREIGN KEY (paciente)
        REFERENCES Pacientes(id_paciente),
    CONSTRAINT fk_consultas_medicos
        FOREIGN KEY (medico)
        REFERENCES Medicos(id_medico),
    CONSTRAINT fk_consultas_diagnosticos
        FOREIGN KEY (diagnostico)
        REFERENCES Diagnosticos(id_diagnostico)
);


-- ============================================================================
-- 9. MEDICAMENTOS
-- Catálogo principal de medicamentos.
-- ============================================================================

CREATE TABLE Medicamentos (
    id_medicamento VARCHAR(10) PRIMARY KEY,
    categoria_medicamento ENUM(
        'analgesico',
        'antibiotico',
        'antiinflamatorio',
        'antihistaminico',
        'antiviral',
        'antifungico',
        'cardiovascular',
        'gastrointestinal',
        'respiratorio',
        'dermatologico',
        'vitamina_suplemento',
        'otro'
    ) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    principio_activo VARCHAR(120) NOT NULL,
    nombre_comercial VARCHAR(120),
    nombre_generico VARCHAR(120),
    presentacion VARCHAR(80) NOT NULL,
    concentracion VARCHAR(60) NOT NULL,
    dosis_referencia VARCHAR(60),
    duracion_maxima_dias INT,
    descripcion VARCHAR(255),
    requiere_receta BOOLEAN NOT NULL DEFAULT FALSE,
    registro_sanitario VARCHAR(60) UNIQUE,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_minimo INT NOT NULL DEFAULT 0,
    stock_maximo INT NOT NULL DEFAULT 0,
    punto_reorden INT NOT NULL DEFAULT 0,
    consumo_promedio_mensual DECIMAL(10,2) NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);


-- ============================================================================
-- 10. MEDICAMENTO - CONDICION
--
-- Relaciona medicamentos con alergias o contraindicaciones.
-- ============================================================================

CREATE TABLE Medicamento_Condicion (
    medicamento VARCHAR(10) NOT NULL,
    condicion VARCHAR(10) NOT NULL,
    nivel_riesgo ENUM('leve', 'moderada', 'severa') NOT NULL,
    observaciones VARCHAR(255),
    PRIMARY KEY (medicamento, condicion),
    CONSTRAINT fk_medicamento_condicion_medicamento
        FOREIGN KEY (medicamento)
        REFERENCES Medicamentos(id_medicamento),
    CONSTRAINT fk_medicamento_condicion_condicion
        FOREIGN KEY (condicion)
        REFERENCES Condiciones_Clinicas(id_condicion)
);


-- ============================================================================
-- 11. INTERACCIONES MEDICAMENTOSAS
--
-- Permite validar combinaciones de medicamentos que pueden generar riesgos.
-- ============================================================================

CREATE TABLE Interacciones_Medicamentosas (
    id_interaccion VARCHAR(10) PRIMARY KEY,
    medicamento_a VARCHAR(10) NOT NULL,
    medicamento_b VARCHAR(10) NOT NULL,
    nivel_riesgo ENUM('leve', 'moderada', 'severa') NOT NULL,
    efecto VARCHAR(255),
    recomendacion VARCHAR(255),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_interaccion_medicamentos
        UNIQUE (medicamento_a, medicamento_b),
    CONSTRAINT fk_interaccion_medicamento_a
        FOREIGN KEY (medicamento_a)
        REFERENCES Medicamentos(id_medicamento),
    CONSTRAINT fk_interaccion_medicamento_b
        FOREIGN KEY (medicamento_b)
        REFERENCES Medicamentos(id_medicamento)
);


-- ============================================================================
-- 12. RECETAS
-- Una consulta puede generar una receta.
-- ============================================================================

CREATE TABLE Recetas (
    id_receta VARCHAR(10) PRIMARY KEY,
    consulta VARCHAR(10) NOT NULL,
    folio VARCHAR(30) NOT NULL UNIQUE,
    fecha_emision DATETIME NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado ENUM(
        'emitida',
        'surtida_parcial',
        'surtida_total',
        'vencida',
        'cancelada'
    ) NOT NULL DEFAULT 'emitida',
    lugar_emision VARCHAR(120),
    diagnostico_texto TEXT,
    indicaciones TEXT,
    observaciones TEXT,
    CONSTRAINT fk_recetas_consultas
        FOREIGN KEY (consulta)
        REFERENCES Consultas(id_consulta)
);


-- ============================================================================
-- 13. DETALLES DE RECETA
--
-- Contiene los medicamentos prescritos en cada receta.
-- ============================================================================

CREATE TABLE Detalles_Receta (
    receta VARCHAR(10) NOT NULL,
    medicamento VARCHAR(10) NOT NULL,
    dosis VARCHAR(60) NOT NULL,
    frecuencia VARCHAR(60) NOT NULL,
    duracion VARCHAR(60) NOT NULL,
    cantidad_prescrita INT NOT NULL,
    via_administracion ENUM(
        'oral',
        'intravenosa',
        'intramuscular',
        'subcutanea',
        'topica',
        'oftalmica',
        'otica',
        'nasal',
        'rectal',
        'inhalada'
    ) NOT NULL,
    instrucciones_especificas VARCHAR(255),
    observaciones VARCHAR(255),
    PRIMARY KEY (receta, medicamento),
    CONSTRAINT fk_detalle_receta_receta
        FOREIGN KEY (receta)
        REFERENCES Recetas(id_receta),
    CONSTRAINT fk_detalle_receta_medicamento
        FOREIGN KEY (medicamento)
        REFERENCES Medicamentos(id_medicamento)
);


-- ============================================================================
-- 14. PROVEEDORES
-- Proveedores de medicamentos.
-- ============================================================================

CREATE TABLE Proveedores (
    id_proveedor VARCHAR(10) PRIMARY KEY,
    nombre_comercial VARCHAR(120) NOT NULL,
    telefono VARCHAR(15),
    correo VARCHAR(100),
    tiempo_entrega_dias INT,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);


-- ============================================================================
-- 15. ORDENES DE COMPRA
--
-- Utilizadas principalmente por el SP3.
-- Cada orden corresponde a un medicamento.
-- ============================================================================

CREATE TABLE Ordenes_Compra (
    id_orden_compra VARCHAR(10) PRIMARY KEY,
    proveedor VARCHAR(10) NOT NULL,
    medicamento VARCHAR(10) NOT NULL,
    empleado VARCHAR(10),
    cantidad_solicitada INT NOT NULL,
    costo_unitario DECIMAL(10,2),
    fecha_generacion DATETIME NOT NULL,
    fecha_estimada_entrega DATE,
    estado ENUM(
        'pendiente',
        'enviada',
        'recibida_parcial',
        'recibida_total',
        'cancelada'
    ) NOT NULL DEFAULT 'pendiente',
    generada_automatica BOOLEAN NOT NULL DEFAULT TRUE,
    observaciones VARCHAR(255),
    CONSTRAINT fk_orden_proveedor
        FOREIGN KEY (proveedor)
        REFERENCES Proveedores(id_proveedor),
    CONSTRAINT fk_orden_medicamento
        FOREIGN KEY (medicamento)
        REFERENCES Medicamentos(id_medicamento),
    CONSTRAINT fk_orden_empleado
        FOREIGN KEY (empleado)
        REFERENCES Empleados(id_empleado)
);


-- ============================================================================
-- 16. LOTES
--
-- Permite controlar diferentes lotes de un medicamento y sus caducidades.
-- ============================================================================

CREATE TABLE Lotes (
    id_lote VARCHAR(10) PRIMARY KEY,
    medicamento VARCHAR(10) NOT NULL,
    codigo_lote VARCHAR(40) NOT NULL,
    fecha_caducidad DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_lote_medicamento
        UNIQUE (medicamento, codigo_lote),
    CONSTRAINT fk_lotes_medicamento
        FOREIGN KEY (medicamento)
        REFERENCES Medicamentos(id_medicamento)
);


-- ============================================================================
-- 17. INVENTARIO
--
-- Control de existencia por lote.
-- Cada lote tiene un único registro de inventario.
-- ============================================================================

CREATE TABLE Inventario (
    id_inventario VARCHAR(10) PRIMARY KEY,
    lote VARCHAR(10) NOT NULL UNIQUE,
    proveedor VARCHAR(10),
    stock_actual INT NOT NULL DEFAULT 0,
    stock_reservado INT NOT NULL DEFAULT 0,
    stock_danado INT NOT NULL DEFAULT 0,
    stock_transito INT NOT NULL DEFAULT 0,
    fecha_ultima_reposicion DATE,
    cantidad_ultima_reposicion INT,
    ubicacion_fisica VARCHAR(60),
    costo_unitario DECIMAL(10,2),
    fecha_ultimo_conteo DATE,
    ultimo_movimiento ENUM(
        'surtido',
        'reposicion',
        'ajuste',
        'merma',
        'vencimiento'
    ),
    observaciones VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_inventario_lote
        FOREIGN KEY (lote)
        REFERENCES Lotes(id_lote),
    CONSTRAINT fk_inventario_proveedor
        FOREIGN KEY (proveedor)
        REFERENCES Proveedores(id_proveedor)
);


-- ============================================================================
-- 18. VENTAS
--
-- Registra el surtido de medicamentos en farmacia.
-- Una receta puede tener varias ventas por surtido parcial.
-- ============================================================================

CREATE TABLE Ventas (
    id_venta VARCHAR(10) PRIMARY KEY,
    empleado VARCHAR(10) NOT NULL,
    receta VARCHAR(10),
    fecha_venta DATETIME NOT NULL,
    tipo_pago ENUM(
        'efectivo',
        'tarjeta_debito',
        'tarjeta_credito',
        'transferencia'
    ) NOT NULL,
    descuento DECIMAL(10,2) NOT NULL DEFAULT 0,
    monto_total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_ventas_empleado
        FOREIGN KEY (empleado)
        REFERENCES Empleados(id_empleado),
    CONSTRAINT fk_ventas_receta
        FOREIGN KEY (receta)
        REFERENCES Recetas(id_receta)
);


-- ============================================================================
-- 19. DETALLES DE VENTA
--
-- Registra medicamento, lote, cantidad y precio utilizado en la venta.
-- ============================================================================

CREATE TABLE Detalles_Venta (
    venta VARCHAR(10) NOT NULL,
    medicamento VARCHAR(10) NOT NULL,
    lote VARCHAR(10) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (venta, medicamento, lote),
    CONSTRAINT fk_detalle_venta_venta
        FOREIGN KEY (venta)
        REFERENCES Ventas(id_venta),
    CONSTRAINT fk_detalle_venta_medicamento
        FOREIGN KEY (medicamento)
        REFERENCES Medicamentos(id_medicamento),
    CONSTRAINT fk_detalle_venta_lote
        FOREIGN KEY (lote)
        REFERENCES Lotes(id_lote)
);


-- ============================================================================
-- 20. AUDITORIA DE INVENTARIO
--
-- TABLA LOG.
-- Registra los cambios realizados al inventario.
-- Será alimentada principalmente por el Trigger 2.
-- ============================================================================

CREATE TABLE Auditoria_Inventario (
    id_auditoria VARCHAR(12) PRIMARY KEY,
    medicamento VARCHAR(10) NOT NULL,
    lote VARCHAR(10) NOT NULL,
    stock_anterior INT NOT NULL,
    stock_nuevo INT NOT NULL,
    tipo_movimiento ENUM(
        'surtido',
        'reposicion',
        'ajuste',
        'merma',
        'vencimiento'
    ) NOT NULL,
    fecha_movimiento DATETIME NOT NULL,
    empleado VARCHAR(10),
    receta VARCHAR(10),
    orden_compra VARCHAR(10),
    usuario_proceso VARCHAR(100),
    observaciones VARCHAR(255),
    CONSTRAINT fk_auditoria_medicamento
        FOREIGN KEY (medicamento)
        REFERENCES Medicamentos(id_medicamento),
    CONSTRAINT fk_auditoria_lote
        FOREIGN KEY (lote)
        REFERENCES Lotes(id_lote),
    CONSTRAINT fk_auditoria_empleado
        FOREIGN KEY (empleado)
        REFERENCES Empleados(id_empleado),
    CONSTRAINT fk_auditoria_receta
        FOREIGN KEY (receta)
        REFERENCES Recetas(id_receta),
    CONSTRAINT fk_auditoria_orden
        FOREIGN KEY (orden_compra)
        REFERENCES Ordenes_Compra(id_orden_compra)
);


-- ============================================================================
-- INSERTS
-- ============================================================================


-- ============================================================================
-- 1. EMPLEADOS
-- ============================================================================

INSERT INTO Empleados
(id_empleado, nombre, apellidos, puesto, telefono, correo, activo, fecha_ingreso)
VALUES
('EMP001', 'Laura', 'Martínez Gómez', 'Recepcionista', '4421001001', 'laura.martinez@farmaciaejemplo.com', TRUE, '2024-01-15'),
('EMP002', 'Carlos', 'Ramírez Torres', 'Farmacéutico', '4421001002', 'carlos.ramirez@farmaciaejemplo.com', TRUE, '2023-08-21'),
('EMP003', 'Mariana', 'López Hernández', 'Farmacéutica', '4421001003', 'mariana.lopez@farmaciaejemplo.com', TRUE, '2024-03-11'),
('EMP004', 'Jorge', 'Sánchez Ruiz', 'Administrador', '4421001004', 'jorge.sanchez@farmaciaejemplo.com', TRUE, '2022-06-06'),
('EMP005', 'Sofía', 'Castillo Méndez', 'Auxiliar de farmacia', '4421001005', 'sofia.castillo@farmaciaejemplo.com', TRUE, '2025-01-20'),
('EMP006', 'Miguel', 'Navarro Díaz', 'Auxiliar de farmacia', '4421001006', 'miguel.navarro@farmaciaejemplo.com', TRUE, '2025-05-12'),
('EMP007', 'Daniela', 'Ortega Flores', 'Recepcionista', '4421001007', 'daniela.ortega@farmaciaejemplo.com', TRUE, '2025-02-17'),
('EMP008', 'Ricardo', 'Vega Morales', 'Encargado de compras', '4421001008', 'ricardo.vega@farmaciaejemplo.com', TRUE, '2023-11-13'),
('EMP009', 'Alejandro', 'Moreno Silva', 'Médico', '4421001009', 'alejandro.moreno@farmaciaejemplo.com', TRUE, '2023-01-09'),
('EMP010', 'Patricia', 'Herrera Luna', 'Médico', '4421001010', 'patricia.herrera@farmaciaejemplo.com', TRUE, '2022-09-19'),
('EMP011', 'Fernando', 'Rojas Pérez', 'Médico', '4421001011', 'fernando.rojas@farmaciaejemplo.com', TRUE, '2024-02-05'),
('EMP012', 'Gabriela', 'Mendoza Cruz', 'Médico', '4421001012', 'gabriela.mendoza@farmaciaejemplo.com', TRUE, '2023-04-17'),
('EMP013', 'Andrés', 'Vargas León', 'Médico', '4421001013', 'andres.vargas@farmaciaejemplo.com', TRUE, '2024-07-22');


-- ============================================================================
-- 2. MEDICOS
-- ============================================================================

INSERT INTO Medicos
(id_medico, empleado, cedula_profesional, cedula_vigencia, especialidad, activo)
VALUES
('MED001', 'EMP009', 'CED-908721', '2028-12-31', 'Medicina familiar', TRUE),
('MED002', 'EMP010', 'CED-817634', '2029-06-30', 'Medicina interna', TRUE),
('MED003', 'EMP011', 'CED-735921', '2027-11-30', 'Pediatría', TRUE),
('MED004', 'EMP012', 'CED-624815', '2030-03-31', 'Dermatología', TRUE),
('MED005', 'EMP013', 'CED-519462', '2028-09-30', 'Medicina general', TRUE);


-- ============================================================================
-- 3. PACIENTES
-- ============================================================================

INSERT INTO Pacientes
(id_paciente, nombre, apellidos, fecha_nacimiento, telefono, correo, direccion, activo, fecha_registro)
VALUES
('PAC001', 'Ana', 'Torres Ramírez', '1998-04-15', '4422102001', 'ana.torres@email.com', 'Col. Centro, Querétaro, Qro.', TRUE, '2025-01-10 09:15:00'),
('PAC002', 'Luis', 'Hernández García', '1987-09-22', '4422102002', 'luis.hernandez@email.com', 'Col. Carretas, Querétaro, Qro.', TRUE, '2025-01-15 10:30:00'),
('PAC003', 'Sofía', 'Martínez López', '2012-06-08', '4422102003', 'sofia.martinez@email.com', 'Col. Juriquilla, Querétaro, Qro.', TRUE, '2025-02-03 11:20:00'),
('PAC004', 'Miguel', 'Sánchez Ortiz', '1979-11-30', '4422102004', 'miguel.sanchez@email.com', 'Col. Álamos, Querétaro, Qro.', TRUE, '2025-02-18 08:45:00'),
('PAC005', 'Valeria', 'Gómez Rivera', '1995-02-19', '4422102005', 'valeria.gomez@email.com', 'Col. Milenio III, Querétaro, Qro.', TRUE, '2025-03-07 12:10:00'),
('PAC006', 'Diego', 'Ramírez Flores', '2004-08-12', '4422102006', 'diego.ramirez@email.com', 'Col. El Refugio, Querétaro, Qro.', TRUE, '2025-03-21 16:00:00'),
('PAC007', 'Camila', 'Vega Morales', '1990-12-05', '4422102007', 'camila.vega@email.com', 'Col. Cimatario, Querétaro, Qro.', TRUE, '2025-04-02 09:50:00'),
('PAC008', 'Jorge', 'Castillo Díaz', '1968-03-27', '4422102008', 'jorge.castillo@email.com', 'Col. Satélite, Querétaro, Qro.', TRUE, '2025-04-14 13:30:00'),
('PAC009', 'Natalia', 'Ortega Ruiz', '2001-07-16', '4422102009', 'natalia.ortega@email.com', 'Col. La Pradera, Querétaro, Qro.', TRUE, '2025-05-06 10:15:00'),
('PAC010', 'Roberto', 'Mendoza Pérez', '1983-10-10', '4422102010', 'roberto.mendoza@email.com', 'Col. Vista Alegre, Querétaro, Qro.', TRUE, '2025-05-19 17:10:00');


-- ============================================================================
-- 4. HISTORIALES CLINICOS
-- ============================================================================

INSERT INTO Historiales_Clinicos
(id_historial, paciente, antecedentes, observaciones, fecha_actualizacion)
VALUES
('HIS001', 'PAC001', 'Rinitis estacional durante primavera.', 'Paciente con seguimiento periódico.', '2026-08-10 09:00:00'),
('HIS002', 'PAC002', 'Antecedente de gastritis.', 'Recomendada vigilancia de síntomas digestivos.', '2026-08-12 10:30:00'),
('HIS003', 'PAC003', 'Sin antecedentes relevantes registrados.', 'Paciente pediátrica.', '2026-08-15 11:00:00'),
('HIS004', 'PAC004', 'Hipertensión arterial diagnosticada en 2021.', 'Seguimiento de presión arterial.', '2026-08-18 08:30:00'),
('HIS005', 'PAC005', 'Migraña episódica.', 'Presenta episodios asociados a estrés.', '2026-08-20 12:00:00'),
('HIS006', 'PAC006', 'Sin antecedentes relevantes registrados.', 'Paciente joven.', '2026-08-22 15:30:00'),
('HIS007', 'PAC007', 'Rinitis alérgica.', 'Síntomas recurrentes durante cambios de clima.', '2026-08-24 09:20:00'),
('HIS008', 'PAC008', 'Diabetes mellitus tipo 2.', 'Control periódico de glucosa.', '2026-08-25 13:00:00'),
('HIS009', 'PAC009', 'Dermatitis atópica.', 'Brotes ocasionales.', '2026-08-27 10:00:00'),
('HIS010', 'PAC010', 'Antecedente de infección respiratoria recurrente.', 'Se recomienda seguimiento.', '2026-08-29 16:30:00');


-- ============================================================================
-- 5. CONDICIONES CLINICAS
-- ============================================================================

INSERT INTO Condiciones_Clinicas
(id_condicion, tipo, nombre, descripcion, activa)
VALUES
('CON001', 'alergia', 'Alergia a penicilina', 'Antecedente de reacción alérgica a medicamentos derivados de penicilina.', TRUE),
('CON002', 'alergia', 'Alergia a ibuprofeno', 'Antecedente de reacción adversa al ibuprofeno.', TRUE),
('CON003', 'alergia', 'Alergia a ácido acetilsalicílico', 'Antecedente de reacción al ácido acetilsalicílico.', TRUE),
('CON004', 'contraindicacion', 'Gastritis activa', 'Condición que requiere precaución con algunos antiinflamatorios.', TRUE),
('CON005', 'contraindicacion', 'Hipertensión no controlada', 'Condición que requiere precaución con ciertos medicamentos.', TRUE),
('CON006', 'contraindicacion', 'Diabetes mellitus', 'Condición que requiere vigilancia en tratamientos específicos.', TRUE),
('CON007', 'alergia', 'Alergia a sulfonamidas', 'Antecedente de reacción a medicamentos del grupo de sulfonamidas.', TRUE),
('CON008', 'contraindicacion', 'Insuficiencia renal', 'Condición registrada para vigilancia farmacológica.', TRUE);


-- ============================================================================
-- 6. HISTORIAL DE CONDICIONES
-- ============================================================================

INSERT INTO Historial_Condicion
(historial, condicion, reaccion, severidad, observaciones, fecha_registro, activa)
VALUES
('HIS001', 'CON001', 'Erupción cutánea', 'moderada', 'Evitar medicamentos relacionados con penicilinas.', '2025-01-10', TRUE),
('HIS002', 'CON004', 'Dolor y acidez', 'moderada', 'Vigilar tratamiento antiinflamatorio.', '2025-01-15', TRUE),
('HIS004', 'CON005', NULL, 'severa', 'Requiere control médico.', '2025-02-18', TRUE),
('HIS008', 'CON006', NULL, 'moderada', 'Mantener seguimiento de glucosa.', '2025-04-14', TRUE),
('HIS009', 'CON007', 'Erupción cutánea', 'moderada', 'Registrar como antecedente.', '2025-05-06', TRUE),
('HIS010', 'CON002', 'Inflamación y urticaria', 'severa', 'Evitar ibuprofeno.', '2025-05-19', TRUE);


-- ============================================================================
-- 7. DIAGNOSTICOS
-- ============================================================================

INSERT INTO Diagnosticos
(id_diagnostico, nombre, descripcion, activo)
VALUES
('DIA001', 'Infección respiratoria aguda', 'Infección de vías respiratorias de evolución reciente.', TRUE),
('DIA002', 'Gastritis', 'Inflamación de la mucosa gástrica.', TRUE),
('DIA003', 'Rinitis alérgica', 'Inflamación de la mucosa nasal asociada a alergias.', TRUE),
('DIA004', 'Hipertensión arterial', 'Presión arterial elevada que requiere seguimiento.', TRUE),
('DIA005', 'Migraña', 'Cefalea recurrente con características compatibles con migraña.', TRUE),
('DIA006', 'Dermatitis atópica', 'Inflamación cutánea recurrente.', TRUE),
('DIA007', 'Diabetes mellitus tipo 2', 'Alteración metabólica que requiere control médico.', TRUE),
('DIA008', 'Faringitis', 'Inflamación de la faringe.', TRUE),
('DIA009', 'Dolor muscular', 'Dolor localizado de origen musculoesquelético.', TRUE),
('DIA010', 'Resfriado común', 'Infección viral respiratoria leve.', TRUE);


-- ============================================================================
-- 8. CONSULTAS
-- ============================================================================

INSERT INTO Consultas
(id_consulta, paciente, medico, diagnostico, fecha, motivo, costo_consulta, tratamiento_indicado, observaciones)
VALUES
('CON001', 'PAC001', 'MED001', 'DIA003', '2026-08-10 09:30:00', 'Congestión nasal y estornudos frecuentes.', 450.00, 'Tratamiento sintomático y control de alergias.', 'Se recomienda evitar exposición a polvo.'),
('CON002', 'PAC002', 'MED002', 'DIA002', '2026-08-12 11:00:00', 'Dolor abdominal y acidez.', 500.00, 'Medidas dietéticas y tratamiento para síntomas gástricos.', 'Evitar alimentos irritantes.'),
('CON003', 'PAC003', 'MED003', 'DIA008', '2026-08-15 11:30:00', 'Dolor de garganta y malestar general.', 400.00, 'Tratamiento sintomático.', 'Vigilar evolución.'),
('CON004', 'PAC004', 'MED002', 'DIA004', '2026-08-18 09:00:00', 'Seguimiento de presión arterial.', 500.00, 'Continuar tratamiento indicado y monitoreo.', 'Presión controlada durante la consulta.'),
('CON005', 'PAC005', 'MED001', 'DIA005', '2026-08-20 12:30:00', 'Dolor de cabeza recurrente.', 450.00, 'Tratamiento sintomático y recomendaciones de descanso.', 'Registrar frecuencia de episodios.'),
('CON006', 'PAC006', 'MED005', 'DIA009', '2026-08-22 16:00:00', 'Dolor muscular posterior a actividad física.', 400.00, 'Reposo relativo y tratamiento sintomático.', 'Sin signos de lesión grave.'),
('CON007', 'PAC007', 'MED001', 'DIA003', '2026-08-24 09:45:00', 'Congestión nasal por cambio de clima.', 450.00, 'Tratamiento para síntomas alérgicos.', 'Seguimiento si persisten síntomas.'),
('CON008', 'PAC008', 'MED002', 'DIA007', '2026-08-25 13:30:00', 'Control de glucosa y seguimiento.', 500.00, 'Continuar control médico y tratamiento establecido.', 'Reforzar seguimiento nutricional.'),
('CON009', 'PAC009', 'MED004', 'DIA006', '2026-08-27 10:30:00', 'Brotes de irritación y resequedad en piel.', 550.00, 'Tratamiento tópico y cuidados de la piel.', 'Evitar productos irritantes.'),
('CON010', 'PAC010', 'MED005', 'DIA010', '2026-08-29 17:00:00', 'Congestión, tos y malestar general.', 400.00, 'Tratamiento sintomático.', 'Reposo y adecuada hidratación.'),
('CON011', 'PAC001', 'MED001', 'DIA003', '2026-09-05 10:00:00', 'Seguimiento de rinitis alérgica.', 450.00, 'Continuar tratamiento sintomático.', 'Mejoría reportada.'),
('CON012', 'PAC004', 'MED002', 'DIA004', '2026-09-08 09:30:00', 'Revisión de presión arterial.', 500.00, 'Continuar seguimiento.', 'Sin cambios importantes.');


-- ============================================================================
-- 9. MEDICAMENTOS
-- ============================================================================

INSERT INTO Medicamentos
(id_medicamento, categoria_medicamento, nombre, principio_activo,
nombre_comercial, nombre_generico, presentacion, concentracion,
dosis_referencia, duracion_maxima_dias, descripcion, requiere_receta,
registro_sanitario, precio_venta, stock_minimo, stock_maximo,
punto_reorden, consumo_promedio_mensual, activo)
VALUES
('MED001', 'analgesico', 'Paracetamol 500 mg', 'Paracetamol',
'Tempra', 'Paracetamol', 'Caja con 20 tabletas', '500 mg',
'500 mg cada 6-8 horas', 7, 'Analgésico y antipirético.',
FALSE, 'RS-PA-001', 68.50, 20, 100, 30, 35.00, TRUE),
('MED002', 'antihistaminico', 'Loratadina 10 mg', 'Loratadina',
'Clarityne', 'Loratadina', 'Caja con 10 tabletas', '10 mg',
'10 mg cada 24 horas', 15, 'Antihistamínico para síntomas alérgicos.',
FALSE, 'RS-LO-002', 92.00, 15, 80, 25, 22.00, TRUE),
('MED003', 'antiinflamatorio', 'Ibuprofeno 400 mg', 'Ibuprofeno',
'Advil', 'Ibuprofeno', 'Caja con 20 tabletas', '400 mg',
'400 mg cada 8 horas', 5, 'Antiinflamatorio y analgésico.',
FALSE, 'RS-IB-003', 85.00, 20, 100, 30, 30.00, TRUE),
('MED004', 'antibiotico', 'Amoxicilina 500 mg', 'Amoxicilina',
'Amoxil', 'Amoxicilina', 'Caja con 12 cápsulas', '500 mg',
'500 mg cada 8 horas', 10, 'Antibiótico de uso bajo prescripción.',
TRUE, 'RS-AM-004', 145.00, 25, 120, 35, 40.00, TRUE),
('MED005', 'gastrointestinal', 'Omeprazol 20 mg', 'Omeprazol',
'Losec', 'Omeprazol', 'Caja con 14 cápsulas', '20 mg',
'20 mg cada 24 horas', 30, 'Medicamento para control de acidez y síntomas gástricos.',
FALSE, 'RS-OM-005', 110.00, 15, 80, 25, 25.00, TRUE),
('MED006', 'antihistaminico', 'Cetirizina 10 mg', 'Cetirizina',
'Zyrtec', 'Cetirizina', 'Caja con 10 tabletas', '10 mg',
'10 mg cada 24 horas', 15, 'Antihistamínico para síntomas alérgicos.',
FALSE, 'RS-CE-006', 98.00, 10, 70, 20, 18.00, TRUE),
('MED007', 'dermatologico', 'Hidrocortisona crema 1%', 'Hidrocortisona',
'Cortaid', 'Hidrocortisona', 'Tubo de 20 g', '1%',
'Aplicar cada 12 horas', 14, 'Crema tópica antiinflamatoria.',
TRUE, 'RS-HI-007', 76.00, 10, 60, 20, 12.00, TRUE),
('MED008', 'cardiovascular', 'Losartán 50 mg', 'Losartán',
'Cozaar', 'Losartán', 'Caja con 30 tabletas', '50 mg',
'50 mg cada 24 horas', 30, 'Medicamento para control de presión arterial.',
TRUE, 'RS-LO-008', 135.00, 20, 100, 30, 28.00, TRUE),
('MED009', 'analgesico', 'Naproxeno 250 mg', 'Naproxeno',
'Flanax', 'Naproxeno', 'Caja con 20 tabletas', '250 mg',
'250 mg cada 12 horas', 7, 'Analgésico y antiinflamatorio.',
TRUE, 'RS-NA-009', 105.00, 10, 60, 20, 14.00, TRUE),
('MED010', 'respiratorio', 'Ambroxol 30 mg', 'Ambroxol',
'Mucosolvan', 'Ambroxol', 'Caja con 20 tabletas', '30 mg',
'30 mg cada 8 horas', 10, 'Expectorante para afecciones respiratorias.',
FALSE, 'RS-AB-010', 88.00, 10, 70, 20, 16.00, TRUE);


-- ============================================================================
-- 10. MEDICAMENTO - CONDICION
-- ============================================================================

INSERT INTO Medicamento_Condicion
(medicamento, condicion, nivel_riesgo, observaciones)
VALUES
('MED004', 'CON001', 'severa', 'No utilizar en pacientes con antecedente de alergia a penicilinas.'),
('MED003', 'CON002', 'severa', 'Evitar en pacientes con antecedente de alergia al ibuprofeno.'),
('MED003', 'CON004', 'moderada', 'Utilizar con precaución en pacientes con gastritis.'),
('MED009', 'CON004', 'moderada', 'Puede aumentar la irritación gástrica.'),
('MED003', 'CON003', 'moderada', 'Precaución por antecedentes de reacción a salicilatos.'),
('MED008', 'CON005', 'moderada', 'Requiere seguimiento médico de presión arterial.'),
('MED009', 'CON002', 'moderada', 'Precaución por antecedente de reacción a antiinflamatorios.'),
('MED004', 'CON007', 'moderada', 'Registrar antecedente de alergia antes de prescribir.');


-- ============================================================================
-- 11. INTERACCIONES MEDICAMENTOSAS
-- ============================================================================

INSERT INTO Interacciones_Medicamentosas
(id_interaccion, medicamento_a, medicamento_b, nivel_riesgo,
efecto, recomendacion, activa)
VALUES
('INT001', 'MED003', 'MED009', 'moderada',
'Puede aumentar el riesgo de irritación gastrointestinal.',
'Evitar combinar ambos antiinflamatorios salvo indicación médica.', TRUE),
('INT002', 'MED008', 'MED009', 'moderada',
'Puede afectar el control de presión arterial y función renal.',
'Vigilar al paciente y utilizar solo bajo indicación médica.', TRUE),
('INT003', 'MED004', 'MED009', 'leve',
'Puede aumentar molestias gastrointestinales.',
'Evaluar tolerancia y antecedentes del paciente.', TRUE),
('INT004', 'MED002', 'MED006', 'leve',
'Puede aumentar efectos antihistamínicos.',
'Evitar duplicar tratamiento antihistamínico.', TRUE);


-- ============================================================================
-- 12. RECETAS
-- ============================================================================

INSERT INTO Recetas
(id_receta, consulta, folio, fecha_emision, fecha_vencimiento, estado,
lugar_emision, diagnostico_texto, indicaciones, observaciones)
VALUES
('REC001', 'CON001', 'FOL-2026-0001', '2026-08-10 09:45:00', '2026-08-24',
'surtida_total', 'Consultorio Farmacia Centro', 'Rinitis alérgica',
'Tomar según indicaciones y evitar exposición a alérgenos.',
'Paciente con buena respuesta al tratamiento.'),
('REC002', 'CON002', 'FOL-2026-0002', '2026-08-12 11:15:00', '2026-08-26',
'surtida_total', 'Consultorio Farmacia Centro', 'Gastritis',
'Tomar antes de los alimentos.', 'Seguimiento de síntomas.'),
('REC003', 'CON003', 'FOL-2026-0003', '2026-08-15 11:45:00', '2026-08-29',
'surtida_total', 'Consultorio Farmacia Centro', 'Faringitis',
'Mantener hidratación y seguir indicaciones.', 'Control si persiste el dolor.'),
('REC004', 'CON004', 'FOL-2026-0004', '2026-08-18 09:15:00', '2026-09-01',
'surtida_total', 'Consultorio Farmacia Centro', 'Hipertensión arterial',
'Tomar diariamente a la misma hora.', 'Continuar monitoreo de presión.'),
('REC005', 'CON005', 'FOL-2026-0005', '2026-08-20 12:45:00', '2026-09-03',
'surtida_total', 'Consultorio Farmacia Centro', 'Migraña',
'Tomar al inicio de los síntomas.', 'Llevar registro de episodios.'),
('REC006', 'CON006', 'FOL-2026-0006', '2026-08-22 16:15:00', '2026-09-05',
'surtida_parcial', 'Consultorio Farmacia Centro', 'Dolor muscular',
'Reposo relativo y tomar según indicaciones.',
'Una parte de la receta quedó pendiente de surtido.'),
('REC007', 'CON007', 'FOL-2026-0007', '2026-08-24 10:00:00', '2026-09-07',
'surtida_total', 'Consultorio Farmacia Centro', 'Rinitis alérgica',
'Tomar según indicaciones.', 'Seguimiento si continúan síntomas.'),
('REC008', 'CON008', 'FOL-2026-0008', '2026-08-25 13:45:00', '2026-09-08',
'surtida_total', 'Consultorio Farmacia Centro', 'Diabetes mellitus tipo 2',
'Continuar tratamiento indicado.', 'Control periódico.'),
('REC009', 'CON009', 'FOL-2026-0009', '2026-08-27 10:45:00', '2026-09-10',
'surtida_total', 'Consultorio Farmacia Centro', 'Dermatitis atópica',
'Aplicar en zona afectada según indicaciones.', 'Evitar productos irritantes.'),
('REC010', 'CON010', 'FOL-2026-0010', '2026-08-29 17:15:00', '2026-09-12',
'surtida_total', 'Consultorio Farmacia Centro', 'Resfriado común',
'Seguir tratamiento sintomático.', 'Reposo e hidratación.'),
('REC011', 'CON011', 'FOL-2026-0011', '2026-09-05 10:15:00', '2026-09-19',
'emitida', 'Consultorio Farmacia Centro', 'Rinitis alérgica',
'Seguir indicaciones médicas.', 'Receta disponible para surtido.'),
('REC012', 'CON012', 'FOL-2026-0012', '2026-09-08 09:45:00', '2026-09-22',
'emitida', 'Consultorio Farmacia Centro', 'Hipertensión arterial',
'Continuar tratamiento indicado.', 'Pendiente de surtido.');


-- ============================================================================
-- 13. DETALLES DE RECETA
-- ============================================================================

INSERT INTO Detalles_Receta
(receta, medicamento, dosis, frecuencia, duracion, cantidad_prescrita,
via_administracion, instrucciones_especificas, observaciones)
VALUES
('REC001', 'MED002', '10 mg', 'Cada 24 horas', '10 días', 10,
'oral', 'Tomar por la mañana.', NULL),
('REC002', 'MED005', '20 mg', 'Cada 24 horas', '14 días', 14,
'oral', 'Tomar antes del desayuno.', NULL),
('REC003', 'MED001', '500 mg', 'Cada 8 horas', '5 días', 15,
'oral', 'Tomar con agua.', NULL),
('REC003', 'MED010', '30 mg', 'Cada 8 horas', '5 días', 15,
'oral', 'Tomar después de los alimentos.', NULL),
('REC004', 'MED008', '50 mg', 'Cada 24 horas', '30 días', 30,
'oral', 'Tomar a la misma hora diariamente.', NULL),
('REC005', 'MED001', '500 mg', 'Cada 8 horas', '3 días', 9,
'oral', 'Tomar al inicio del dolor.', NULL),
('REC006', 'MED001', '500 mg', 'Cada 8 horas', '5 días', 15,
'oral', 'Tomar con agua.', 'Pendiente de surtido parcial.'),
('REC006', 'MED009', '250 mg', 'Cada 12 horas', '5 días', 10,
'oral', 'Tomar después de los alimentos.', NULL),
('REC007', 'MED006', '10 mg', 'Cada 24 horas', '10 días', 10,
'oral', 'Tomar por la noche.', NULL),
('REC008', 'MED008', '50 mg', 'Cada 24 horas', '30 días', 30,
'oral', 'Continuar tratamiento indicado.', NULL),
('REC009', 'MED007', '1%', 'Cada 12 horas', '7 días', 1,
'topica', 'Aplicar una capa fina.', NULL),
('REC010', 'MED010', '30 mg', 'Cada 8 horas', '5 días', 15,
'oral', 'Tomar después de los alimentos.', NULL),
('REC011', 'MED002', '10 mg', 'Cada 24 horas', '10 días', 10,
'oral', 'Tomar por la mañana.', NULL),
('REC012', 'MED008', '50 mg', 'Cada 24 horas', '30 días', 30,
'oral', 'Tomar a la misma hora diariamente.', NULL);


-- ============================================================================
-- 14. PROVEEDORES
-- ============================================================================

INSERT INTO Proveedores
(id_proveedor, nombre_comercial, telefono, correo, tiempo_entrega_dias, activo)
VALUES
('PRO001', 'Distribuidora Farmacéutica del Centro', '4423003001', 'ventas@dfcentro.com', 3, TRUE),
('PRO002', 'Medicamentos Nacionales S.A.', '4423003002', 'pedidos@mednacionales.com', 5, TRUE),
('PRO003', 'Farmadistribuciones Querétaro', '4423003003', 'ventas@farmadistribucionesqro.com', 2, TRUE),
('PRO004', 'Grupo Salud y Farma', '4423003004', 'pedidos@saludyfarma.com', 4, TRUE),
('PRO005', 'Suministros Médicos del Bajío', '4423003005', 'ventas@sumbajio.com', 6, TRUE);


-- ============================================================================
-- 15. ORDENES DE COMPRA
-- ============================================================================

INSERT INTO Ordenes_Compra
(id_orden_compra, proveedor, medicamento, empleado, cantidad_solicitada,
costo_unitario, fecha_generacion, fecha_estimada_entrega, estado,
generada_automatica, observaciones)
VALUES
('ORD001', 'PRO001', 'MED001', 'EMP008', 50, 42.00,
'2026-08-01 09:00:00', '2026-08-04', 'recibida_total', TRUE,
'Reposición por consumo mensual.'),
('ORD002', 'PRO003', 'MED002', 'EMP008', 40, 58.00,
'2026-08-03 10:00:00', '2026-08-05', 'recibida_total', TRUE,
'Reposición preventiva.'),
('ORD003', 'PRO002', 'MED004', 'EMP008', 60, 95.00,
'2026-08-05 11:30:00', '2026-08-10', 'recibida_total', TRUE,
'Reposición de antibiótico.'),
('ORD004', 'PRO004', 'MED008', 'EMP008', 50, 88.00,
'2026-08-07 09:30:00', '2026-08-11', 'recibida_total', TRUE,
'Reposición por nivel de inventario.'),
('ORD005', 'PRO005', 'MED010', 'EMP008', 35, 55.00,
'2026-08-09 14:00:00', '2026-08-15', 'recibida_total', TRUE,
'Reposición de medicamento respiratorio.'),
('ORD006', 'PRO001', 'MED003', 'EMP008', 40, 54.00,
'2026-08-15 10:00:00', '2026-08-18', 'pendiente', TRUE,
'Solicitud de reposición pendiente.'),
('ORD007', 'PRO003', 'MED009', 'EMP008', 30, 68.00,
'2026-08-20 12:00:00', '2026-08-22', 'enviada', TRUE,
'Pedido en tránsito.');


-- ============================================================================
-- 16. LOTES
-- ============================================================================

INSERT INTO Lotes
(id_lote, medicamento, codigo_lote, fecha_caducidad, activo)
VALUES
('LOT001', 'MED001', 'PAR-2601-A', '2027-01-31', TRUE),
('LOT002', 'MED001', 'PAR-2604-B', '2027-04-30', TRUE),
('LOT003', 'MED002', 'LOR-2602-A', '2027-02-28', TRUE),
('LOT004', 'MED002', 'LOR-2605-B', '2027-05-31', TRUE),
('LOT005', 'MED003', 'IBU-2603-A', '2027-03-31', TRUE),
('LOT006', 'MED004', 'AMO-2601-A', '2027-01-31', TRUE),
('LOT007', 'MED005', 'OME-2604-A', '2027-04-30', TRUE),
('LOT008', 'MED006', 'CET-2605-A', '2027-05-31', TRUE),
('LOT009', 'MED007', 'HID-2602-A', '2027-02-28', TRUE),
('LOT010', 'MED008', 'LOS-2601-A', '2027-01-31', TRUE),
('LOT011', 'MED008', 'LOS-2605-B', '2027-05-31', TRUE),
('LOT012', 'MED009', 'NAP-2603-A', '2027-03-31', TRUE),
('LOT013', 'MED010', 'AMB-2604-A', '2027-04-30', TRUE);


-- ============================================================================
-- 17. INVENTARIO
-- ============================================================================

INSERT INTO Inventario
(id_inventario, lote, proveedor, stock_actual, stock_reservado,
stock_danado, stock_transito, fecha_ultima_reposicion,
cantidad_ultima_reposicion, ubicacion_fisica, costo_unitario,
fecha_ultimo_conteo, ultimo_movimiento, observaciones, activo)
VALUES
('INV001', 'LOT001', 'PRO001', 38, 0, 0, 0, '2026-08-04', 50,
'Estante A-01', 42.00, '2026-09-10', 'reposicion',
'Lote principal de paracetamol.', TRUE),
('INV002', 'LOT002', 'PRO001', 24, 0, 0, 0, '2026-08-20', 30,
'Estante A-01', 43.00, '2026-09-10', 'surtido',
'Lote más reciente.', TRUE),
('INV003', 'LOT003', 'PRO003', 12, 0, 0, 0, '2026-08-05', 40,
'Estante A-02', 58.00, '2026-09-10', 'surtido',
'Stock bajo para pruebas de reposición.', TRUE),
('INV004', 'LOT004', 'PRO003', 28, 0, 0, 0, '2026-08-18', 30,
'Estante A-02', 59.00, '2026-09-10', 'reposicion',
'Lote reciente.', TRUE),
('INV005', 'LOT005', 'PRO002', 8, 0, 0, 5, '2026-08-18', 40,
'Estante A-03', 54.00, '2026-09-10', 'surtido',
'Stock bajo y pedido pendiente.', TRUE),
('INV006', 'LOT006', 'PRO002', 18, 0, 0, 0, '2026-08-10', 60,
'Estante A-04', 95.00, '2026-09-10', 'surtido',
'Antibiótico bajo prescripción.', TRUE),
('INV007', 'LOT007', 'PRO004', 16, 0, 0, 0, '2026-08-12', 35,
'Estante A-05', 65.00, '2026-09-10', 'surtido',
'Existencia disponible.', TRUE),
('INV008', 'LOT008', 'PRO003', 22, 0, 0, 0, '2026-08-15', 30,
'Estante A-06', 60.00, '2026-09-10', 'reposicion',
'Existencia suficiente.', TRUE),
('INV009', 'LOT009', 'PRO004', 9, 0, 0, 0, '2026-08-16', 20,
'Estante B-01', 45.00, '2026-09-10', 'surtido',
'Stock cercano al mínimo.', TRUE),
('INV010', 'LOT010', 'PRO004', 14, 0, 0, 0, '2026-08-11', 50,
'Estante B-02', 88.00, '2026-09-10', 'surtido',
'Existencia baja.', TRUE),
('INV011', 'LOT011', 'PRO004', 31, 0, 0, 0, '2026-08-25', 40,
'Estante B-02', 90.00, '2026-09-10', 'reposicion',
'Lote reciente.', TRUE),
('INV012', 'LOT012', 'PRO001', 7, 0, 0, 0, '2026-08-22', 30,
'Estante B-03', 68.00, '2026-09-10', 'surtido',
'Stock bajo para pruebas.', TRUE),
('INV013', 'LOT013', 'PRO005', 25, 0, 0, 0, '2026-08-15', 35,
'Estante B-04', 55.00, '2026-09-10', 'reposicion',
'Existencia suficiente.', TRUE);


-- ============================================================================
-- 18. VENTAS
-- ============================================================================

INSERT INTO Ventas
(id_venta, empleado, receta, fecha_venta, tipo_pago, descuento, monto_total)
VALUES
('VEN001', 'EMP002', 'REC001', '2026-08-10 10:00:00', 'tarjeta_debito', 0.00, 920.00),
('VEN002', 'EMP003', 'REC002', '2026-08-12 11:30:00', 'efectivo', 5.00, 105.00),
('VEN003', 'EMP005', 'REC003', '2026-08-15 12:00:00', 'tarjeta_credito', 0.00, 2347.50),
('VEN004', 'EMP002', 'REC004', '2026-08-18 09:30:00', 'transferencia', 10.00, 125.00),
('VEN005', 'EMP003', 'REC005', '2026-08-20 13:00:00', 'efectivo', 0.00, 68.50),
('VEN006', 'EMP005', 'REC006', '2026-08-22 16:30:00', 'tarjeta_debito', 0.00, 68.50),
('VEN007', 'EMP006', 'REC007', '2026-08-24 10:15:00', 'tarjeta_debito', 0.00, 980.00),
('VEN008', 'EMP002', 'REC008', '2026-08-25 14:00:00', 'transferencia', 5.00, 130.00),
('VEN009', 'EMP003', 'REC009', '2026-08-27 11:00:00', 'efectivo', 0.00, 76.00),
('VEN010', 'EMP006', 'REC010', '2026-08-29 17:30:00', 'tarjeta_credito', 0.00, 1320.00);


-- ============================================================================
-- 19. DETALLES DE VENTA
-- ============================================================================

INSERT INTO Detalles_Venta
(venta, medicamento, lote, cantidad, precio_unitario, subtotal)
VALUES
('VEN001', 'MED002', 'LOT003', 10, 92.00, 920.00),
('VEN002', 'MED005', 'LOT007', 1, 110.00, 110.00),
('VEN003', 'MED001', 'LOT001', 15, 68.50, 1027.50),
('VEN003', 'MED010', 'LOT013', 15, 88.00, 1320.00),
('VEN004', 'MED008', 'LOT010', 1, 135.00, 135.00),
('VEN005', 'MED001', 'LOT001', 1, 68.50, 68.50),
('VEN006', 'MED001', 'LOT002', 1, 68.50, 68.50),
('VEN007', 'MED006', 'LOT008', 10, 98.00, 980.00),
('VEN008', 'MED008', 'LOT011', 1, 135.00, 135.00),
('VEN009', 'MED007', 'LOT009', 1, 76.00, 76.00),
('VEN010', 'MED010', 'LOT013', 15, 88.00, 1320.00);


-- ============================================================================
-- 20. AUDITORIA DE INVENTARIO
-- ============================================================================

INSERT INTO Auditoria_Inventario
(id_auditoria, medicamento, lote, stock_anterior, stock_nuevo,
tipo_movimiento, fecha_movimiento, empleado, receta, orden_compra,
usuario_proceso, observaciones)
VALUES
('AUD001', 'MED001', 'LOT001', 0, 50, 'reposicion',
'2026-08-04 10:00:00', 'EMP008', NULL, 'ORD001',
'sistema', 'Recepción inicial de lote.'),
('AUD002', 'MED002', 'LOT003', 0, 40, 'reposicion',
'2026-08-05 11:00:00', 'EMP008', NULL, 'ORD002',
'sistema', 'Recepción inicial de lote.'),
('AUD003', 'MED004', 'LOT006', 0, 60, 'reposicion',
'2026-08-10 12:00:00', 'EMP008', NULL, 'ORD003',
'sistema', 'Recepción de antibiótico.'),
('AUD004', 'MED008', 'LOT010', 0, 50, 'reposicion',
'2026-08-11 10:00:00', 'EMP008', NULL, 'ORD004',
'sistema', 'Recepción de lote.'),
('AUD005', 'MED010', 'LOT013', 0, 35, 'reposicion',
'2026-08-15 15:00:00', 'EMP008', NULL, 'ORD005',
'sistema', 'Recepción de lote.'),
('AUD006', 'MED001', 'LOT001', 50, 35, 'surtido',
'2026-08-15 12:00:00', 'EMP005', 'REC003', NULL,
'sistema', 'Surtido de receta.'),
('AUD007', 'MED008', 'LOT010', 50, 49, 'surtido',
'2026-08-18 09:30:00', 'EMP002', 'REC004', NULL,
'sistema', 'Surtido de receta.'),
('AUD008', 'MED001', 'LOT001', 35, 34, 'surtido',
'2026-08-20 13:00:00', 'EMP003', 'REC005', NULL,
'sistema', 'Surtido de receta.'),
('AUD009', 'MED006', 'LOT008', 30, 20, 'surtido',
'2026-08-24 10:15:00', 'EMP006', 'REC007', NULL,
'sistema', 'Surtido de receta.'),
('AUD010', 'MED010', 'LOT013', 35, 20, 'surtido',
'2026-08-29 17:30:00', 'EMP006', 'REC010', NULL,
'sistema', 'Surtido de receta.');


-- ============================================================================
-- COMPROBACIÓN DE REGISTROS
-- ============================================================================

SELECT 'Empleados' AS tabla, COUNT(*) AS registros FROM Empleados
UNION ALL
SELECT 'Medicos', COUNT(*) FROM Medicos
UNION ALL
SELECT 'Pacientes', COUNT(*) FROM Pacientes
UNION ALL
SELECT 'Historiales_Clinicos', COUNT(*) FROM Historiales_Clinicos
UNION ALL
SELECT 'Condiciones_Clinicas', COUNT(*) FROM Condiciones_Clinicas
UNION ALL
SELECT 'Historial_Condicion', COUNT(*) FROM Historial_Condicion
UNION ALL
SELECT 'Consultas', COUNT(*) FROM Consultas
UNION ALL
SELECT 'Diagnosticos', COUNT(*) FROM Diagnosticos
UNION ALL
SELECT 'Medicamentos', COUNT(*) FROM Medicamentos
UNION ALL
SELECT 'Medicamento_Condicion', COUNT(*) FROM Medicamento_Condicion
UNION ALL
SELECT 'Interacciones_Medicamentosas', COUNT(*) FROM Interacciones_Medicamentosas
UNION ALL
SELECT 'Recetas', COUNT(*) FROM Recetas
UNION ALL
SELECT 'Detalles_Receta', COUNT(*) FROM Detalles_Receta
UNION ALL
SELECT 'Proveedores', COUNT(*) FROM Proveedores
UNION ALL
SELECT 'Ordenes_Compra', COUNT(*) FROM Ordenes_Compra
UNION ALL
SELECT 'Lotes', COUNT(*) FROM Lotes
UNION ALL
SELECT 'Inventario', COUNT(*) FROM Inventario
UNION ALL
SELECT 'Ventas', COUNT(*) FROM Ventas
UNION ALL
SELECT 'Detalles_Venta', COUNT(*) FROM Detalles_Venta
UNION ALL
SELECT 'Auditoria_Inventario', COUNT(*) FROM Auditoria_Inventario;


-- ============================================================================
-- MOSTRAR LAS TABLAS CREADAS
-- ============================================================================

USE proyecto_final_data_base;

/*
====================================================================
ANA - VISTA 1
HISTORIAL CLINICO COMPLETO DEL PACIENTE
====================================================================

En esta vista se presenta de manera consolidada la información
clínica del paciente.

Se integran:
- Datos del paciente.
- Edad.
- Consultas.
- Diagnósticos.
- Tratamientos.
- Médico responsable.
- Recetas.
- Medicamentos prescritos.
- Dosis, frecuencia y duración.
- Alergias.
- Contraindicaciones.

La finalidad es consultar el historial clínico completo desde una
sola vista sin tener que consultar individualmente todas las tablas
relacionadas.
====================================================================
*/

DROP VIEW IF EXISTS vista_historial_clinico_completo;

CREATE VIEW vista_historial_clinico_completo AS

SELECT
    p.id_paciente,
    CONCAT(p.nombre, ' ', p.apellidos) AS paciente,
    TIMESTAMPDIFF(
        YEAR,
        p.fecha_nacimiento,
        CURDATE()
    ) AS edad,

    p.telefono,
    p.correo,

    c.id_consulta,
    c.fecha AS fecha_consulta,
    c.motivo AS motivo_consulta,

    d.nombre AS diagnostico,
    c.tratamiento_indicado AS tratamiento,

    r.id_receta,
    r.folio,
    r.fecha_emision,
    r.fecha_vencimiento,
    r.estado AS estado_receta,

    m.nombre AS medicamento,
    m.principio_activo,
    m.presentacion,
    m.concentracion,

    dr.dosis,
    dr.frecuencia,
    dr.duracion,
    dr.cantidad_prescrita,
    dr.via_administracion,

    hc.alergias,
    hc.contraindicaciones,

    CONCAT(e.nombre, ' ', e.apellidos) AS medico_responsable

FROM Pacientes p

LEFT JOIN Consultas c
    ON c.paciente = p.id_paciente

LEFT JOIN Diagnosticos d
    ON d.id_diagnostico = c.diagnostico

LEFT JOIN Medicos me
    ON me.id_medico = c.medico

LEFT JOIN Empleados e
    ON e.id_empleado = me.empleado

LEFT JOIN Recetas r
    ON r.consulta = c.id_consulta

LEFT JOIN Detalles_Receta dr
    ON dr.receta = r.id_receta

LEFT JOIN Medicamentos m
    ON m.id_medicamento = dr.medicamento

LEFT JOIN
(
    SELECT
        hc1.id_historial,

        GROUP_CONCAT(
            DISTINCT
            CASE
                WHEN cc.tipo = 'alergia'
                THEN cc.nombre
            END
            SEPARATOR ', '
        ) AS alergias,

        GROUP_CONCAT(
            DISTINCT
            CASE
                WHEN cc.tipo = 'contraindicacion'
                THEN cc.nombre
            END
            SEPARATOR ', '
        ) AS contraindicaciones

    FROM Historiales_Clinicos hc1

    LEFT JOIN Historial_Condicion hco
        ON hco.historial = hc1.id_historial

    LEFT JOIN Condiciones_Clinicas cc
        ON cc.id_condicion = hco.condicion

    GROUP BY hc1.id_historial

) hc
    ON hc.id_historial = CONCAT('HIS',
        LPAD(
            SUBSTRING(p.id_paciente, 4),
            3,
            '0'
        )
    )

ORDER BY
    p.id_paciente,
    c.fecha,
    r.id_receta,
    m.nombre;

-- // PROBANDO LA VISTA 1 (LISTO)

SELECT *
FROM vista_historial_clinico_completo;

-- CONSULTA ESPECIFICA DE LA VISTA 1 (LISTO)
SELECT *
FROM vista_historial_clinico_completo
WHERE id_paciente = 'PAC001';



;


/*
====================================================================
CONSULTA DE LA VISTA 1
====================================================================
*/

SELECT *
FROM vista_historial_clinico_completo;


/*
Consulta específica para demostrar el historial de PAC-000001
*/

SELECT *
FROM vista_historial_clinico_completo
WHERE id_paciente = 'PAC001';


/*
====================================================================
MATEO - VISTA 2
INVENTARIO DE MEDICAMENTOS CON ALERTAS DE STOCK MINIMO
====================================================================

Esta vista permite controlar las existencias de medicamentos.

Se muestra:
- Medicamento.
- Presentación.
- Concentración.
- Stock actual.
- Stock mínimo.
- Estado del inventario.
- Lote próximo a caducar.
- Fecha de caducidad.
- Proveedor.
- Última reposición.
- Consumo promedio mensual.

Los estados son:

AGOTADO
Cuando el stock es igual a cero.

CRITICO
Cuando el stock es menor o igual al 50% del stock mínimo.

BAJO
Cuando el stock está por debajo del mínimo.

SUFICIENTE
Cuando el stock se encuentra dentro del nivel esperado.
====================================================================
*/

-- // PRUEBA DE LA VISTA 2 (ESTA VISTA ESTA BIEN)
DROP VIEW IF EXISTS vista_inventario_medicamentos_alerta;
CREATE VIEW vista_inventario_medicamentos_alerta AS

WITH stock_medicamentos AS
(
    SELECT
        l.medicamento,
        SUM(i.stock_actual) AS stock_actual,
        MAX(i.fecha_ultima_reposicion) AS ultima_reposicion

    FROM Inventario i

    INNER JOIN Lotes l
        ON l.id_lote = i.lote

    WHERE
        i.activo = TRUE
        AND l.activo = TRUE

    GROUP BY
        l.medicamento
),

lotes_proximos AS
(
    SELECT
        l.medicamento,
        l.id_lote,
        l.fecha_caducidad,

        ROW_NUMBER() OVER
        (
            PARTITION BY l.medicamento
            ORDER BY
                l.fecha_caducidad ASC,
                l.id_lote ASC
        ) AS posicion

    FROM Lotes l

    INNER JOIN Inventario i
        ON i.lote = l.id_lote

    WHERE
        l.activo = TRUE
        AND i.activo = TRUE
        AND i.stock_actual > 0
        AND l.fecha_caducidad >= CURDATE()
)

SELECT

    m.id_medicamento,
    m.nombre AS medicamento,
    m.principio_activo,
    m.presentacion,
    m.concentracion,

    COALESCE(sm.stock_actual, 0) AS stock_actual,

    m.stock_minimo,

    CASE

        WHEN COALESCE(sm.stock_actual, 0) = 0
            THEN 'agotado'

        WHEN COALESCE(sm.stock_actual, 0)
             <= (m.stock_minimo * 0.50)
            THEN 'critico'

        WHEN COALESCE(sm.stock_actual, 0)
             < m.stock_minimo
            THEN 'bajo'

        ELSE 'suficiente'

    END AS estado_stock,

    lp.id_lote AS lote_proximo_caducar,
    lp.fecha_caducidad,

    pr.id_proveedor,
    pr.nombre_comercial AS proveedor,

    sm.ultima_reposicion,

    m.consumo_promedio_mensual

FROM Medicamentos m

LEFT JOIN stock_medicamentos sm
    ON sm.medicamento = m.id_medicamento

LEFT JOIN lotes_proximos lp
    ON lp.medicamento = m.id_medicamento
    AND lp.posicion = 1

LEFT JOIN Inventario i
    ON i.lote = lp.id_lote

LEFT JOIN Proveedores pr
    ON pr.id_proveedor = i.proveedor

WHERE
    m.activo = TRUE

ORDER BY
    CASE

        WHEN COALESCE(sm.stock_actual, 0) = 0
            THEN 1

        WHEN COALESCE(sm.stock_actual, 0)
             <= (m.stock_minimo * 0.50)
            THEN 2

        WHEN COALESCE(sm.stock_actual, 0)
             < m.stock_minimo
            THEN 3

        ELSE 4

    END,
    m.nombre;

-- // PROBANDO LA VISTA 2
SELECT *
FROM vista_inventario_medicamentos_alerta;

-- // CASO ESPECIFICO
SELECT *
FROM vista_inventario_medicamentos_alerta
WHERE estado_stock IN
(
    'bajo',
    'critico',
    'agotado'
);
;


/*
====================================================================
CONSULTA GENERAL DE LA VISTA 2
====================================================================
*/

SELECT *
FROM vista_inventario_medicamentos_alerta;


/*
====================================================================
CONSULTA DE ALERTAS DE INVENTARIO
====================================================================

Permite demostrar únicamente los medicamentos que requieren
atención por tener stock bajo, crítico o agotado.
====================================================================
*/

SELECT *
FROM vista_inventario_medicamentos_alerta
WHERE estado_stock IN
      (
       'bajo',
       'critico',
       'agotado'
          );

/* 
============================================================================
VISTA 3 - REPORTE DE MEDICAMENTOS MAS RECETADOS Y SURTIDOS

Objetivo:
Proporcionar a la gerencia médica y comercial un resumen de los medicamentos más recetados por
los médicos y más surƟdos por la farmacia en un período, junto con su nivel de conversión receta–
venta. Sirve para tomar decisiones de compra, detectar recetas no surƟdas y evaluar la demanda
real del consultorio.

Información a visualizar:

- Medicamento y principio activo
- Cantidad de veces recetado por período
- Cantidad de veces surƟdo en farmacia
- Porcentaje de conversión receta–venta
- Médicos que más lo recetan
- Tendencia de consumo (creciente, estable, decreciente)
====================================================================
*/

DROP VIEW IF EXISTS vista_medicamentos_recetados_surtidos;

CREATE VIEW vista_medicamentos_recetados_surtidos AS
SELECT
    m.id_medicamento,
    m.nombre AS medicamento,
    m.principio_activo,
    COUNT(DISTINCT dr.receta) AS veces_recetado,
    COALESCE(COUNT(DISTINCT dv.venta),0) AS veces_surtido,
    COALESCE(SUM(dv.cantidad),0) AS unidades_surtidas,
    ROUND(
        CASE WHEN COUNT(DISTINCT dr.receta)=0 THEN 0
             ELSE COUNT(DISTINCT dv.venta)*100.0/COUNT(DISTINCT dr.receta)
        END, 2
    ) AS porcentaje_conversion_receta_venta,
    GROUP_CONCAT(DISTINCT CONCAT(e.nombre,' ',e.apellidos)
                 ORDER BY e.nombre SEPARATOR ', ') AS medicos_que_recetan,
    CASE
      WHEN COALESCE(SUM(CASE WHEN v.fecha_venta >= DATE_SUB(CURDATE(),INTERVAL 30 DAY)
                             THEN dv.cantidad ELSE 0 END),0)
         > COALESCE(SUM(CASE WHEN v.fecha_venta >= DATE_SUB(CURDATE(),INTERVAL 60 DAY)
                              AND v.fecha_venta < DATE_SUB(CURDATE(),INTERVAL 30 DAY)
                             THEN dv.cantidad ELSE 0 END),0)
      THEN 'creciente'
      WHEN COALESCE(SUM(CASE WHEN v.fecha_venta >= DATE_SUB(CURDATE(),INTERVAL 30 DAY)
                             THEN dv.cantidad ELSE 0 END),0)
         < COALESCE(SUM(CASE WHEN v.fecha_venta >= DATE_SUB(CURDATE(),INTERVAL 60 DAY)
                              AND v.fecha_venta < DATE_SUB(CURDATE(),INTERVAL 30 DAY)
                             THEN dv.cantidad ELSE 0 END),0)
      THEN 'decreciente'
      ELSE 'estable'
    END AS tendencia_consumo
FROM Medicamentos m
LEFT JOIN Detalles_Receta dr ON dr.medicamento=m.id_medicamento
LEFT JOIN Recetas r ON r.id_receta=dr.receta
LEFT JOIN Consultas c ON c.id_consulta=r.consulta
LEFT JOIN Medicos me ON me.id_medico=c.medico
LEFT JOIN Empleados e ON e.id_empleado=me.empleado
LEFT JOIN Detalles_Venta dv ON dv.medicamento=m.id_medicamento
LEFT JOIN Ventas v ON v.id_venta=dv.venta AND v.receta=dr.receta
GROUP BY m.id_medicamento,m.nombre,m.principio_activo;

-- // PROBANDO LA VISTA 3
SELECT * FROM vista_medicamentos_recetados_surtidos
;

/*
====================================================================
CONSULTA GENERAL DE LA VISTA 3
====================================================================
*/

SELECT *
FROM vista_medicamentos_recetados_surtidos;

/* ============================================================================
   SP 1 - REGISTRAR CONSULTA Y EMITIR RECETA MEDICA
   Acepta cualquier ID existente de paciente/medico/diagnostico/medicamento.
   Los IDs de consulta, receta y folio deben ser nuevos.
   ============================================================================ */
DELIMITER //
CREATE PROCEDURE SP1_Registrar_Consulta_Receta(
    -- IDs generados y enviados desde la aplicación
    IN p_id_consulta VARCHAR(10),
    IN p_id_receta VARCHAR(10),
    IN p_folio_receta VARCHAR(30),
    
    IN p_id_paciente VARCHAR(10),
    IN p_id_medico VARCHAR(10),
    IN p_id_diagnostico VARCHAR(10),
    IN p_motivo VARCHAR(255),
    IN p_costo DECIMAL(10,2),
    IN p_observaciones TEXT,
    
    -- Datos de un (1) medicamento para el detalle de la receta
    IN p_medicamento VARCHAR(10),
    IN p_cantidad INT,
    IN p_dosis VARCHAR(60),
    IN p_frecuencia VARCHAR(60),
    IN p_duracion VARCHAR(60),
    IN p_via VARCHAR(20)
)
BEGIN
    DECLARE v_paciente_activo BOOLEAN;
    DECLARE v_medico_valido INT;
    DECLARE v_alergia_count INT;

    -- 1. Validar Paciente
    SELECT activo INTO v_paciente_activo FROM Pacientes WHERE id_paciente = p_id_paciente;
    IF v_paciente_activo IS NULL OR v_paciente_activo = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Paciente no existe o está inactivo.';
    END IF;

    -- 2. Validar Médico
    SELECT COUNT(*) INTO v_medico_valido FROM Medicos 
    WHERE id_medico = p_id_medico AND activo = TRUE AND cedula_vigencia >= CURDATE();
    IF v_medico_valido = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Médico inactivo o con cédula vencida.';
    END IF;

    -- 3. Validar Alergias / Contraindicaciones para el medicamento enviado
    SELECT COUNT(*) INTO v_alergia_count
    FROM Historial_Condicion hc
    JOIN Historiales_Clinicos h ON hc.historial = h.id_historial
    JOIN Medicamento_Condicion mc ON mc.condicion = hc.condicion
    WHERE h.paciente = p_id_paciente AND mc.medicamento = p_medicamento AND hc.activa = TRUE;

    IF v_alergia_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Riesgo Clínico: El paciente presenta alergia al medicamento prescrito.';
    END IF;

    -- Insertar Consulta
    INSERT INTO Consultas (id_consulta, paciente, medico, diagnostico, fecha, motivo, costo_consulta, observaciones)
    VALUES (p_id_consulta, p_id_paciente, p_id_medico, p_id_diagnostico, NOW(), p_motivo, p_costo, p_observaciones);

    -- Insertar Receta Base
    INSERT INTO Recetas (id_receta, consulta, folio, fecha_emision, fecha_vencimiento, estado)
    VALUES (p_id_receta, p_id_consulta, p_folio_receta, NOW(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'emitida');

    -- Insertar Detalle de Receta
    INSERT INTO Detalles_Receta (receta, medicamento, dosis, frecuencia, duracion, cantidad_prescrita, via_administracion)
    VALUES (p_id_receta, p_medicamento, p_dosis, p_frecuencia, p_duracion, p_cantidad, p_via);

END //
DELIMITER ;

/* ============================================================================
   SP 2 - SURTIR RECETA Y ACTUALIZAR INVENTARIO
   ============================================================================ */
DELIMITER //

CREATE PROCEDURE SP2_Surtir_Receta(
    IN p_id_venta VARCHAR(10),
    IN p_id_receta VARCHAR(10),
    IN p_id_empleado VARCHAR(10),
    IN p_tipo_pago VARCHAR(20),
    IN p_descuento DECIMAL(10,2)
)
BEGIN
    DECLARE v_estado_receta VARCHAR(20);
    DECLARE v_fecha_vencimiento DATE;

    -- 1. Verificar validez de la receta
    SELECT estado, fecha_vencimiento INTO v_estado_receta, v_fecha_vencimiento 
    FROM Recetas WHERE id_receta = p_id_receta;
    
    IF v_estado_receta NOT IN ('emitida', 'surtida_parcial') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La receta ya fue surtida o está cancelada.';
    END IF;
    
    IF v_fecha_vencimiento < CURDATE() THEN
        UPDATE Recetas SET estado = 'vencida' WHERE id_receta = p_id_receta;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La receta ha expirado.';
    END IF;

    -- 2. Insertar cabecera de la venta
    INSERT INTO Ventas (id_venta, empleado, receta, fecha_venta, tipo_pago, descuento, monto_total)
    VALUES (p_id_venta, p_id_empleado, p_id_receta, NOW(), p_tipo_pago, p_descuento, 0);

    -- 3. Insertar detalles de venta buscando el lote correcto a través de la tabla Lotes
    INSERT INTO Detalles_Venta (venta, medicamento, lote, cantidad, precio_unitario, subtotal)
    SELECT 
        p_id_venta,
        dr.medicamento,
        (
            SELECT i.lote 
            FROM Inventario i
            JOIN Lotes l ON i.lote = l.id_lote
            WHERE l.medicamento = dr.medicamento 
              AND i.stock_actual >= dr.cantidad_prescrita 
              AND l.fecha_caducidad >= CURDATE()
            ORDER BY l.fecha_caducidad ASC 
            LIMIT 1
        ) AS lote_asignado,
        dr.cantidad_prescrita,
        m.precio_venta,
        (dr.cantidad_prescrita * m.precio_venta)
    FROM Detalles_Receta dr
    JOIN Medicamentos m ON dr.medicamento = m.id_medicamento
    WHERE dr.receta = p_id_receta;

    -- 4. Actualizar stock en Inventario
    UPDATE Inventario i
    JOIN Detalles_Venta dv ON i.lote = dv.lote
    SET i.stock_actual = i.stock_actual - dv.cantidad
    WHERE dv.venta = p_id_venta;

    -- 5. Actualizar el monto total de la venta
    UPDATE Ventas 
    SET monto_total = (SELECT SUM(subtotal) FROM Detalles_Venta WHERE venta = p_id_venta) - p_descuento 
    WHERE id_venta = p_id_venta;

    -- 6. Actualizar estado de la receta
    UPDATE Recetas SET estado = 'surtida_total' WHERE id_receta = p_id_receta;

END //

DELIMITER ;


/* ============================================================================
   SP 3 - GENERAR ORDEN DE REPOSICION POR STOCK MINIMO
   ============================================================================ */
DELIMITER //
CREATE PROCEDURE SP3_Generar_Ordenes_Reposicion()
BEGIN
    -- Inserción masiva evaluando mínimos y máximos en una sola consulta
    INSERT INTO Ordenes_Compra (
        id_orden_compra, proveedor, medicamento, empleado, cantidad_solicitada, 
        fecha_generacion, fecha_estimada_entrega, estado, generada_automatica, observaciones
    )
    SELECT 
        -- Crea un ID dinámico basado en el medicamento (Ej: O-MED001)
        CONCAT('O-', m.id_medicamento), 
        pr.id_proveedor,
        m.id_medicamento,
        NULL,
        -- Cálculo de requerimiento sumando colchón de consumo por días de entrega
        (m.stock_maximo - COALESCE(SUM(i.stock_actual), 0)) + ROUND((m.consumo_promedio_mensual / 30) * pr.tiempo_entrega_dias),
        NOW(),
        DATE_ADD(CURDATE(), INTERVAL pr.tiempo_entrega_dias DAY),
        'pendiente',
        TRUE,
        'Orden generada automáticamente por stock mínimo'
    FROM Medicamentos m
    LEFT JOIN Lotes l ON m.id_medicamento = l.medicamento AND l.fecha_caducidad > CURDATE()
    LEFT JOIN Inventario i ON l.id_lote = i.lote
    -- Toma el primer proveedor activo como referencia de entrega
    CROSS JOIN (
        SELECT id_proveedor, tiempo_entrega_dias 
        FROM Proveedores 
        WHERE activo = TRUE 
        LIMIT 1
    ) pr
    WHERE m.activo = TRUE
      -- Evitar duplicar si el medicamento ya tiene orden pendiente
      AND m.id_medicamento NOT IN (
          SELECT medicamento 
          FROM Ordenes_Compra 
          WHERE estado IN ('pendiente', 'enviada')
      )
    GROUP BY 
        m.id_medicamento, 
        m.stock_maximo, 
        m.stock_minimo, 
        m.consumo_promedio_mensual,
        pr.id_proveedor, 
        pr.tiempo_entrega_dias
    -- Filtro final: solo los que tengan stock actual igual o menor al mínimo
    HAVING COALESCE(SUM(i.stock_actual), 0) <= m.stock_minimo;
END //
DELIMITER ;

/* ============================================================================
   TRIGGER 1 - BEFORE INSERT EN DETALLES_RECETA
   Valida paciente, medico, medicamento, stock, contraindicaciones,
   interacciones, dosis y duracion.
   ============================================================================ */
DELIMITER //
CREATE TRIGGER TRG_Validar_Nueva_Receta
BEFORE INSERT ON Detalles_Receta
FOR EACH ROW
BEGIN
    DECLARE v_paciente VARCHAR(10);
    DECLARE v_paciente_activo BOOLEAN;
    DECLARE v_medico_activo BOOLEAN;
    DECLARE v_cedula_vigencia DATE;
    DECLARE v_medicamento_activo BOOLEAN;
    DECLARE v_alergia_count INT;
    DECLARE v_interaccion_count INT;

    -- 1. Obtener datos de la cabecera (Paciente y Médico) vinculados a esta receta
    SELECT p.id_paciente, p.activo, m.activo, m.cedula_vigencia 
    INTO v_paciente, v_paciente_activo, v_medico_activo, v_cedula_vigencia
    FROM Recetas r
    JOIN Consultas c ON r.consulta = c.id_consulta
    JOIN Pacientes p ON c.paciente = p.id_paciente
    JOIN Medicos m ON c.medico = m.id_medico
    WHERE r.id_receta = NEW.receta;

    -- 2. Validar Paciente y Médico
    IF v_paciente_activo = FALSE OR v_paciente_activo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rechazo: El paciente no existe o está inactivo en el sistema.';
    END IF;

    IF v_medico_activo = FALSE OR v_cedula_vigencia < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rechazo: El médico está inactivo o su licencia profesional ha expirado.';
    END IF;
    -- 3. Validar existencia del medicamento en catálogo
    SELECT activo INTO v_medicamento_activo 
    FROM Medicamentos 
    WHERE id_medicamento = NEW.medicamento;
    IF v_medicamento_activo = FALSE OR v_medicamento_activo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rechazo: El medicamento recetado no está activo en el catálogo.';
    END IF;
    -- 4. Validar Alergias y Contraindicaciones
    SELECT COUNT(*) INTO v_alergia_count
    FROM Historial_Condicion hc
    JOIN Historiales_Clinicos h ON hc.historial = h.id_historial
    JOIN Medicamento_Condicion mc ON mc.condicion = hc.condicion
    WHERE h.paciente = v_paciente 
      AND mc.medicamento = NEW.medicamento 
      AND hc.activa = TRUE;
    IF v_alergia_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alerta de Seguridad: El paciente presenta una alergia o contraindicación a este fármaco.';
    END IF;
    -- 5. Validar Interacciones con otros medicamentos que ya se hayan insertado en la misma receta
    SELECT COUNT(*) INTO v_interaccion_count
    FROM Detalles_Receta dr
    JOIN Interacciones_Medicamentosas im 
      ON (im.medicamento_a = NEW.medicamento AND im.medicamento_b = dr.medicamento)
      OR (im.medicamento_b = NEW.medicamento AND im.medicamento_a = dr.medicamento)
    WHERE dr.receta = NEW.receta 
      AND im.nivel_riesgo IN ('moderada', 'severa') 
      AND im.activa = TRUE;
    IF v_interaccion_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alerta de Seguridad: Riesgo de interacción severa/moderada con otro fármaco en la misma receta.';
    END IF;
END //
DELIMITER ;


/* ============================================================================
   TRIGGER 2 - AFTER UPDATE EN INVENTARIO
   Registra automaticamente cada cambio de stock en la tabla LOG.
   ============================================================================ */
DELIMITER //
CREATE TRIGGER TRG_Auditoria_Inventario
AFTER UPDATE ON Inventario
FOR EACH ROW
BEGIN
    DECLARE v_medicamento VARCHAR(10);

    -- Ejecutar solo si la cantidad de stock real sufrió modificaciones
    IF OLD.stock_actual <> NEW.stock_actual THEN
        
        -- Localizar a qué medicamento pertenece el lote alterado
        SELECT medicamento INTO v_medicamento 
        FROM Lotes 
        WHERE id_lote = NEW.lote;

        INSERT INTO Auditoria_Inventario (
            id_auditoria, 
            medicamento, 
            lote, 
            stock_anterior, 
            stock_nuevo, 
            tipo_movimiento, 
            fecha_movimiento, 
            usuario_proceso, 
            observaciones
        ) VALUES (
            -- Genera un ID basado en el tiempo (Ejemplo: A-143520)
            CONCAT('A-', DATE_FORMAT(NOW(), '%H%i%s')),
            v_medicamento,
            NEW.lote,
            OLD.stock_actual,
            NEW.stock_actual,
            COALESCE(NEW.ultimo_movimiento, 'ajuste'),
            NOW(),
            USER(),
            COALESCE(NEW.observaciones, 'Modificación detectada y registrada por el sistema')
        );
    END IF;
END //
DELIMITER ;

/* ============================================================================
   Pruebas de los PROCEDURES
   ============================================================================ */

-- ----------------------------------------------------------------------------
-- Prueba SP1
-- ----------------------------------------------------------------------------
-- Debe lanzar ERROR: "Riesgo Clínico: El paciente presenta alergia al medicamento prescrito."
CALL SP1_Registrar_Consulta_Receta(
    'CON901', 'REC901', 'FOL-TEST-001', 
    'PAC001', 'MED001', 'DIA001', 'Prueba alergia', 500.00, 'Ninguna',
    'MED004', 10, '500 mg', 'Cada 8 horas', '7 dias', 'oral'
);
-- Evidencia: Confirmar que la consulta NO se registró en la base de datos
SELECT * FROM Consultas WHERE id_consulta = 'CON901';

-- ----------------------------------------------------------------------------
-- Prueba SP2
-- ----------------------------------------------------------------------------
-- 1. Verificamos stock ANTES de la venta (Loratadina en REC011 -> MED002)
SELECT lote, stock_actual FROM Inventario WHERE lote IN ('LOT003', 'LOT004');
-- 2. Ejecutamos el surtido
CALL SP2_Surtir_Receta('VEN901', 'REC011', 'EMP002', 'efectivo', 0.00);
-- 3. Evidencia: Verificamos cambio de estado a 'surtida_total' y venta generada
SELECT id_receta, estado FROM Recetas WHERE id_receta = 'REC011';
SELECT id_venta, monto_total FROM Ventas WHERE id_venta = 'VEN901';
-- 4. Evidencia: Verificamos el stock DESPUÉS de la venta (debe haber bajado en 10 unidades)
SELECT lote, stock_actual FROM Inventario WHERE lote IN ('LOT003', 'LOT004');
-- 5. Evidencia: Verificamos la bitácora de auditoría generada automáticamente
SELECT * FROM Auditoria_Inventario ORDER BY fecha_movimiento DESC LIMIT 1;

-- ----------------------------------------------------------------------------
-- Prueba SP3
-- ----------------------------------------------------------------------------
-- 1. Forzamos stock por debajo del mínimo (Omeprazol MED005, min: 15)
UPDATE Inventario SET stock_actual = 2, observaciones = 'Merma prueba' WHERE id_inventario = 'INV007';
-- 2. Ejecutamos motor de reabastecimiento
CALL SP3_Generar_Ordenes_Reposicion();
-- 3. Evidencia: Demostrar que se creó la orden con estado 'pendiente'
SELECT id_orden_compra, medicamento, cantidad_solicitada, estado 
FROM Ordenes_Compra 
WHERE medicamento = 'MED005' 
ORDER BY fecha_generacion DESC LIMIT 1;

-- ----------------------------------------------------------------------------
-- Prueba Trigger 1
-- ----------------------------------------------------------------------------
-- 1. Preparamos consulta y receta base
INSERT INTO Consultas (id_consulta, paciente, medico, diagnostico, fecha, motivo, costo_consulta) 
VALUES ('CON902', 'PAC003', 'MED001', 'DIA001', NOW(), 'Prueba interacción', 400.00);
INSERT INTO Recetas (id_receta, consulta, folio, fecha_emision, fecha_vencimiento, estado) 
VALUES ('REC902', 'CON902', 'FOL-TEST-002', NOW(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'emitida');
-- 2. Insertamos el primer medicamento (Ibuprofeno - Éxito)
INSERT INTO Detalles_Receta (receta, medicamento, dosis, frecuencia, duracion, cantidad_prescrita, via_administracion) 
VALUES ('REC902', 'MED003', '400 mg', 'Cada 8 horas', '3 días', 9, 'oral');
-- 3. Insertamos el segundo medicamento incompatible (Naproxeno -> Debe lanzar ERROR)
INSERT INTO Detalles_Receta (receta, medicamento, dosis, frecuencia, duracion, cantidad_prescrita, via_administracion) 
VALUES ('REC902', 'MED009', '250 mg', 'Cada 12 horas', '3 días', 6, 'oral');
-- 4. Evidencia: Comprobar que solo quedó registrado el MED003 y se bloqueó el MED009
SELECT * FROM Detalles_Receta WHERE receta = 'REC902';

-- ----------------------------------------------------------------------------
-- Prueba Trigger 2
-- ----------------------------------------------------------------------------
-- 1. Modificamos el stock directamente
UPDATE Inventario 
SET stock_actual = stock_actual - 1, ultimo_movimiento = 'merma', observaciones = 'Ajuste de prueba' 
WHERE id_inventario = 'INV001';
-- 2. Evidencia: Comprobar que el Trigger registró el movimiento en la auditoría
SELECT * FROM Auditoria_Inventario ORDER BY fecha_movimiento DESC LIMIT 1;




















