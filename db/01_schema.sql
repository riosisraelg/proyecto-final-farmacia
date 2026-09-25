-- =====================================================================
--  SCRIPT DDL - MySQL 8.x
--  PROYECTO FINAL - Farmacia con Consultorio Medico
--  Generado a partir del MER: DER_Proyecto_Final.txt  (20 tablas)
-- ---------------------------------------------------------------------
--  Permite implementar:
--    CRUD, Vista 1/2/3, SP1/SP2/SP3, Trigger 1 y 2, LOG de inventario.
--  CONVENCION:
--    PK = id_<entidad>
--    FK = nombre de la entidad relacionada sin "id_"
--  Los ENUM del DBML se implementan como tipo ENUM de MySQL.
--  Los comentarios del DBML se conservan como COMMENT de columna.
-- ---------------------------------------------------------------------
--  ORDEN DE CREACION (por dependencias de FK):
--    Empleados -> Medicos -> Pacientes -> Historiales_Clinicos ->
--    Condiciones_Clinicas -> Historial_Condicion -> Diagnosticos ->
--    Consultas -> Medicamentos -> Medicamento_Condicion ->
--    Interacciones_Medicamentosas -> Recetas -> Detalles_Receta ->
--    Proveedores -> Ordenes_Compra -> Lotes -> Inventario ->
--    Ventas -> Detalles_Venta -> Auditoria_Inventario
-- =====================================================================

DROP DATABASE IF EXISTS proyecto_final_data_base;
CREATE DATABASE proyecto_final_data_base
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE proyecto_final_data_base;

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
--  DROP en orden inverso a las dependencias (hijos primero), para que
--  el script se pueda RE-EJECUTAR sin errores de llaves foraneas.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS Auditoria_Inventario;
DROP TABLE IF EXISTS Detalles_Venta;
DROP TABLE IF EXISTS Ventas;
DROP TABLE IF EXISTS Inventario;
DROP TABLE IF EXISTS Lotes;
DROP TABLE IF EXISTS Ordenes_Compra;
DROP TABLE IF EXISTS Proveedores;
DROP TABLE IF EXISTS Detalles_Receta;
DROP TABLE IF EXISTS Recetas;
DROP TABLE IF EXISTS Interacciones_Medicamentosas;
DROP TABLE IF EXISTS Medicamento_Condicion;
DROP TABLE IF EXISTS Medicamentos;
DROP TABLE IF EXISTS Consultas;
DROP TABLE IF EXISTS Diagnosticos;
DROP TABLE IF EXISTS Historial_Condicion;
DROP TABLE IF EXISTS Condiciones_Clinicas;
DROP TABLE IF EXISTS Historiales_Clinicos;
DROP TABLE IF EXISTS Pacientes;
DROP TABLE IF EXISTS Medicos;
DROP TABLE IF EXISTS Empleados;

-- =====================================================================
--  1. EMPLEADOS  (informacion general de trabajadores)
-- =====================================================================
CREATE TABLE Empleados (
  id_empleado   VARCHAR(10)  NOT NULL,
  nombre        VARCHAR(50)  NOT NULL,
  apellidos     VARCHAR(100) NOT NULL,
  puesto        VARCHAR(60)  NOT NULL,
  telefono      VARCHAR(15)  NULL,
  correo        VARCHAR(100) NULL,
  activo        BOOLEAN      NOT NULL DEFAULT TRUE,
  fecha_ingreso DATE         NOT NULL,
  CONSTRAINT pk_empleados PRIMARY KEY (id_empleado)
) ENGINE=InnoDB;

-- =====================================================================
--  2. MEDICOS  (extension 1:1 de Empleados)
-- =====================================================================
CREATE TABLE Medicos (
  id_medico          VARCHAR(10) NOT NULL,
  empleado           VARCHAR(10) NOT NULL           COMMENT 'FK 1:1 -> Empleados',
  cedula_profesional VARCHAR(20) NOT NULL,
  cedula_vigencia    DATE        NOT NULL,
  especialidad       VARCHAR(80) NULL,
  activo             BOOLEAN     NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_medicos PRIMARY KEY (id_medico),
  CONSTRAINT uq_medicos_empleado UNIQUE (empleado),
  CONSTRAINT uq_medicos_cedula   UNIQUE (cedula_profesional),
  CONSTRAINT fk_medicos_empleado FOREIGN KEY (empleado) REFERENCES Empleados (id_empleado)
) ENGINE=InnoDB;

-- =====================================================================
--  3. PACIENTES
-- =====================================================================
CREATE TABLE Pacientes (
  id_paciente      VARCHAR(10)  NOT NULL,
  nombre           VARCHAR(50)  NOT NULL,
  apellidos        VARCHAR(100) NOT NULL,
  fecha_nacimiento DATE         NOT NULL,
  telefono         VARCHAR(15)  NOT NULL,
  correo           VARCHAR(100) NULL,
  direccion        VARCHAR(150) NULL,
  activo           BOOLEAN      NOT NULL DEFAULT TRUE,
  fecha_registro   DATETIME     NOT NULL,
  CONSTRAINT pk_pacientes PRIMARY KEY (id_paciente)
) ENGINE=InnoDB;

-- =====================================================================
--  4. HISTORIALES_CLINICOS  (1:1 con Pacientes)
-- =====================================================================
CREATE TABLE Historiales_Clinicos (
  id_historial        VARCHAR(10) NOT NULL,
  paciente            VARCHAR(10) NOT NULL           COMMENT 'FK 1:1 -> Pacientes',
  antecedentes        TEXT        NULL,
  observaciones       TEXT        NULL,
  fecha_actualizacion DATETIME    NOT NULL,
  CONSTRAINT pk_historiales PRIMARY KEY (id_historial),
  CONSTRAINT uq_historiales_paciente UNIQUE (paciente),
  CONSTRAINT fk_historiales_paciente FOREIGN KEY (paciente) REFERENCES Pacientes (id_paciente)
) ENGINE=InnoDB;

-- =====================================================================
--  5. CONDICIONES_CLINICAS  (unifica alergias y contraindicaciones)
-- =====================================================================
CREATE TABLE Condiciones_Clinicas (
  id_condicion VARCHAR(10)  NOT NULL,
  tipo ENUM('alergia','contraindicacion') NOT NULL  COMMENT 'enum tipo_condicion',
  nombre       VARCHAR(100) NOT NULL,
  descripcion  VARCHAR(255) NULL,
  activa       BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_condiciones PRIMARY KEY (id_condicion),
  CONSTRAINT uq_condiciones_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

-- =====================================================================
--  6. HISTORIAL_CONDICION  (condiciones del paciente; SP1)
-- =====================================================================
CREATE TABLE Historial_Condicion (
  historial      VARCHAR(10)  NOT NULL               COMMENT 'FK -> Historiales_Clinicos',
  condicion      VARCHAR(10)  NOT NULL               COMMENT 'FK -> Condiciones_Clinicas',
  reaccion       VARCHAR(150) NULL,
  severidad      ENUM('leve','moderada','severa') NULL COMMENT 'enum nivel_riesgo',
  observaciones  VARCHAR(255) NULL,
  fecha_registro DATE         NOT NULL,
  activa         BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_historial_condicion PRIMARY KEY (historial, condicion),
  CONSTRAINT fk_hcond_historial FOREIGN KEY (historial) REFERENCES Historiales_Clinicos (id_historial),
  CONSTRAINT fk_hcond_condicion FOREIGN KEY (condicion) REFERENCES Condiciones_Clinicas (id_condicion)
) ENGINE=InnoDB;

-- =====================================================================
--  7. DIAGNOSTICOS  (catalogo; se crea antes de Consultas)
-- =====================================================================
CREATE TABLE Diagnosticos (
  id_diagnostico VARCHAR(10)  NOT NULL,
  nombre         VARCHAR(100) NOT NULL,
  descripcion    VARCHAR(255) NULL,
  activo         BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_diagnosticos PRIMARY KEY (id_diagnostico),
  CONSTRAINT uq_diagnosticos_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

-- =====================================================================
--  8. CONSULTAS  (paciente + medico + diagnostico)
-- =====================================================================
CREATE TABLE Consultas (
  id_consulta          VARCHAR(10)   NOT NULL,
  paciente             VARCHAR(10)   NOT NULL        COMMENT 'FK -> Pacientes',
  medico               VARCHAR(10)   NOT NULL        COMMENT 'FK -> Medicos',
  diagnostico          VARCHAR(10)   NOT NULL        COMMENT 'FK -> Diagnosticos',
  fecha                DATETIME      NOT NULL,
  motivo               VARCHAR(255)  NOT NULL,
  costo_consulta       DECIMAL(10,2) NOT NULL,
  tratamiento_indicado TEXT          NULL,
  observaciones        TEXT          NULL,
  CONSTRAINT pk_consultas PRIMARY KEY (id_consulta),
  CONSTRAINT fk_consultas_paciente    FOREIGN KEY (paciente)    REFERENCES Pacientes (id_paciente),
  CONSTRAINT fk_consultas_medico      FOREIGN KEY (medico)      REFERENCES Medicos (id_medico),
  CONSTRAINT fk_consultas_diagnostico FOREIGN KEY (diagnostico) REFERENCES Diagnosticos (id_diagnostico)
) ENGINE=InnoDB;

-- =====================================================================
--  9. MEDICAMENTOS  (catalogo + parametros de reposicion SP3)
-- =====================================================================
CREATE TABLE Medicamentos (
  id_medicamento     VARCHAR(10)   NOT NULL,
  categoria_medicamento ENUM('analgesico','antibiotico','antiinflamatorio',
                             'antihistaminico','antiviral','antifungico',
                             'cardiovascular','gastrointestinal','respiratorio',
                             'dermatologico','vitamina_suplemento','otro') NOT NULL
                                                     COMMENT 'enum categoria_medicamento',
  nombre             VARCHAR(120)  NOT NULL,
  principio_activo   VARCHAR(120)  NOT NULL,
  nombre_comercial   VARCHAR(120)  NULL,
  nombre_generico    VARCHAR(120)  NULL,
  presentacion       VARCHAR(80)   NOT NULL,
  concentracion      VARCHAR(60)   NOT NULL,
  dosis_referencia   VARCHAR(60)   NULL,
  duracion_maxima_dias INT         NULL,
  descripcion        VARCHAR(255)  NULL,
  requiere_receta    BOOLEAN       NOT NULL DEFAULT FALSE,
  registro_sanitario VARCHAR(60)   NULL,
  precio_venta       DECIMAL(10,2) NOT NULL,
  stock_minimo       INT           NOT NULL DEFAULT 0,
  stock_maximo       INT           NOT NULL DEFAULT 0,
  punto_reorden      INT           NOT NULL DEFAULT 0,
  consumo_promedio_mensual DECIMAL(10,2) NOT NULL DEFAULT 0,
  activo             BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_medicamentos PRIMARY KEY (id_medicamento),
  CONSTRAINT uq_medicamentos_registro UNIQUE (registro_sanitario)
) ENGINE=InnoDB;

-- =====================================================================
--  10. MEDICAMENTO_CONDICION  (med <-> alergia/contraindicacion)
-- =====================================================================
CREATE TABLE Medicamento_Condicion (
  medicamento   VARCHAR(10)  NOT NULL                COMMENT 'FK -> Medicamentos',
  condicion     VARCHAR(10)  NOT NULL                COMMENT 'FK -> Condiciones_Clinicas',
  nivel_riesgo  ENUM('leve','moderada','severa') NOT NULL COMMENT 'enum nivel_riesgo',
  observaciones VARCHAR(255) NULL,
  CONSTRAINT pk_med_condicion PRIMARY KEY (medicamento, condicion),
  CONSTRAINT fk_mcond_medicamento FOREIGN KEY (medicamento) REFERENCES Medicamentos (id_medicamento),
  CONSTRAINT fk_mcond_condicion   FOREIGN KEY (condicion)   REFERENCES Condiciones_Clinicas (id_condicion)
) ENGINE=InnoDB;

-- =====================================================================
--  11. INTERACCIONES_MEDICAMENTOSAS  (entre dos medicamentos)
-- =====================================================================
CREATE TABLE Interacciones_Medicamentosas (
  id_interaccion VARCHAR(10)  NOT NULL,
  medicamento_a  VARCHAR(10)  NOT NULL               COMMENT 'FK -> Medicamentos',
  medicamento_b  VARCHAR(10)  NOT NULL               COMMENT 'FK -> Medicamentos',
  nivel_riesgo   ENUM('leve','moderada','severa') NOT NULL COMMENT 'enum nivel_riesgo',
  efecto         VARCHAR(255) NULL,
  recomendacion  VARCHAR(255) NULL,
  activa         BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_interacciones PRIMARY KEY (id_interaccion),
  CONSTRAINT uq_interacciones_par UNIQUE (medicamento_a, medicamento_b),
  CONSTRAINT chk_interacciones_distintos CHECK (medicamento_a <> medicamento_b),
  CONSTRAINT fk_itx_med_a FOREIGN KEY (medicamento_a) REFERENCES Medicamentos (id_medicamento),
  CONSTRAINT fk_itx_med_b FOREIGN KEY (medicamento_b) REFERENCES Medicamentos (id_medicamento)
) ENGINE=InnoDB;

-- =====================================================================
--  12. RECETAS
-- =====================================================================
CREATE TABLE Recetas (
  id_receta         VARCHAR(10)  NOT NULL,
  consulta          VARCHAR(10)  NOT NULL            COMMENT 'FK -> Consultas',
  folio             VARCHAR(30)  NOT NULL,
  fecha_emision     DATETIME     NOT NULL,
  fecha_vencimiento DATE         NOT NULL,
  estado ENUM('emitida','surtida_parcial','surtida_total','vencida','cancelada')
                    NOT NULL DEFAULT 'emitida'       COMMENT 'enum estado_receta',
  lugar_emision     VARCHAR(120) NULL,
  diagnostico_texto TEXT         NULL,
  indicaciones      TEXT         NULL,
  observaciones     TEXT         NULL,
  CONSTRAINT pk_recetas PRIMARY KEY (id_receta),
  CONSTRAINT uq_recetas_folio UNIQUE (folio),
  CONSTRAINT fk_recetas_consulta FOREIGN KEY (consulta) REFERENCES Consultas (id_consulta)
) ENGINE=InnoDB;

-- =====================================================================
--  13. DETALLES_RECETA  (Trigger 1 se implementa aqui)
-- =====================================================================
CREATE TABLE Detalles_Receta (
  receta                    VARCHAR(10)  NOT NULL    COMMENT 'FK -> Recetas',
  medicamento               VARCHAR(10)  NOT NULL    COMMENT 'FK -> Medicamentos',
  dosis                     VARCHAR(60)  NOT NULL,
  frecuencia                VARCHAR(60)  NOT NULL,
  duracion                  VARCHAR(60)  NOT NULL,
  cantidad_prescrita        INT          NOT NULL,
  via_administracion ENUM('oral','intravenosa','intramuscular','subcutanea',
                          'topica','oftalmica','otica','nasal','rectal','inhalada')
                            NOT NULL                 COMMENT 'enum via_administracion',
  instrucciones_especificas VARCHAR(255) NULL,
  observaciones             VARCHAR(255) NULL,
  CONSTRAINT pk_det_receta PRIMARY KEY (receta, medicamento),
  CONSTRAINT fk_dr_receta      FOREIGN KEY (receta)      REFERENCES Recetas (id_receta),
  CONSTRAINT fk_dr_medicamento FOREIGN KEY (medicamento) REFERENCES Medicamentos (id_medicamento)
) ENGINE=InnoDB;

-- =====================================================================
--  14. PROVEEDORES
-- =====================================================================
CREATE TABLE Proveedores (
  id_proveedor        VARCHAR(10)  NOT NULL,
  nombre_comercial    VARCHAR(120) NOT NULL,
  telefono            VARCHAR(15)  NULL,
  correo              VARCHAR(100) NULL,
  tiempo_entrega_dias INT          NULL,
  activo              BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_proveedores PRIMARY KEY (id_proveedor)
) ENGINE=InnoDB;

-- =====================================================================
--  15. ORDENES_COMPRA  (por medicamento; SP3)
-- =====================================================================
CREATE TABLE Ordenes_Compra (
  id_orden_compra        VARCHAR(10)   NOT NULL,
  proveedor              VARCHAR(10)   NOT NULL      COMMENT 'FK -> Proveedores',
  medicamento            VARCHAR(10)   NOT NULL      COMMENT 'FK -> Medicamentos',
  empleado               VARCHAR(10)   NULL          COMMENT 'FK -> Empleados',
  cantidad_solicitada    INT           NOT NULL,
  costo_unitario         DECIMAL(10,2) NULL,
  fecha_generacion       DATETIME      NOT NULL,
  fecha_estimada_entrega DATE          NULL,
  estado ENUM('pendiente','enviada','recibida_parcial','recibida_total','cancelada')
                         NOT NULL DEFAULT 'pendiente' COMMENT 'enum estado_orden_compra',
  generada_automatica    BOOLEAN       NOT NULL DEFAULT TRUE,
  observaciones          VARCHAR(255)  NULL,
  CONSTRAINT pk_ordenes_compra PRIMARY KEY (id_orden_compra),
  CONSTRAINT fk_oc_proveedor   FOREIGN KEY (proveedor)   REFERENCES Proveedores (id_proveedor),
  CONSTRAINT fk_oc_medicamento FOREIGN KEY (medicamento) REFERENCES Medicamentos (id_medicamento),
  CONSTRAINT fk_oc_empleado    FOREIGN KEY (empleado)    REFERENCES Empleados (id_empleado)
) ENGINE=InnoDB;

-- =====================================================================
--  16. LOTES  (existencias por lote y caducidad; stock NO va aqui)
-- =====================================================================
CREATE TABLE Lotes (
  id_lote         VARCHAR(10) NOT NULL,
  medicamento     VARCHAR(10) NOT NULL              COMMENT 'FK -> Medicamentos',
  codigo_lote     VARCHAR(40) NOT NULL,
  fecha_caducidad DATE        NOT NULL,
  activo          BOOLEAN     NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_lotes PRIMARY KEY (id_lote),
  CONSTRAINT uq_lotes_med_codigo UNIQUE (medicamento, codigo_lote),
  CONSTRAINT fk_lotes_medicamento FOREIGN KEY (medicamento) REFERENCES Medicamentos (id_medicamento)
) ENGINE=InnoDB;

-- =====================================================================
--  17. INVENTARIO  (1:1 con Lotes; el stock vive aqui)
-- =====================================================================
CREATE TABLE Inventario (
  id_inventario              VARCHAR(10)   NOT NULL,
  lote                       VARCHAR(10)   NOT NULL  COMMENT 'FK 1:1 -> Lotes',
  proveedor                  VARCHAR(10)   NULL      COMMENT 'FK -> Proveedores',
  stock_actual               INT           NOT NULL DEFAULT 0,
  stock_reservado            INT           NOT NULL DEFAULT 0,
  stock_danado               INT           NOT NULL DEFAULT 0,
  stock_transito             INT           NOT NULL DEFAULT 0,
  fecha_ultima_reposicion    DATE          NULL,
  cantidad_ultima_reposicion INT           NULL,
  ubicacion_fisica           VARCHAR(60)   NULL,
  costo_unitario             DECIMAL(10,2) NULL,
  fecha_ultimo_conteo        DATE          NULL,
  ultimo_movimiento ENUM('surtido','reposicion','ajuste','merma','vencimiento') NULL
                                                     COMMENT 'enum tipo_movimiento_inventario',
  observaciones              VARCHAR(255)  NULL,
  activo                     BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_inventario PRIMARY KEY (id_inventario),
  CONSTRAINT uq_inventario_lote UNIQUE (lote),
  CONSTRAINT fk_inv_lote      FOREIGN KEY (lote)      REFERENCES Lotes (id_lote),
  CONSTRAINT fk_inv_proveedor FOREIGN KEY (proveedor) REFERENCES Proveedores (id_proveedor)
) ENGINE=InnoDB;

-- =====================================================================
--  18. VENTAS  (surtido de medicamentos; SP2)
-- =====================================================================
CREATE TABLE Ventas (
  id_venta    VARCHAR(10)   NOT NULL,
  empleado    VARCHAR(10)   NOT NULL                 COMMENT 'FK -> Empleados',
  receta      VARCHAR(10)   NULL                     COMMENT 'FK -> Recetas',
  fecha_venta DATETIME      NOT NULL,
  tipo_pago ENUM('efectivo','tarjeta_debito','tarjeta_credito','transferencia')
              NOT NULL                               COMMENT 'enum tipo_pago',
  descuento   DECIMAL(10,2) NOT NULL DEFAULT 0,
  monto_total DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
  CONSTRAINT fk_ventas_empleado FOREIGN KEY (empleado) REFERENCES Empleados (id_empleado),
  CONSTRAINT fk_ventas_receta   FOREIGN KEY (receta)   REFERENCES Recetas (id_receta)
) ENGINE=InnoDB;

-- =====================================================================
--  19. DETALLES_VENTA  (medicamento y lote usados por venta)
-- =====================================================================
CREATE TABLE Detalles_Venta (
  venta           VARCHAR(10)   NOT NULL             COMMENT 'FK -> Ventas',
  medicamento     VARCHAR(10)   NOT NULL             COMMENT 'FK -> Medicamentos',
  lote            VARCHAR(10)   NOT NULL             COMMENT 'FK -> Lotes',
  cantidad        INT           NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal        DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_det_venta PRIMARY KEY (venta, medicamento, lote),
  CONSTRAINT fk_dv_venta       FOREIGN KEY (venta)       REFERENCES Ventas (id_venta),
  CONSTRAINT fk_dv_medicamento FOREIGN KEY (medicamento) REFERENCES Medicamentos (id_medicamento),
  CONSTRAINT fk_dv_lote        FOREIGN KEY (lote)        REFERENCES Lotes (id_lote)
) ENGINE=InnoDB;

-- =====================================================================
--  20. AUDITORIA_INVENTARIO  (tabla LOG; Trigger 2)
-- =====================================================================
CREATE TABLE Auditoria_Inventario (
  id_auditoria     VARCHAR(12) NOT NULL,
  medicamento      VARCHAR(10) NOT NULL              COMMENT 'FK -> Medicamentos',
  lote             VARCHAR(10) NOT NULL              COMMENT 'FK -> Lotes',
  stock_anterior   INT         NOT NULL,
  stock_nuevo      INT         NOT NULL,
  tipo_movimiento ENUM('surtido','reposicion','ajuste','merma','vencimiento')
                   NOT NULL                          COMMENT 'enum tipo_movimiento_inventario',
  fecha_movimiento DATETIME    NOT NULL,
  empleado         VARCHAR(10) NULL                  COMMENT 'FK -> Empleados',
  receta           VARCHAR(10) NULL                  COMMENT 'FK -> Recetas',
  orden_compra     VARCHAR(10) NULL                  COMMENT 'FK -> Ordenes_Compra',
  usuario_proceso  VARCHAR(100) NULL,
  observaciones    VARCHAR(255) NULL,
  CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria),
  CONSTRAINT fk_aud_medicamento  FOREIGN KEY (medicamento)  REFERENCES Medicamentos (id_medicamento),
  CONSTRAINT fk_aud_lote         FOREIGN KEY (lote)         REFERENCES Lotes (id_lote),
  CONSTRAINT fk_aud_empleado     FOREIGN KEY (empleado)     REFERENCES Empleados (id_empleado),
  CONSTRAINT fk_aud_receta       FOREIGN KEY (receta)       REFERENCES Recetas (id_receta),
  CONSTRAINT fk_aud_orden_compra FOREIGN KEY (orden_compra) REFERENCES Ordenes_Compra (id_orden_compra)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
--  FIN DEL DDL  (20 tablas)
-- =====================================================================
