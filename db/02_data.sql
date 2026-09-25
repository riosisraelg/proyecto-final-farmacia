-- =====================================================================
--  SCRIPT DML - MySQL 8.x
--  PROYECTO FINAL - Farmacia con Consultorio Medico  (20 tablas)
--  Inserta 12 registros por tabla (Parte III del avance: minimo 10).
--  Requiere ejecutar antes: farmacia_consultorio_v1.sql
--  Orden de insercion = orden de dependencias de FK.
-- =====================================================================

USE proyecto_final_data_base;

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
--  1. EMPLEADOS
-- ---------------------------------------------------------------------
INSERT INTO Empleados (id_empleado, nombre, apellidos, puesto, telefono, correo, activo, fecha_ingreso) VALUES
 ('EMP-000001','Laura','Mendoza Ruiz','medico','5511000001','laura.mendoza@clinix.mx',TRUE,'2020-01-15'),
 ('EMP-000002','Carlos','Fuentes Alba','medico','5511000002','carlos.fuentes@clinix.mx',TRUE,'2019-03-10'),
 ('EMP-000003','Ana','Torres Lopez','medico','5511000003','ana.torres@clinix.mx',TRUE,'2021-07-01'),
 ('EMP-000004','Miguel','Herrera Cruz','medico','5511000004','miguel.herrera@clinix.mx',TRUE,'2018-11-20'),
 ('EMP-000005','Sofia','Ramirez Diaz','medico','5511000005','sofia.ramirez@clinix.mx',TRUE,'2022-02-14'),
 ('EMP-000006','Jorge','Nunez Vega','medico','5511000006','jorge.nunez@clinix.mx',TRUE,'2020-06-05'),
 ('EMP-000007','Patricia','Salas Mora','farmaceutico','5511000007','patricia.salas@clinix.mx',TRUE,'2021-09-12'),
 ('EMP-000008','Ricardo','Gomez Pena','cajero','5511000008','ricardo.gomez@clinix.mx',TRUE,'2023-01-09'),
 ('EMP-000009','Elena','Castro Rios','cajero','5511000009','elena.castro@clinix.mx',TRUE,'2023-04-18'),
 ('EMP-000010','Fernando','Ortega Lima','admin','5511000010','fernando.ortega@clinix.mx',TRUE,'2017-08-30'),
 ('EMP-000011','Gabriela','Vidal Soto','farmaceutico','5511000011','gabriela.vidal@clinix.mx',TRUE,'2022-10-03'),
 ('EMP-000012','Hector','Luna Parra','almacenista','5511000012','hector.luna@clinix.mx',TRUE,'2021-05-22');

-- ---------------------------------------------------------------------
--  2. MEDICOS  (empleados con puesto medico: EMP-000001..006)
-- ---------------------------------------------------------------------
INSERT INTO Medicos (id_medico, empleado, cedula_profesional, cedula_vigencia, especialidad, activo) VALUES
 ('MDC-000001','EMP-000001','CED1234567','2027-12-31','Medicina General',TRUE),
 ('MDC-000002','EMP-000002','CED2234567','2026-06-30','Pediatria',TRUE),
 ('MDC-000003','EMP-000003','CED3234567','2028-03-15','Cardiologia',TRUE),
 ('MDC-000004','EMP-000004','CED4234567','2027-01-20','Dermatologia',TRUE),
 ('MDC-000005','EMP-000005','CED5234567','2029-05-10','Medicina Interna',TRUE),
 ('MDC-000006','EMP-000006','CED6234567','2026-11-01','Neurologia',TRUE),
 ('MDC-000007','EMP-000007','CED7234567','2028-07-07','Ginecologia',TRUE),
 ('MDC-000008','EMP-000008','CED8234567','2027-09-09','Endocrinologia',TRUE),
 ('MDC-000009','EMP-000009','CED9234567','2026-02-02','Traumatologia',TRUE),
 ('MDC-000010','EMP-000010','CED1034567','2030-04-04','Otorrinolaringologia',TRUE),
 ('MDC-000011','EMP-000011','CED1134567','2028-08-08','Gastroenterologia',TRUE),
 ('MDC-000012','EMP-000012','CED1234568','2029-09-09','Alergologia',TRUE);
-- Nota: para llegar a 12 registros de ejemplo se asigna cedula a todos
-- los empleados; en un caso real solo tendrian cedula los del puesto medico.

-- ---------------------------------------------------------------------
--  3. PACIENTES
-- ---------------------------------------------------------------------
INSERT INTO Pacientes (id_paciente, nombre, apellidos, fecha_nacimiento, telefono, correo, direccion, activo, fecha_registro) VALUES
 ('PAC-000001','Maria','Lopez Garcia','1990-04-12','5522000001','maria.lopez@mail.mx','Av. Reforma 100, CDMX',TRUE,'2024-01-10 09:00:00'),
 ('PAC-000002','Juan','Perez Soto','1985-08-25','5522000002','juan.perez@mail.mx','Calle 5 de Mayo 23, CDMX',TRUE,'2024-01-15 10:30:00'),
 ('PAC-000003','Rosa','Martinez Vela','2000-12-01','5522000003','rosa.martinez@mail.mx','Insurgentes Sur 456, CDMX',TRUE,'2024-02-01 11:15:00'),
 ('PAC-000004','Pedro','Sanchez Rey','1978-06-30','5522000004','pedro.sanchez@mail.mx','Eje Central 789, CDMX',TRUE,'2024-02-20 08:45:00'),
 ('PAC-000005','Lucia','Gomez Nava','1995-03-17','5522000005','lucia.gomez@mail.mx','Calzada Tlalpan 321, CDMX',TRUE,'2024-03-05 14:00:00'),
 ('PAC-000006','Andres','Ruiz Cano','1965-11-09','5522000006','andres.ruiz@mail.mx','Av. Universidad 654, CDMX',TRUE,'2024-03-18 16:20:00'),
 ('PAC-000007','Carmen','Diaz Pena','2010-07-22','5522000007','carmen.diaz@mail.mx','Patriotismo 111, CDMX',TRUE,'2024-04-02 09:30:00'),
 ('PAC-000008','Raul','Flores Mena','1988-02-14','5522000008','raul.flores@mail.mx','Division del Norte 222, CDMX',TRUE,'2024-04-25 12:00:00'),
 ('PAC-000009','Diana','Vargas Rios','1999-09-05','5522000009','diana.vargas@mail.mx','Rio Churubusco 333, CDMX',TRUE,'2024-05-10 10:10:00'),
 ('PAC-000010','Tomas','Aguilar Paz','1972-01-28','5522000010','tomas.aguilar@mail.mx','Calzada de la Viga 444, CDMX',TRUE,'2024-05-30 15:45:00'),
 ('PAC-000011','Beatriz','Campos Leon','2003-05-19','5522000011','beatriz.campos@mail.mx','Av. Coyoacan 555, CDMX',TRUE,'2024-06-12 11:00:00'),
 ('PAC-000012','Oscar','Reyes Solis','1982-10-03','5522000012','oscar.reyes@mail.mx','Miguel Angel 666, CDMX',TRUE,'2024-06-28 13:30:00');

-- ---------------------------------------------------------------------
--  4. HISTORIALES_CLINICOS  (1:1 con pacientes)
-- ---------------------------------------------------------------------
INSERT INTO Historiales_Clinicos (id_historial, paciente, antecedentes, observaciones, fecha_actualizacion) VALUES
 ('HCL-000001','PAC-000001','Hipertension controlada','Sin cirugias previas','2024-06-01 09:00:00'),
 ('HCL-000002','PAC-000002','Diabetes tipo 2','Toma metformina','2024-06-02 09:00:00'),
 ('HCL-000003','PAC-000003','Asma leve','Uso ocasional de inhalador','2024-06-03 09:00:00'),
 ('HCL-000004','PAC-000004','Colesterol alto','Dieta en curso','2024-06-04 09:00:00'),
 ('HCL-000005','PAC-000005','Sin antecedentes relevantes','Paciente sana','2024-06-05 09:00:00'),
 ('HCL-000006','PAC-000006','Gastritis cronica','Evitar irritantes','2024-06-06 09:00:00'),
 ('HCL-000007','PAC-000007','Rinitis alergica','Paciente pediatrico','2024-06-07 09:00:00'),
 ('HCL-000008','PAC-000008','Migrana recurrente','Estudios neurologicos normales','2024-06-08 09:00:00'),
 ('HCL-000009','PAC-000009','Anemia leve','Suplemento de hierro','2024-06-09 09:00:00'),
 ('HCL-000010','PAC-000010','Artritis','Terapia fisica','2024-06-10 09:00:00'),
 ('HCL-000011','PAC-000011','Sin antecedentes','Chequeo anual','2024-06-11 09:00:00'),
 ('HCL-000012','PAC-000012','Reflujo gastroesofagico','Control dietetico','2024-06-12 09:00:00');

-- ---------------------------------------------------------------------
--  5. CONDICIONES_CLINICAS  (alergias y contraindicaciones unificadas)
-- ---------------------------------------------------------------------
INSERT INTO Condiciones_Clinicas (id_condicion, tipo, nombre, descripcion, activa) VALUES
 ('CND-000001','alergia','Penicilina','Alergia a antibioticos betalactamicos',TRUE),
 ('CND-000002','alergia','Aspirina','Alergia a acido acetilsalicilico',TRUE),
 ('CND-000003','alergia','Sulfas','Alergia a sulfonamidas',TRUE),
 ('CND-000004','alergia','Ibuprofeno','Alergia a AINE',TRUE),
 ('CND-000005','alergia','Latex','Alergia por contacto',TRUE),
 ('CND-000006','alergia','Mariscos','Reaccion alimentaria',TRUE),
 ('CND-000007','contraindicacion','Embarazo','No administrar en gestacion',TRUE),
 ('CND-000008','contraindicacion','Lactancia','Precaucion durante lactancia',TRUE),
 ('CND-000009','contraindicacion','Insuficiencia renal','Ajustar dosis',TRUE),
 ('CND-000010','contraindicacion','Insuficiencia hepatica','Contraindicado en dano hepatico',TRUE),
 ('CND-000011','contraindicacion','Ulcera gastrica','Evitar AINE',TRUE),
 ('CND-000012','contraindicacion','Anticoagulados','Riesgo de sangrado',TRUE);

-- ---------------------------------------------------------------------
--  6. HISTORIAL_CONDICION
-- ---------------------------------------------------------------------
INSERT INTO Historial_Condicion (historial, condicion, reaccion, severidad, observaciones, fecha_registro, activa) VALUES
 ('HCL-000001','CND-000001','Urticaria','moderada','Confirmada en 2019','2024-01-10',TRUE),
 ('HCL-000002','CND-000002','Broncoespasmo','severa','Evitar por completo','2024-01-15',TRUE),
 ('HCL-000003','CND-000004','Erupcion cutanea','leve','Tolera dosis bajas','2024-02-01',TRUE),
 ('HCL-000004','CND-000010','Riesgo hepatico',NULL,'Evitar hepatotoxicos','2024-02-20',TRUE),
 ('HCL-000005','CND-000007','Posible embarazo',NULL,'Confirmar antes de recetar','2024-03-05',TRUE),
 ('HCL-000006','CND-000011','Dolor gastrico','moderada','Evitar AINE','2024-03-18',TRUE),
 ('HCL-000007','CND-000006','Angioedema','severa','Reaccion en 2022','2024-04-02',TRUE),
 ('HCL-000008','CND-000003','Prurito','leve',NULL,'2024-04-25',TRUE),
 ('HCL-000009','CND-000009','Funcion renal limitrofe',NULL,'Ajustar dosis','2024-05-10',TRUE),
 ('HCL-000010','CND-000012','Uso de anticoagulante',NULL,'Vigilar sangrado','2024-05-30',TRUE),
 ('HCL-000011','CND-000008','Lactancia',NULL,'Madre lactante','2024-06-11',TRUE),
 ('HCL-000012','CND-000011','Reflujo','leve','Evitar irritantes','2024-06-12',TRUE);

-- ---------------------------------------------------------------------
--  7. DIAGNOSTICOS
-- ---------------------------------------------------------------------
INSERT INTO Diagnosticos (id_diagnostico, nombre, descripcion, activo) VALUES
 ('DIA-000001','Cefalea tensional','Dolor de cabeza por tension',TRUE),
 ('DIA-000002','Diabetes mellitus tipo 2','Trastorno metabolico',TRUE),
 ('DIA-000003','Asma bronquial','Enfermedad respiratoria cronica',TRUE),
 ('DIA-000004','Dislipidemia','Colesterol elevado',TRUE),
 ('DIA-000005','Gastritis','Inflamacion gastrica',TRUE),
 ('DIA-000006','Rinitis alergica','Alergia respiratoria',TRUE),
 ('DIA-000007','Migrana','Cefalea vascular',TRUE),
 ('DIA-000008','Anemia ferropenica','Deficit de hierro',TRUE),
 ('DIA-000009','Artritis','Inflamacion articular',TRUE),
 ('DIA-000010','Reflujo gastroesofagico','ERGE',TRUE),
 ('DIA-000011','Hipertension arterial','Presion elevada',TRUE),
 ('DIA-000012','Faringitis','Infeccion de garganta',TRUE);

-- ---------------------------------------------------------------------
--  8. CONSULTAS  (con FK a diagnostico)
-- ---------------------------------------------------------------------
INSERT INTO Consultas (id_consulta, paciente, medico, diagnostico, fecha, motivo, costo_consulta, tratamiento_indicado, observaciones) VALUES
 ('CON-000001','PAC-000001','MDC-000001','DIA-000001','2024-06-15 09:00:00','Dolor de cabeza persistente',500.00,'Reposo e hidratacion','Presion normal'),
 ('CON-000002','PAC-000002','MDC-000005','DIA-000002','2024-06-15 10:00:00','Control de diabetes',600.00,'Ajuste de metformina','Glucosa 130'),
 ('CON-000003','PAC-000003','MDC-000002','DIA-000003','2024-06-16 11:00:00','Crisis asmatica leve',550.00,'Inhalador broncodilatador','Saturacion 96%'),
 ('CON-000004','PAC-000004','MDC-000003','DIA-000004','2024-06-16 12:00:00','Revision cardiaca',700.00,'Dieta y estatina','ECG normal'),
 ('CON-000005','PAC-000005','MDC-000001','DIA-000011','2024-06-17 09:30:00','Chequeo general',450.00,'Sin tratamiento','Presion limitrofe'),
 ('CON-000006','PAC-000006','MDC-000011','DIA-000005','2024-06-17 13:00:00','Dolor estomacal',500.00,'Antiacido','Gastritis probable'),
 ('CON-000007','PAC-000007','MDC-000002','DIA-000006','2024-06-18 10:00:00','Alergia estacional',400.00,'Antihistaminico','Paciente pediatrico'),
 ('CON-000008','PAC-000008','MDC-000006','DIA-000007','2024-06-18 14:00:00','Migrana',650.00,'Analgesico especifico','Estudios normales'),
 ('CON-000009','PAC-000009','MDC-000008','DIA-000008','2024-06-19 09:00:00','Fatiga y anemia',600.00,'Suplemento de hierro','Hemoglobina baja'),
 ('CON-000010','PAC-000010','MDC-000009','DIA-000009','2024-06-19 11:30:00','Dolor articular',700.00,'Antiinflamatorio','Artritis'),
 ('CON-000011','PAC-000011','MDC-000007','DIA-000011','2024-06-20 10:00:00','Control ginecologico',650.00,'Seguimiento','Sin hallazgos'),
 ('CON-000012','PAC-000012','MDC-000011','DIA-000010','2024-06-20 12:00:00','Reflujo',500.00,'Inhibidor de bomba','Control dietetico');

-- ---------------------------------------------------------------------
--  9. MEDICAMENTOS  (con parametros de reposicion y referencia)
-- ---------------------------------------------------------------------
INSERT INTO Medicamentos (id_medicamento, categoria_medicamento, nombre, principio_activo, nombre_comercial, nombre_generico, presentacion, concentracion, dosis_referencia, duracion_maxima_dias, descripcion, requiere_receta, registro_sanitario, precio_venta, stock_minimo, stock_maximo, punto_reorden, consumo_promedio_mensual, activo) VALUES
 ('MED-000001','analgesico','Paracetamol 500','Paracetamol','Tylenol','Paracetamol','Caja 20 tabletas','500mg','1 tableta c/8h',10,'Analgesico y antipiretico',FALSE,'RS-0001',45.50,50,400,80,90.00,TRUE),
 ('MED-000002','antibiotico','Amoxicilina 500','Amoxicilina','Amoxil','Amoxicilina','Caja 12 capsulas','500mg','1 capsula c/8h',14,'Antibiotico betalactamico',TRUE,'RS-0002',89.00,60,300,90,70.00,TRUE),
 ('MED-000003','antiinflamatorio','Ibuprofeno 400','Ibuprofeno','Advil','Ibuprofeno','Caja 30 tabletas','400mg','1 tableta c/8h',7,'AINE',FALSE,'RS-0003',60.00,40,300,70,80.00,TRUE),
 ('MED-000004','antihistaminico','Loratadina 10','Loratadina','Clarityne','Loratadina','Caja 10 tabletas','10mg','1 tableta c/24h',30,'Antialergico',FALSE,'RS-0004',75.00,50,250,80,60.00,TRUE),
 ('MED-000005','cardiovascular','Losartan 50','Losartan','Cozaar','Losartan','Caja 30 tabletas','50mg','1 tableta c/24h',90,'Antihipertensivo',TRUE,'RS-0005',120.00,60,200,90,50.00,TRUE),
 ('MED-000006','gastrointestinal','Omeprazol 20','Omeprazol','Losec','Omeprazol','Caja 14 capsulas','20mg','1 capsula c/24h',28,'Inhibidor de bomba de protones',FALSE,'RS-0006',95.00,80,200,100,85.00,TRUE),
 ('MED-000007','respiratorio','Salbutamol','Salbutamol','Ventolin','Salbutamol','Inhalador 200 dosis','100mcg','2 inhalaciones c/6h',30,'Broncodilatador',TRUE,'RS-0007',140.00,50,120,70,40.00,TRUE),
 ('MED-000008','antibiotico','Azitromicina 500','Azitromicina','Zithromax','Azitromicina','Caja 3 tabletas','500mg','1 tableta c/24h',3,'Antibiotico macrolido',TRUE,'RS-0008',180.00,50,100,60,35.00,TRUE),
 ('MED-000009','vitamina_suplemento','Sulfato ferroso','Hierro','Fergrad','Sulfato ferroso','Caja 30 tabletas','200mg','1 tableta c/24h',60,'Suplemento de hierro',FALSE,'RS-0009',55.00,40,300,70,60.00,TRUE),
 ('MED-000010','analgesico','Naproxeno 250','Naproxeno','Flanax','Naproxeno','Caja 20 tabletas','250mg','1 tableta c/8h',7,'Analgesico AINE',FALSE,'RS-0010',70.00,40,250,70,70.00,TRUE),
 ('MED-000011','cardiovascular','Atorvastatina 20','Atorvastatina','Lipitor','Atorvastatina','Caja 30 tabletas','20mg','1 tableta c/24h',90,'Reductor de colesterol',TRUE,'RS-0011',150.00,50,200,80,55.00,TRUE),
 ('MED-000012','antiviral','Aciclovir 400','Aciclovir','Zovirax','Aciclovir','Caja 25 tabletas','400mg','1 tableta 5 veces/dia',10,'Antiviral',TRUE,'RS-0012',110.00,30,100,50,25.00,TRUE);

-- ---------------------------------------------------------------------
--  10. MEDICAMENTO_CONDICION  (med <-> alergia/contraindicacion)
-- ---------------------------------------------------------------------
INSERT INTO Medicamento_Condicion (medicamento, condicion, nivel_riesgo, observaciones) VALUES
 ('MED-000002','CND-000001','severa','Amoxicilina es penicilina'),
 ('MED-000003','CND-000004','severa','Ibuprofeno es AINE'),
 ('MED-000010','CND-000004','moderada','Naproxeno es AINE'),
 ('MED-000003','CND-000011','severa','Ibuprofeno agrava ulcera gastrica'),
 ('MED-000010','CND-000011','severa','Naproxeno agrava ulcera gastrica'),
 ('MED-000005','CND-000007','severa','Losartan contraindicado en embarazo'),
 ('MED-000011','CND-000010','severa','Atorvastatina en dano hepatico'),
 ('MED-000012','CND-000009','moderada','Aciclovir ajustar en falla renal'),
 ('MED-000006','CND-000010','moderada','Omeprazol en insuficiencia hepatica'),
 ('MED-000002','CND-000008','moderada','Precaucion durante lactancia'),
 ('MED-000010','CND-000012','severa','Naproxeno en anticoagulados: riesgo de sangrado'),
 ('MED-000008','CND-000003','leve','Precaucion en alergia a sulfas');

-- ---------------------------------------------------------------------
--  11. INTERACCIONES_MEDICAMENTOSAS
-- ---------------------------------------------------------------------
INSERT INTO Interacciones_Medicamentosas (id_interaccion, medicamento_a, medicamento_b, nivel_riesgo, efecto, recomendacion, activa) VALUES
 ('ITX-000001','MED-000003','MED-000010','severa','Doble AINE aumenta riesgo de sangrado gastrico','Evitar uso conjunto',TRUE),
 ('ITX-000002','MED-000003','MED-000005','moderada','Ibuprofeno reduce efecto antihipertensivo del losartan','Monitorear presion',TRUE),
 ('ITX-000003','MED-000010','MED-000005','moderada','Naproxeno reduce efecto del losartan','Monitorear presion',TRUE),
 ('ITX-000004','MED-000002','MED-000008','leve','Dos antibioticos pueden alterar flora','Valorar necesidad',TRUE),
 ('ITX-000005','MED-000005','MED-000011','leve','Vigilar funcion hepatica y renal','Monitoreo periodico',TRUE),
 ('ITX-000006','MED-000006','MED-000002','moderada','Omeprazol altera absorcion de amoxicilina','Separar las tomas',TRUE),
 ('ITX-000007','MED-000003','MED-000011','moderada','Riesgo hepatico combinado','Monitorear enzimas hepaticas',TRUE),
 ('ITX-000008','MED-000001','MED-000010','leve','Uso conjunto de analgesicos','Vigilar dosis total',TRUE),
 ('ITX-000009','MED-000007','MED-000005','leve','Efectos cardiovasculares opuestos','Monitorear frecuencia cardiaca',TRUE),
 ('ITX-000010','MED-000012','MED-000009','leve','Sin interaccion relevante, registro preventivo','Uso normal',TRUE),
 ('ITX-000011','MED-000004','MED-000006','leve','Sin interaccion significativa','Uso normal',TRUE),
 ('ITX-000012','MED-000008','MED-000011','moderada','Azitromicina con estatina: riesgo de miopatia','Vigilar dolor muscular',TRUE);

-- ---------------------------------------------------------------------
--  12. RECETAS
-- ---------------------------------------------------------------------
INSERT INTO Recetas (id_receta, consulta, folio, fecha_emision, fecha_vencimiento, estado, lugar_emision, diagnostico_texto, indicaciones, observaciones) VALUES
 ('REC-000001','CON-000001','RX-2024-000001-CDMX','2024-06-15 09:30:00','2024-07-15','surtida_total','Consultorio Central CDMX','Cefalea tensional','Tomar con alimentos','Reposo'),
 ('REC-000002','CON-000002','RX-2024-000002-CDMX','2024-06-15 10:30:00','2024-07-15','surtida_total','Consultorio Central CDMX','Diabetes tipo 2','Control de glucosa diario','Dieta baja en azucar'),
 ('REC-000003','CON-000003','RX-2024-000003-CDMX','2024-06-16 11:30:00','2024-07-16','surtida_total','Consultorio Central CDMX','Asma','Usar inhalador en crisis','Evitar alergenos'),
 ('REC-000004','CON-000004','RX-2024-000004-CDMX','2024-06-16 12:30:00','2024-07-16','emitida','Consultorio Central CDMX','Dislipidemia','Tomar en la noche','Dieta'),
 ('REC-000005','CON-000005','RX-2024-000005-CDMX','2024-06-17 10:00:00','2024-07-17','emitida','Consultorio Central CDMX','Chequeo','Hidratacion','Sin medicamento fuerte'),
 ('REC-000006','CON-000006','RX-2024-000006-CDMX','2024-06-17 13:30:00','2024-07-17','surtida_total','Consultorio Central CDMX','Gastritis','Antes del desayuno','Evitar irritantes'),
 ('REC-000007','CON-000007','RX-2024-000007-CDMX','2024-06-18 10:30:00','2024-07-18','surtida_total','Consultorio Central CDMX','Rinitis','Una vez al dia','Paciente pediatrico'),
 ('REC-000008','CON-000008','RX-2024-000008-CDMX','2024-06-18 14:30:00','2024-07-18','surtida_parcial','Consultorio Central CDMX','Migrana','En crisis','Evitar opioides'),
 ('REC-000009','CON-000009','RX-2024-000009-CDMX','2024-06-19 09:30:00','2024-07-19','surtida_total','Consultorio Central CDMX','Anemia','Con vitamina C','Control mensual'),
 ('REC-000010','CON-000010','RX-2024-000010-CDMX','2024-06-19 12:00:00','2024-07-19','emitida','Consultorio Central CDMX','Artritis','Con alimentos','Terapia fisica'),
 ('REC-000011','CON-000011','RX-2024-000011-CDMX','2024-06-20 10:30:00','2024-07-20','emitida','Consultorio Central CDMX','Control','Seguimiento','Sin hallazgos'),
 ('REC-000012','CON-000012','RX-2024-000012-CDMX','2024-06-20 12:30:00','2024-07-20','surtida_total','Consultorio Central CDMX','Reflujo','En ayunas','Control dietetico');

-- ---------------------------------------------------------------------
--  13. DETALLES_RECETA
-- ---------------------------------------------------------------------
INSERT INTO Detalles_Receta (receta, medicamento, dosis, frecuencia, duracion, cantidad_prescrita, via_administracion, instrucciones_especificas, observaciones) VALUES
 ('REC-000001','MED-000001','1 tableta','Cada 8 horas','5 dias',15,'oral','Tomar con agua','Si persiste, volver'),
 ('REC-000002','MED-000005','1 tableta','Cada 24 horas','30 dias',30,'oral','Por la manana','Medir presion'),
 ('REC-000003','MED-000007','2 inhalaciones','Cada 6 horas','En crisis',1,'inhalada','Agitar antes de usar','Vigilar saturacion'),
 ('REC-000004','MED-000011','1 tableta','Cada 24 horas','30 dias',30,'oral','Por la noche','Control de colesterol'),
 ('REC-000005','MED-000001','1 tableta','Cada 12 horas','3 dias',6,'oral','Solo si hay dolor','Uso ocasional'),
 ('REC-000006','MED-000006','1 capsula','Cada 24 horas','14 dias',14,'oral','Antes del desayuno','ERGE'),
 ('REC-000007','MED-000004','1 tableta','Cada 24 horas','10 dias',10,'oral','Dosis pediatrica','Alergia estacional'),
 ('REC-000008','MED-000010','1 tableta','Cada 8 horas','5 dias',15,'oral','Con alimentos','Migrana'),
 ('REC-000009','MED-000009','1 tableta','Cada 24 horas','60 dias',60,'oral','Con jugo de naranja','Anemia'),
 ('REC-000010','MED-000003','1 tableta','Cada 8 horas','7 dias',21,'oral','Con alimentos','Artritis'),
 ('REC-000011','MED-000001','1 tableta','Cada 8 horas','3 dias',9,'oral','Solo si hay dolor','Control'),
 ('REC-000012','MED-000006','1 capsula','Cada 24 horas','21 dias',21,'oral','En ayunas','Reflujo');

-- ---------------------------------------------------------------------
--  14. PROVEEDORES
-- ---------------------------------------------------------------------
INSERT INTO Proveedores (id_proveedor, nombre_comercial, telefono, correo, tiempo_entrega_dias, activo) VALUES
 ('PRV-000001','Farmaceutica Nacional','5533000001','ventas@farmanal.mx',3,TRUE),
 ('PRV-000002','Distribuidora MediMax','5533000002','contacto@medimax.mx',5,TRUE),
 ('PRV-000003','Laboratorios Vida','5533000003','pedidos@labvida.mx',4,TRUE),
 ('PRV-000004','Grupo Salud Total','5533000004','compras@saludtotal.mx',2,TRUE),
 ('PRV-000005','Proveedora Central','5533000005','info@provcentral.mx',6,TRUE),
 ('PRV-000006','BioPharma SA','5533000006','ventas@biopharma.mx',3,TRUE),
 ('PRV-000007','MediSurte','5533000007','atencion@medisurte.mx',4,TRUE),
 ('PRV-000008','Insumos Clinicos','5533000008','insumos@clinicos.mx',5,TRUE),
 ('PRV-000009','Distribuidora del Centro','5533000009','centro@distri.mx',3,TRUE),
 ('PRV-000010','FarmaExpress','5533000010','express@farma.mx',2,TRUE),
 ('PRV-000011','Laboratorio Andino','5533000011','andino@lab.mx',7,TRUE),
 ('PRV-000012','Quimica Medica','5533000012','quimica@medica.mx',4,TRUE);

-- ---------------------------------------------------------------------
--  15. ORDENES_COMPRA  (por medicamento)
-- ---------------------------------------------------------------------
INSERT INTO Ordenes_Compra (id_orden_compra, proveedor, medicamento, empleado, cantidad_solicitada, costo_unitario, fecha_generacion, fecha_estimada_entrega, estado, generada_automatica, observaciones) VALUES
 ('ORD-000001','PRV-000001','MED-000001','EMP-000012',200,25.00,'2024-06-01 08:00:00','2024-06-04','recibida_total',FALSE,'Reposicion paracetamol'),
 ('ORD-000002','PRV-000012','MED-000002','EMP-000012',100,50.00,'2024-06-02 08:00:00','2024-06-06','recibida_total',TRUE,'Stock bajo amoxicilina'),
 ('ORD-000003','PRV-000002','MED-000005','EMP-000010',80,70.00,'2024-06-03 08:00:00','2024-06-08','enviada',FALSE,'Losartan'),
 ('ORD-000004','PRV-000004','MED-000006','EMP-000012',60,55.00,'2024-06-04 08:00:00','2024-06-06','recibida_total',TRUE,'Omeprazol critico'),
 ('ORD-000005','PRV-000003','MED-000007','EMP-000010',40,90.00,'2024-06-05 08:00:00','2024-06-09','pendiente',TRUE,'Salbutamol'),
 ('ORD-000006','PRV-000006','MED-000009','EMP-000012',150,30.00,'2024-06-06 08:00:00','2024-06-09','recibida_parcial',FALSE,'Hierro'),
 ('ORD-000007','PRV-000007','MED-000004','EMP-000010',120,40.00,'2024-06-07 08:00:00','2024-06-11','enviada',TRUE,'Loratadina'),
 ('ORD-000008','PRV-000005','MED-000012','EMP-000012',50,65.00,'2024-06-08 08:00:00','2024-06-14','pendiente',TRUE,'Aciclovir'),
 ('ORD-000009','PRV-000009','MED-000010','EMP-000010',100,38.00,'2024-06-09 08:00:00','2024-06-12','recibida_total',FALSE,'Naproxeno'),
 ('ORD-000010','PRV-000011','MED-000011','EMP-000012',70,95.00,'2024-06-10 08:00:00','2024-06-17','pendiente',TRUE,'Atorvastatina'),
 ('ORD-000011','PRV-000001','MED-000003','EMP-000010',90,30.00,'2024-06-11 08:00:00','2024-06-14','recibida_total',FALSE,'Ibuprofeno'),
 ('ORD-000012','PRV-000012','MED-000008','EMP-000012',30,110.00,'2024-06-12 08:00:00','2024-06-16','enviada',TRUE,'Azitromicina');

-- ---------------------------------------------------------------------
--  16. LOTES  (uno por medicamento)
-- ---------------------------------------------------------------------
INSERT INTO Lotes (id_lote, medicamento, codigo_lote, fecha_caducidad, activo) VALUES
 ('LOT-000001','MED-000001','L-PAR-2401','2026-05-31',TRUE),
 ('LOT-000002','MED-000002','L-AMO-2402','2025-11-30',TRUE),
 ('LOT-000003','MED-000003','L-IBU-2403','2026-03-31',TRUE),
 ('LOT-000004','MED-000004','L-LOR-2404','2027-01-31',TRUE),
 ('LOT-000005','MED-000005','L-LOS-2405','2026-08-31',TRUE),
 ('LOT-000006','MED-000006','L-OME-2406','2025-12-31',TRUE),
 ('LOT-000007','MED-000007','L-SAL-2407','2026-06-30',TRUE),
 ('LOT-000008','MED-000008','L-AZI-2408','2025-10-31',TRUE),
 ('LOT-000009','MED-000009','L-FER-2409','2027-02-28',TRUE),
 ('LOT-000010','MED-000010','L-NAP-2410','2026-04-30',TRUE),
 ('LOT-000011','MED-000011','L-ATO-2411','2026-09-30',TRUE),
 ('LOT-000012','MED-000012','L-ACI-2412','2026-07-31',TRUE);

-- ---------------------------------------------------------------------
--  17. INVENTARIO  (1:1 con Lotes; el stock vive aqui)
-- ---------------------------------------------------------------------
INSERT INTO Inventario (id_inventario, lote, proveedor, stock_actual, stock_reservado, stock_danado, stock_transito, fecha_ultima_reposicion, cantidad_ultima_reposicion, ubicacion_fisica, costo_unitario, fecha_ultimo_conteo, ultimo_movimiento, observaciones, activo) VALUES
 ('INV-000001','LOT-000001','PRV-000001',300,10,0,0,'2024-06-04',200,'Anaquel A1',25.00,'2024-06-14','reposicion','OK',TRUE),
 ('INV-000002','LOT-000002','PRV-000012',150,5,0,0,'2024-06-06',100,'Anaquel A2',50.00,'2024-06-14','reposicion','OK',TRUE),
 ('INV-000003','LOT-000003','PRV-000001',200,0,5,0,'2024-06-13',90,'Anaquel A3',30.00,'2024-06-14','reposicion','OK',TRUE),
 ('INV-000004','LOT-000004','PRV-000007',180,0,0,0,'2024-06-11',120,'Anaquel B1',40.00,'2024-06-14','surtido','OK',TRUE),
 ('INV-000005','LOT-000005','PRV-000002',120,10,0,0,'2024-06-08',80,'Anaquel B2',70.00,'2024-06-14','surtido','OK',TRUE),
 ('INV-000006','LOT-000006','PRV-000004',90,0,0,0,'2024-06-06',60,'Anaquel B3',55.00,'2024-06-14','surtido','Reponer pronto',TRUE),
 ('INV-000007','LOT-000007','PRV-000003',60,5,0,40,'2024-06-09',40,'Anaquel C1',90.00,'2024-06-14','surtido','En transito',TRUE),
 ('INV-000008','LOT-000008','PRV-000012',40,0,5,30,'2024-06-16',30,'Anaquel C2',110.00,'2024-06-14','merma','Stock critico',TRUE),
 ('INV-000009','LOT-000009','PRV-000006',220,0,0,0,'2024-06-09',150,'Anaquel C3',30.00,'2024-06-14','surtido','OK',TRUE),
 ('INV-000010','LOT-000010','PRV-000009',160,0,0,0,'2024-06-12',100,'Anaquel D1',38.00,'2024-06-14','surtido','OK',TRUE),
 ('INV-000011','LOT-000011','PRV-000011',110,0,0,70,'2024-06-17',70,'Anaquel D2',95.00,'2024-06-14','reposicion','Pedido en transito',TRUE),
 ('INV-000012','LOT-000012','PRV-000005',0,0,0,50,'2024-06-14',0,'Anaquel D3',65.00,'2024-06-14','vencimiento','Agotado, orden pendiente',TRUE);

-- ---------------------------------------------------------------------
--  18. VENTAS  (asociadas a recetas surtidas y ventas libres)
-- ---------------------------------------------------------------------
INSERT INTO Ventas (id_venta, empleado, receta, fecha_venta, tipo_pago, descuento, monto_total) VALUES
 ('VEN-000001','EMP-000007','REC-000001','2024-06-15 11:00:00','efectivo',0.00,45.50),
 ('VEN-000002','EMP-000011','REC-000002','2024-06-15 11:30:00','tarjeta_credito',0.00,120.00),
 ('VEN-000003','EMP-000007','REC-000003','2024-06-16 12:00:00','tarjeta_debito',0.00,140.00),
 ('VEN-000004','EMP-000011','REC-000006','2024-06-17 14:00:00','efectivo',5.00,90.00),
 ('VEN-000005','EMP-000007','REC-000007','2024-06-18 11:00:00','efectivo',0.00,75.00),
 ('VEN-000006','EMP-000011','REC-000008','2024-06-18 15:00:00','transferencia',0.00,70.00),
 ('VEN-000007','EMP-000007','REC-000009','2024-06-19 10:00:00','tarjeta_debito',0.00,55.00),
 ('VEN-000008','EMP-000011','REC-000012','2024-06-20 13:00:00','efectivo',0.00,95.00),
 ('VEN-000009','EMP-000009',NULL,'2024-06-20 16:00:00','efectivo',0.00,60.00),
 ('VEN-000010','EMP-000008',NULL,'2024-06-21 09:00:00','tarjeta_credito',0.00,70.00),
 ('VEN-000011','EMP-000009',NULL,'2024-06-21 10:30:00','efectivo',0.00,45.50),
 ('VEN-000012','EMP-000008',NULL,'2024-06-21 12:00:00','tarjeta_debito',10.00,140.00);

-- ---------------------------------------------------------------------
--  19. DETALLES_VENTA  (PK: venta + medicamento + lote)
-- ---------------------------------------------------------------------
INSERT INTO Detalles_Venta (venta, medicamento, lote, cantidad, precio_unitario, subtotal) VALUES
 ('VEN-000001','MED-000001','LOT-000001',1,45.50,45.50),
 ('VEN-000002','MED-000005','LOT-000005',1,120.00,120.00),
 ('VEN-000003','MED-000007','LOT-000007',1,140.00,140.00),
 ('VEN-000004','MED-000006','LOT-000006',1,95.00,95.00),
 ('VEN-000005','MED-000004','LOT-000004',1,75.00,75.00),
 ('VEN-000006','MED-000010','LOT-000010',1,70.00,70.00),
 ('VEN-000007','MED-000009','LOT-000009',1,55.00,55.00),
 ('VEN-000008','MED-000006','LOT-000006',1,95.00,95.00),
 ('VEN-000009','MED-000003','LOT-000003',1,60.00,60.00),
 ('VEN-000010','MED-000010','LOT-000010',1,70.00,70.00),
 ('VEN-000011','MED-000001','LOT-000001',1,45.50,45.50),
 ('VEN-000012','MED-000011','LOT-000011',1,150.00,150.00);

-- ---------------------------------------------------------------------
--  20. AUDITORIA_INVENTARIO  (tabla LOG)
-- ---------------------------------------------------------------------
INSERT INTO Auditoria_Inventario (id_auditoria, medicamento, lote, stock_anterior, stock_nuevo, tipo_movimiento, fecha_movimiento, empleado, receta, orden_compra, usuario_proceso, observaciones) VALUES
 ('AUD-000001','MED-000001','LOT-000001',101,301,'reposicion','2024-06-04 10:05:00','EMP-000012',NULL,'ORD-000001','sp_reposicion','Ingreso por orden'),
 ('AUD-000002','MED-000001','LOT-000001',301,300,'surtido','2024-06-15 11:00:00','EMP-000007','REC-000001',NULL,'sp_surtir','Venta VEN-000001'),
 ('AUD-000003','MED-000005','LOT-000005',121,120,'surtido','2024-06-15 11:30:00','EMP-000011','REC-000002',NULL,'sp_surtir','Venta VEN-000002'),
 ('AUD-000004','MED-000007','LOT-000007',61,60,'surtido','2024-06-16 12:00:00','EMP-000007','REC-000003',NULL,'sp_surtir','Venta VEN-000003'),
 ('AUD-000005','MED-000006','LOT-000006',91,90,'surtido','2024-06-17 14:00:00','EMP-000011','REC-000006',NULL,'sp_surtir','Venta VEN-000004'),
 ('AUD-000006','MED-000004','LOT-000004',181,180,'surtido','2024-06-18 11:00:00','EMP-000007','REC-000007',NULL,'sp_surtir','Venta VEN-000005'),
 ('AUD-000007','MED-000009','LOT-000009',221,220,'surtido','2024-06-19 10:00:00','EMP-000011','REC-000009',NULL,'sp_surtir','Venta VEN-000007'),
 ('AUD-000008','MED-000008','LOT-000008',45,40,'merma','2024-06-16 09:00:00','EMP-000012',NULL,NULL,'ajuste_manual','Producto danado'),
 ('AUD-000009','MED-000012','LOT-000012',50,0,'vencimiento','2024-06-14 08:00:00','EMP-000012',NULL,NULL,'proceso_caducidad','Lote vencido retirado'),
 ('AUD-000010','MED-000002','LOT-000002',50,150,'reposicion','2024-06-06 10:05:00','EMP-000012',NULL,'ORD-000002','sp_reposicion','Ingreso por orden'),
 ('AUD-000011','MED-000010','LOT-000010',161,160,'surtido','2024-06-21 10:30:00','EMP-000009',NULL,NULL,'sp_surtir','Venta libre VEN-000010'),
 ('AUD-000012','MED-000003','LOT-000003',110,109,'ajuste','2024-06-14 08:30:00','EMP-000012',NULL,NULL,'conteo_fisico','Ajuste por conteo fisico');

-- =====================================================================
-- =====================================================================
--  DATOS ADICIONALES REALISTAS
--  Agregados segun GUIDELINES_DATOS.md (basado en Instrucciones 2:
--  Vistas 1/2/3, SP1/SP2/SP3 y Triggers 1/2).
--  Objetivo: que las vistas y reportes devuelvan resultados con sentido
--  y existan casos de prueba para los SP/Triggers.
-- =====================================================================
-- =====================================================================

-- ---------------------------------------------------------------------
--  EMPLEADOS adicionales (mas medicos y personal; 1 medico con cedula
--  vencida se define abajo, 1 empleado inactivo).
-- ---------------------------------------------------------------------
INSERT INTO Empleados (id_empleado, nombre, apellidos, puesto, telefono, correo, activo, fecha_ingreso) VALUES
 ('EMP-000013','Valeria','Cordova Islas','medico','5511000013','valeria.cordova@clinix.mx',TRUE,'2019-05-02'),
 ('EMP-000014','Rodrigo','Beltran Cortez','medico','5511000014','rodrigo.beltran@clinix.mx',TRUE,'2021-02-11'),
 ('EMP-000015','Monica','Estrada Pineda','medico','5511000015','monica.estrada@clinix.mx',TRUE,'2016-09-19'),
 ('EMP-000016','Alberto','Cabrera Rojas','farmaceutico','5511000016','alberto.cabrera@clinix.mx',TRUE,'2022-03-08'),
 ('EMP-000017','Nadia','Ponce Miranda','cajero','5511000017','nadia.ponce@clinix.mx',TRUE,'2023-06-14'),
 ('EMP-000018','Sergio','Villalobos Cano','almacenista','5511000018','sergio.villalobos@clinix.mx',FALSE,'2018-01-30');

-- ---------------------------------------------------------------------
--  MEDICOS adicionales.
--  MDC-000015 tiene CEDULA VENCIDA -> caso de rechazo del SP1/Trigger1.
-- ---------------------------------------------------------------------
INSERT INTO Medicos (id_medico, empleado, cedula_profesional, cedula_vigencia, especialidad, activo) VALUES
 ('MDC-000013','EMP-000013','CED1334567','2028-12-31','Medicina General',TRUE),
 ('MDC-000014','EMP-000014','CED1434567','2027-10-10','Pediatria',TRUE),
 ('MDC-000015','EMP-000015','CED1534567','2023-01-31','Cardiologia',TRUE);  -- CEDULA VENCIDA (caso de prueba)

-- ---------------------------------------------------------------------
--  PACIENTES adicionales.  PAC-000015 esta INACTIVO -> caso SP1.
-- ---------------------------------------------------------------------
INSERT INTO Pacientes (id_paciente, nombre, apellidos, fecha_nacimiento, telefono, correo, direccion, activo, fecha_registro) VALUES
 ('PAC-000013','Ignacio','Salgado Mora','1993-07-11','5522000013','ignacio.salgado@mail.mx','Av. Patriotismo 900, CDMX',TRUE,'2024-02-05 10:00:00'),
 ('PAC-000014','Fernanda','Rivas Lara','2001-11-23','5522000014','fernanda.rivas@mail.mx','Calz. de Tlalpan 1200, CDMX',TRUE,'2024-02-19 09:15:00'),
 ('PAC-000015','Hugo','Mena Trejo','1959-03-08','5522000015','hugo.mena@mail.mx','Eje 3 Sur 45, CDMX',FALSE,'2023-12-01 08:30:00'),  -- INACTIVO (caso de prueba)
 ('PAC-000016','Paola','Guerrero Nieto','1997-06-16','5522000016','paola.guerrero@mail.mx','Av. Cuauhtemoc 77, CDMX',TRUE,'2024-03-22 11:45:00'),
 ('PAC-000017','Emilio','Zamora Fuentes','1980-09-27','5522000017','emilio.zamora@mail.mx','Calle Gabriel Mancera 55, CDMX',TRUE,'2024-04-14 12:30:00'),
 ('PAC-000018','Renata','Cervantes Ojeda','2012-01-05','5522000018','renata.cervantes@mail.mx','Av. Coyoacan 800, CDMX',TRUE,'2024-05-03 09:00:00');

-- ---------------------------------------------------------------------
--  HISTORIALES_CLINICOS de los pacientes adicionales (1:1).
-- ---------------------------------------------------------------------
INSERT INTO Historiales_Clinicos (id_historial, paciente, antecedentes, observaciones, fecha_actualizacion) VALUES
 ('HCL-000013','PAC-000013','Sin antecedentes cronicos','Deportista','2024-06-13 09:00:00'),
 ('HCL-000014','PAC-000014','Rinitis alergica','Alergia al polen','2024-06-14 09:00:00'),
 ('HCL-000015','PAC-000015','Hipertension y diabetes','Paciente adulto mayor','2024-06-15 09:00:00'),
 ('HCL-000016','PAC-000016','Gastritis ocasional','Estres laboral','2024-06-16 09:00:00'),
 ('HCL-000017','PAC-000017','Colesterol elevado','Sedentario','2024-06-17 09:00:00'),
 ('HCL-000018','PAC-000018','Asma infantil','Paciente pediatrico','2024-06-18 09:00:00');

-- ---------------------------------------------------------------------
--  HISTORIAL_CONDICION adicionales (alergias/contraindicaciones que
--  chocan con medicamentos -> alimentan Vista 1 y validaciones SP1).
-- ---------------------------------------------------------------------
INSERT INTO Historial_Condicion (historial, condicion, reaccion, severidad, observaciones, fecha_registro, activa) VALUES
 ('HCL-000013','CND-000005','Dermatitis','leve','Alergia al latex','2024-02-05',TRUE),
 ('HCL-000014','CND-000002','Broncoespasmo','severa','No administrar aspirina','2024-02-19',TRUE),
 ('HCL-000015','CND-000009','Creatinina elevada',NULL,'Ajustar dosis renales','2023-12-01',TRUE),
 ('HCL-000015','CND-000001','Urticaria','severa','Alergia a penicilina confirmada','2023-12-01',TRUE),
 ('HCL-000016','CND-000011','Dolor epigastrico','moderada','Evitar AINE','2024-03-22',TRUE),
 ('HCL-000017','CND-000010','Transaminasas altas',NULL,'Vigilar higado','2024-04-14',TRUE),
 ('HCL-000018','CND-000004','Erupcion','moderada','Alergia a ibuprofeno','2024-05-03',TRUE);

-- ---------------------------------------------------------------------
--  DIAGNOSTICOS adicionales.
-- ---------------------------------------------------------------------
INSERT INTO Diagnosticos (id_diagnostico, nombre, descripcion, activo) VALUES
 ('DIA-000013','Infeccion respiratoria aguda','Cuadro viral de vias altas',TRUE),
 ('DIA-000014','Lumbalgia','Dolor lumbar mecanico',TRUE),
 ('DIA-000015','Conjuntivitis alergica','Inflamacion ocular por alergia',TRUE);

-- ---------------------------------------------------------------------
--  MEDICAMENTOS adicionales.  MED-000014 esta INACTIVO -> caso SP1/SP3.
--  Se agregan estados de stock variados via su inventario mas abajo.
-- ---------------------------------------------------------------------
INSERT INTO Medicamentos (id_medicamento, categoria_medicamento, nombre, principio_activo, nombre_comercial, nombre_generico, presentacion, concentracion, dosis_referencia, duracion_maxima_dias, descripcion, requiere_receta, registro_sanitario, precio_venta, stock_minimo, stock_maximo, punto_reorden, consumo_promedio_mensual, activo) VALUES
 ('MED-000013','antibiotico','Ciprofloxacino 500','Ciprofloxacino','Ciproxina','Ciprofloxacino','Caja 14 tabletas','500mg','1 tableta c/12h',10,'Antibiotico quinolona',TRUE,'RS-0013',130.00,40,150,60,45.00,TRUE),
 ('MED-000014','dermatologico','Hidrocortisona crema','Hidrocortisona','Cortiderm','Hidrocortisona','Tubo 30g','1%','Aplicar 2 veces/dia',15,'Corticoide topico (DESCONTINUADO)',FALSE,'RS-0014',85.00,20,80,30,10.00,FALSE),  -- INACTIVO
 ('MED-000015','antifungico','Fluconazol 150','Fluconazol','Diflucan','Fluconazol','Caja 1 capsula','150mg','1 capsula dosis unica',1,'Antifungico',TRUE,'RS-0015',95.00,25,100,40,20.00,TRUE),
 ('MED-000016','respiratorio','Ambroxol jarabe','Ambroxol','Mucosolvan','Ambroxol','Frasco 120ml','15mg/5ml','10ml c/8h',7,'Mucolitico',FALSE,'RS-0016',65.00,50,200,80,70.00,TRUE),
 ('MED-000017','antihistaminico','Olopatadina gotas','Olopatadina','Patanol','Olopatadina','Frasco 5ml','0.1%','1 gota c/12h',30,'Antihistaminico oftalmico',TRUE,'RS-0017',180.00,15,60,25,15.00,TRUE),
 ('MED-000018','analgesico','Ketorolaco 10','Ketorolaco','Dolac','Ketorolaco','Caja 10 tabletas','10mg','1 tableta c/8h',5,'Analgesico potente',TRUE,'RS-0018',90.00,30,120,50,60.00,TRUE);

-- ---------------------------------------------------------------------
--  MEDICAMENTO_CONDICION adicionales (nuevos medicamentos).
-- ---------------------------------------------------------------------
INSERT INTO Medicamento_Condicion (medicamento, condicion, nivel_riesgo, observaciones) VALUES
 ('MED-000013','CND-000009','moderada','Ciprofloxacino ajustar en falla renal'),
 ('MED-000015','CND-000010','moderada','Fluconazol hepatotoxico'),
 ('MED-000018','CND-000011','severa','Ketorolaco contraindicado en ulcera'),
 ('MED-000018','CND-000012','severa','Ketorolaco en anticoagulados'),
 ('MED-000016','CND-000008','leve','Ambroxol precaucion en lactancia'),
 ('MED-000017','CND-000007','leve','Olopatadina precaucion en embarazo');

-- ---------------------------------------------------------------------
--  INTERACCIONES_MEDICAMENTOSAS adicionales.
-- ---------------------------------------------------------------------
INSERT INTO Interacciones_Medicamentosas (id_interaccion, medicamento_a, medicamento_b, nivel_riesgo, efecto, recomendacion, activa) VALUES
 ('ITX-000013','MED-000018','MED-000003','severa','Doble AINE, alto riesgo de sangrado','Evitar uso conjunto',TRUE),
 ('ITX-000014','MED-000018','MED-000010','severa','Doble AINE, riesgo gastrico','Evitar uso conjunto',TRUE),
 ('ITX-000015','MED-000013','MED-000011','moderada','Ciprofloxacino aumenta efecto de estatina','Vigilar miopatia',TRUE),
 ('ITX-000016','MED-000015','MED-000011','moderada','Fluconazol eleva niveles de atorvastatina','Reducir dosis',TRUE),
 ('ITX-000017','MED-000013','MED-000006','leve','Omeprazol reduce absorcion de ciprofloxacino','Separar tomas',TRUE);

-- ---------------------------------------------------------------------
--  LOTES adicionales: MULTIPLES lotes por medicamento y 1 VENCIDO.
--  (Vista 2: vencimiento mas proximo; SP2: lote vencido rechazado.)
-- ---------------------------------------------------------------------
INSERT INTO Lotes (id_lote, medicamento, codigo_lote, fecha_caducidad, activo) VALUES
 ('LOT-000013','MED-000001','L-PAR-2405','2025-02-28',TRUE),   -- segundo lote de paracetamol (caduca antes)
 ('LOT-000014','MED-000002','L-AMO-2320','2024-05-31',TRUE),   -- LOTE VENCIDO (antes de la fecha de operacion)
 ('LOT-000015','MED-000006','L-OME-2501','2026-10-31',TRUE),   -- segundo lote de omeprazol
 ('LOT-000016','MED-000013','L-CIP-2410','2026-01-31',TRUE),
 ('LOT-000017','MED-000015','L-FLU-2411','2026-03-31',TRUE),
 ('LOT-000018','MED-000016','L-AMB-2412','2026-05-31',TRUE),
 ('LOT-000019','MED-000017','L-OLO-2501','2027-01-31',TRUE),
 ('LOT-000020','MED-000018','L-KET-2409','2025-09-30',TRUE);

-- ---------------------------------------------------------------------
--  INVENTARIO adicionales (1:1 con los lotes nuevos).
--  Se cubren los 4 estados de abastecimiento de la Vista 2:
--    suficiente / bajo / critico / agotado.
-- ---------------------------------------------------------------------
INSERT INTO Inventario (id_inventario, lote, proveedor, stock_actual, stock_reservado, stock_danado, stock_transito, fecha_ultima_reposicion, cantidad_ultima_reposicion, ubicacion_fisica, costo_unitario, fecha_ultimo_conteo, ultimo_movimiento, observaciones, activo) VALUES
 ('INV-000013','LOT-000013','PRV-000001',80,0,0,0,'2024-05-20',80,'Anaquel A1',25.00,'2024-06-14','reposicion','Lote secundario paracetamol',TRUE),
 ('INV-000014','LOT-000014','PRV-000012',0,0,0,0,'2024-01-10',0,'Cuarentena',50.00,'2024-06-14','vencimiento','Lote vencido, no dispensar',TRUE),
 ('INV-000015','LOT-000015','PRV-000004',150,0,0,0,'2024-06-01',150,'Anaquel B3',55.00,'2024-06-14','reposicion','Lote nuevo omeprazol',TRUE),
 ('INV-000016','LOT-000016','PRV-000012',35,0,0,0,'2024-06-05',60,'Anaquel E1',65.00,'2024-06-14','surtido','critico: <= stock_minimo(40)',TRUE),  -- CRITICO
 ('INV-000017','LOT-000017','PRV-000005',60,0,0,0,'2024-06-02',80,'Anaquel E2',48.00,'2024-06-14','reposicion','suficiente',TRUE),                    -- SUFICIENTE
 ('INV-000018','LOT-000018','PRV-000003',52,0,0,0,'2024-06-03',120,'Anaquel E3',32.00,'2024-06-14','surtido','bajo: cerca de reorden(80)',TRUE),      -- BAJO
 ('INV-000019','LOT-000019','PRV-000007',18,0,0,0,'2024-06-04',40,'Anaquel F1',110.00,'2024-06-14','surtido','critico: <= stock_minimo(15)+',TRUE),  -- CRITICO/limitrofe
 ('INV-000020','LOT-000020','PRV-000009',0,0,0,60,'2024-06-10',0,'Anaquel F2',45.00,'2024-06-14','surtido','agotado, en transito',TRUE);              -- AGOTADO

-- ---------------------------------------------------------------------
--  CONSULTAS adicionales.
--  - Seguimiento del MISMO paciente en distintas fechas (historial).
--  - Consultas en MESES distintos para la tendencia de la Vista 3.
--  - PAC-000001 y PAC-000006 concentran varias consultas.
-- ---------------------------------------------------------------------
INSERT INTO Consultas (id_consulta, paciente, medico, diagnostico, fecha, motivo, costo_consulta, tratamiento_indicado, observaciones) VALUES
 ('CON-000013','PAC-000001','MDC-000001','DIA-000001','2024-07-10 09:00:00','Seguimiento cefalea',500.00,'Continuar analgesico','Mejoria parcial'),
 ('CON-000014','PAC-000001','MDC-000001','DIA-000011','2024-08-12 09:00:00','Control de presion',500.00,'Mantener antihipertensivo','Estable'),
 ('CON-000015','PAC-000006','MDC-000011','DIA-000005','2024-07-05 13:00:00','Seguimiento gastritis',500.00,'Continuar omeprazol','Mejoria'),
 ('CON-000016','PAC-000006','MDC-000011','DIA-000010','2024-08-08 13:00:00','Reflujo persistente',500.00,'Ajuste de dosis','Requiere endoscopia'),
 ('CON-000017','PAC-000013','MDC-000013','DIA-000013','2024-07-15 10:00:00','Tos y fiebre',450.00,'Antibiotico y mucolitico','Infeccion respiratoria'),
 ('CON-000018','PAC-000014','MDC-000014','DIA-000015','2024-07-18 11:00:00','Ojos irritados',420.00,'Gotas antialergicas','Conjuntivitis'),
 ('CON-000019','PAC-000016','MDC-000011','DIA-000005','2024-07-20 12:00:00','Dolor estomacal',500.00,'Omeprazol','Gastritis por estres'),
 ('CON-000020','PAC-000017','MDC-000003','DIA-000004','2024-08-01 10:00:00','Colesterol alto',700.00,'Estatina','Dislipidemia'),
 ('CON-000021','PAC-000018','MDC-000014','DIA-000003','2024-08-05 09:30:00','Crisis asmatica',550.00,'Inhalador','Paciente pediatrico'),
 ('CON-000022','PAC-000004','MDC-000009','DIA-000014','2024-08-15 12:00:00','Dolor lumbar',700.00,'Analgesico potente','Lumbalgia mecanica');

-- ---------------------------------------------------------------------
--  RECETAS adicionales.
--  Mezcla de estados: surtidas (con venta) y NO surtidas (emitida/vencida)
--  para calcular la CONVERSION receta-venta de la Vista 3.
-- ---------------------------------------------------------------------
INSERT INTO Recetas (id_receta, consulta, folio, fecha_emision, fecha_vencimiento, estado, lugar_emision, diagnostico_texto, indicaciones, observaciones) VALUES
 ('REC-000013','CON-000013','RX-2024-000013-CDMX','2024-07-10 09:30:00','2024-08-09','surtida_total','Consultorio Central CDMX','Cefalea','Con alimentos','Seguimiento'),
 ('REC-000014','CON-000014','RX-2024-000014-CDMX','2024-08-12 09:30:00','2024-09-11','surtida_total','Consultorio Central CDMX','Hipertension','Por la manana','Estable'),
 ('REC-000015','CON-000015','RX-2024-000015-CDMX','2024-07-05 13:30:00','2024-08-04','surtida_total','Consultorio Central CDMX','Gastritis','Antes del desayuno','Seguimiento'),
 ('REC-000016','CON-000016','RX-2024-000016-CDMX','2024-08-08 13:30:00','2024-09-07','emitida','Consultorio Central CDMX','Reflujo','En ayunas','No surtida aun'),
 ('REC-000017','CON-000017','RX-2024-000017-CDMX','2024-07-15 10:30:00','2024-08-14','surtida_total','Consultorio Central CDMX','Infeccion respiratoria','Completar tratamiento','Antibiotico'),
 ('REC-000018','CON-000018','RX-2024-000018-CDMX','2024-07-18 11:30:00','2024-08-17','emitida','Consultorio Central CDMX','Conjuntivitis','No suspender','No surtida'),
 ('REC-000019','CON-000019','RX-2024-000019-CDMX','2024-07-20 12:30:00','2024-08-19','surtida_total','Consultorio Central CDMX','Gastritis','Antes del desayuno','Surtida'),
 ('REC-000020','CON-000020','RX-2024-000020-CDMX','2024-08-01 10:30:00','2024-08-31','vencida','Consultorio Central CDMX','Dislipidemia','Por la noche','Vencida sin surtir'),
 ('REC-000021','CON-000021','RX-2024-000021-CDMX','2024-08-05 10:00:00','2024-09-04','surtida_total','Consultorio Central CDMX','Asma','En crisis','Pediatrico'),
 ('REC-000022','CON-000022','RX-2024-000022-CDMX','2024-08-15 12:30:00','2024-09-14','emitida','Consultorio Central CDMX','Lumbalgia','Con alimentos','No surtida');

-- ---------------------------------------------------------------------
--  DETALLES_RECETA adicionales.
--  Se REPITEN ciertos medicamentos para el ranking de Vista 3:
--    MED-000001 (paracetamol) y MED-000006 (omeprazol) muy recetados.
-- ---------------------------------------------------------------------
INSERT INTO Detalles_Receta (receta, medicamento, dosis, frecuencia, duracion, cantidad_prescrita, via_administracion, instrucciones_especificas, observaciones) VALUES
 ('REC-000013','MED-000001','1 tableta','Cada 8 horas','5 dias',15,'oral','Con agua','Seguimiento'),
 ('REC-000014','MED-000005','1 tableta','Cada 24 horas','30 dias',30,'oral','Por la manana','Control presion'),
 ('REC-000015','MED-000006','1 capsula','Cada 24 horas','14 dias',14,'oral','Antes del desayuno','Gastritis'),
 ('REC-000016','MED-000006','1 capsula','Cada 24 horas','21 dias',21,'oral','En ayunas','Reflujo'),
 ('REC-000017','MED-000013','1 tableta','Cada 12 horas','10 dias',20,'oral','Completar','Antibiotico'),
 ('REC-000017','MED-000016','10 ml','Cada 8 horas','7 dias',1,'oral','Agitar','Mucolitico'),
 ('REC-000018','MED-000017','1 gota','Cada 12 horas','15 dias',1,'oftalmica','En ojo afectado','Conjuntivitis'),
 ('REC-000019','MED-000006','1 capsula','Cada 24 horas','14 dias',14,'oral','Antes del desayuno','Gastritis'),
 ('REC-000019','MED-000001','1 tableta','Cada 8 horas','3 dias',9,'oral','Solo con dolor','Coadyuvante'),
 ('REC-000020','MED-000011','1 tableta','Cada 24 horas','30 dias',30,'oral','Por la noche','Colesterol'),
 ('REC-000021','MED-000007','2 inhalaciones','Cada 6 horas','En crisis',1,'inhalada','Agitar','Asma'),
 ('REC-000022','MED-000018','1 tableta','Cada 8 horas','5 dias',15,'oral','Con alimentos','Lumbalgia'),
 ('REC-000022','MED-000001','1 tableta','Cada 8 horas','5 dias',15,'oral','Con agua','Coadyuvante');

-- ---------------------------------------------------------------------
--  ORDENES_COMPRA adicionales.
--  - MED-000014 esta inactivo: NO deberia generar orden (caso SP3).
--  - MED-000008 ya tiene orden 'enviada'; se agrega una 'pendiente' para
--    probar que SP3 NO duplique ordenes pendientes del mismo medicamento.
-- ---------------------------------------------------------------------
INSERT INTO Ordenes_Compra (id_orden_compra, proveedor, medicamento, empleado, cantidad_solicitada, costo_unitario, fecha_generacion, fecha_estimada_entrega, estado, generada_automatica, observaciones) VALUES
 ('ORD-000013','PRV-000012','MED-000013','EMP-000012',80,60.00,'2024-07-01 08:00:00','2024-07-05','recibida_total',TRUE,'Ciprofloxacino stock bajo'),
 ('ORD-000014','PRV-000009','MED-000018','EMP-000012',100,45.00,'2024-07-02 08:00:00','2024-07-05','pendiente',TRUE,'Ketorolaco agotado'),
 ('ORD-000015','PRV-000012','MED-000008','EMP-000010',40,110.00,'2024-07-03 08:00:00','2024-07-07','pendiente',TRUE,'Azitromicina (segunda orden pendiente - caso duplicado)'),
 ('ORD-000016','PRV-000003','MED-000016','EMP-000012',120,32.00,'2024-07-04 08:00:00','2024-07-08','enviada',TRUE,'Ambroxol'),
 ('ORD-000017','PRV-000007','MED-000017','EMP-000010',40,110.00,'2024-07-05 08:00:00','2024-07-09','recibida_total',FALSE,'Olopatadina'),
 ('ORD-000018','PRV-000005','MED-000015','EMP-000012',60,55.00,'2024-07-06 08:00:00','2024-07-12','pendiente',TRUE,'Fluconazol');

-- ---------------------------------------------------------------------
--  VENTAS adicionales.
--  Solo las recetas SURTIDAS tienen venta (conversion receta-venta).
--  Ventas repartidas en julio y agosto para la TENDENCIA de la Vista 3.
-- ---------------------------------------------------------------------
INSERT INTO Ventas (id_venta, empleado, receta, fecha_venta, tipo_pago, descuento, monto_total) VALUES
 ('VEN-000013','EMP-000007','REC-000013','2024-07-10 11:00:00','efectivo',0.00,45.50),
 ('VEN-000014','EMP-000011','REC-000014','2024-08-12 11:00:00','tarjeta_credito',0.00,120.00),
 ('VEN-000015','EMP-000016','REC-000015','2024-07-05 14:00:00','efectivo',0.00,95.00),
 ('VEN-000016','EMP-000007','REC-000017','2024-07-15 12:00:00','tarjeta_debito',0.00,195.00),
 ('VEN-000017','EMP-000016','REC-000019','2024-07-20 13:00:00','efectivo',5.00,135.50),
 ('VEN-000018','EMP-000011','REC-000021','2024-08-05 11:00:00','transferencia',0.00,140.00),
 ('VEN-000019','EMP-000017',NULL,'2024-07-22 10:00:00','efectivo',0.00,65.00),
 ('VEN-000020','EMP-000017',NULL,'2024-08-18 16:00:00','tarjeta_debito',0.00,130.00);

-- ---------------------------------------------------------------------
--  DETALLES_VENTA adicionales (PK: venta + medicamento + lote).
-- ---------------------------------------------------------------------
INSERT INTO Detalles_Venta (venta, medicamento, lote, cantidad, precio_unitario, subtotal) VALUES
 ('VEN-000013','MED-000001','LOT-000013',1,45.50,45.50),
 ('VEN-000014','MED-000005','LOT-000005',1,120.00,120.00),
 ('VEN-000015','MED-000006','LOT-000015',1,95.00,95.00),
 ('VEN-000016','MED-000013','LOT-000016',1,130.00,130.00),
 ('VEN-000016','MED-000016','LOT-000018',1,65.00,65.00),
 ('VEN-000017','MED-000006','LOT-000015',1,95.00,95.00),
 ('VEN-000017','MED-000001','LOT-000013',1,45.50,45.50),
 ('VEN-000018','MED-000007','LOT-000007',1,140.00,140.00),
 ('VEN-000019','MED-000016','LOT-000018',1,65.00,65.00),
 ('VEN-000020','MED-000013','LOT-000016',1,130.00,130.00);

-- ---------------------------------------------------------------------
--  AUDITORIA_INVENTARIO adicionales.
--  Cubre los 5 tipos de movimiento y documentos asociados.
-- ---------------------------------------------------------------------
INSERT INTO Auditoria_Inventario (id_auditoria, medicamento, lote, stock_anterior, stock_nuevo, tipo_movimiento, fecha_movimiento, empleado, receta, orden_compra, usuario_proceso, observaciones) VALUES
 ('AUD-000013','MED-000013','LOT-000016',95,35,'surtido','2024-07-15 12:00:00','EMP-000007','REC-000017',NULL,'sp_surtir','Venta VEN-000016'),
 ('AUD-000014','MED-000016','LOT-000018',53,52,'surtido','2024-07-15 12:01:00','EMP-000007','REC-000017',NULL,'sp_surtir','Venta VEN-000016'),
 ('AUD-000015','MED-000006','LOT-000015',151,150,'surtido','2024-07-05 14:00:00','EMP-000016','REC-000015',NULL,'sp_surtir','Venta VEN-000015'),
 ('AUD-000016','MED-000013','LOT-000016',15,95,'reposicion','2024-07-05 09:00:00','EMP-000012',NULL,'ORD-000013','sp_reposicion','Ingreso por orden'),
 ('AUD-000017','MED-000002','LOT-000014',10,0,'vencimiento','2024-06-01 08:00:00','EMP-000012',NULL,NULL,'proceso_caducidad','Lote LOT-000014 vencido'),
 ('AUD-000018','MED-000018','LOT-000020',20,0,'merma','2024-06-25 09:00:00','EMP-000012',NULL,NULL,'ajuste_manual','Producto danado en traslado'),
 ('AUD-000019','MED-000017','LOT-000019',40,18,'surtido','2024-07-18 11:30:00','EMP-000007','REC-000018',NULL,'sp_surtir','Dispensacion parcial'),
 ('AUD-000020','MED-000016','LOT-000018',120,53,'ajuste','2024-07-01 08:30:00','EMP-000012',NULL,NULL,'conteo_fisico','Ajuste por conteo');

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
--  FIN DEL DML
--  Totales aproximados por tabla tras la ampliacion:
--    Empleados 18 | Medicos 15 | Pacientes 18 | Historiales 18
--    Condiciones 12 | Historial_Condicion 19 | Diagnosticos 15
--    Consultas 22 | Medicamentos 18 | Medicamento_Condicion 18
--    Interacciones 17 | Recetas 22 | Detalles_Receta 25
--    Proveedores 12 | Ordenes_Compra 18 | Lotes 20 | Inventario 20
--    Ventas 20 | Detalles_Venta 22 | Auditoria 20
--  (Todas >= 10 registros, con casos de prueba para Vistas/SP/Triggers.)
-- =====================================================================
