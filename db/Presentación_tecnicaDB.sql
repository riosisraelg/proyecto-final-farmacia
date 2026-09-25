/*
====================================================================
PROYECTO FINAL - FARMACIA CON CONSULTORIO MÉDICO
BASE DE DATOS: proyecto_final_data_base
====================================================================

CASO DE NEGOCIO

La empresa corresponde a una farmacia con consultorio médico,
encargada de gestionar pacientes, consultas médicas, diagnósticos,
recetas, medicamentos, inventario, proveedores, ventas y
seguimiento clínico.

PROBLEMÁTICA ACTUAL

La farmacia necesita centralizar la información clínica y de
medicamentos para evitar errores en la prescripción y surtido,
controlar el inventario, detectar existencias bajas y validar que
los medicamentos prescritos sean compatibles con las condiciones
clínicas y alergias registradas de cada paciente.

La base de datos permite integrar la información médica, las recetas,
los medicamentos, el inventario y las operaciones de la farmacia,
aplicando reglas de validación mediante vistas, procedimientos
almacenados y triggers.

====================================================================
*/

/*
====================================================================
SELECCIÓN DE LA BASE DE DATOS
====================================================================
*/

USE proyecto_final_data_base;


/*
====================================================================
MOSTRAR TODAS LAS TABLAS Y SUS DATOS
====================================================================

Esta sección permite presentar la estructura completa de la base
de datos y comprobar la información almacenada en cada tabla.
====================================================================
*/


/*
1. EMPLEADOS
*/
SELECT * FROM Empleados;


/*
2. MEDICOS
*/
SELECT * FROM Medicos;


/*
3. PACIENTES
*/
SELECT * FROM Pacientes;


/*
4. HISTORIALES CLINICOS
*/
SELECT * FROM Historiales_Clinicos;


/*
5. CONDICIONES CLINICAS
*/
SELECT * FROM Condiciones_Clinicas;


/*
6. HISTORIAL CONDICION
*/
SELECT * FROM Historial_Condicion;


/*
7. DIAGNOSTICOS
*/
SELECT * FROM Diagnosticos;


/*
8. CONSULTAS
*/
SELECT * FROM Consultas;


/*
9. MEDICAMENTOS
*/
SELECT * FROM Medicamentos;


/*
10. MEDICAMENTO CONDICION
*/
SELECT * FROM Medicamento_Condicion;


/*
11. INTERACCIONES MEDICAMENTOSAS
*/
SELECT * FROM Interacciones_Medicamentosas;


/*
12. RECETAS
*/
SELECT * FROM Recetas;


/*
13. DETALLES DE RECETA
*/
SELECT * FROM Detalles_Receta;


/*
14. PROVEEDORES
*/
SELECT * FROM Proveedores;


/*
15. ORDENES DE COMPRA
*/
SELECT * FROM Ordenes_Compra;


/*
16. LOTES
*/
SELECT * FROM Lotes;


/*
17. INVENTARIO
*/
SELECT * FROM Inventario;


/*
18. VENTAS
*/
SELECT * FROM Ventas;


/*
19. DETALLES DE VENTA
*/
SELECT * FROM Detalles_Venta;


/*
20. AUDITORIA DE INVENTARIO
*/
SELECT * FROM Auditoria_Inventario;


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
WHERE id_paciente = 'PAC-000001';


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
====================================================================
ISRA - STORED PROCEDURE
REGISTRAR CONSULTA Y EMITIR RECETA MEDICA
====================================================================

Este procedimiento automatiza el registro de una nueva consulta
médica y la generación de su receta.

VALIDACIONES REALIZADAS:

1. Paciente existente y activo.
2. Médico existente y activo.
3. Cédula profesional vigente.
4. Diagnóstico existente y activo.
5. Consulta no duplicada.
6. Receta no duplicada.
7. Medicamentos existentes y activos.
8. Cantidades mayores a cero.
9. Existencia suficiente en inventario.
10. Alergias y contraindicaciones.
11. Interacciones medicamentosas.
12. Dosis compatible con la concentración.
13. Duración dentro del máximo permitido.
14. Registro de la consulta.
15. Generación de la receta.
16. Registro de los medicamentos de la receta.
17. Descuento automático del inventario cuando se indica
    surtimiento inmediato.

Para el descuento se utiliza el lote con fecha de caducidad
más próxima, aplicando el criterio FEFO.
====================================================================
*/

DROP PROCEDURE IF EXISTS sp_registrar_consulta_emitir_receta;

DELIMITER $$

CREATE PROCEDURE sp_registrar_consulta_emitir_receta
(
    IN p_id_consulta VARCHAR(10),
    IN p_id_paciente VARCHAR(10),
    IN p_id_medico VARCHAR(10),
    IN p_id_diagnostico VARCHAR(10),

    IN p_fecha_consulta DATETIME,
    IN p_motivo VARCHAR(255),
    IN p_costo_consulta DECIMAL(10,2),
    IN p_tratamiento TEXT,
    IN p_observaciones_consulta TEXT,

    IN p_id_receta VARCHAR(10),
    IN p_folio VARCHAR(30),
    IN p_fecha_emision DATETIME,
    IN p_fecha_vencimiento DATE,
    IN p_lugar_emision VARCHAR(120),
    IN p_indicaciones TEXT,
    IN p_observaciones_receta TEXT,

    IN p_medicamentos JSON,

    IN p_surtir_inmediatamente BOOLEAN
)

BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_diagnostico INT DEFAULT 0;
    DECLARE v_stock DECIMAL(12,2) DEFAULT 0;
    DECLARE v_conflicto INT DEFAULT 0;
    DECLARE v_interaccion INT DEFAULT 0;
    DECLARE v_duracion_max INT DEFAULT NULL;

    DECLARE v_error BOOLEAN DEFAULT FALSE;

    /*
    Manejo general de errores.
    Si ocurre cualquier error se deshace toda la operación.
    */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN

    ROLLBACK;

    DROP TEMPORARY TABLE IF EXISTS tmp_sp1_medicamentos;

    RESIGNAL;

END;

    START TRANSACTION;


    /*
    ================================================================
    1. VALIDAR PACIENTE
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Pacientes

    WHERE id_paciente = p_id_paciente
      AND activo = TRUE;


    IF v_existe = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El paciente no existe o se encuentra inactivo.';

    END IF;


    /*
    ================================================================
    2. VALIDAR MEDICO
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Medicos

    WHERE id_medico = p_id_medico
      AND activo = TRUE
      AND cedula_vigencia >= CURDATE();


    IF v_existe = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El medico no existe, esta inactivo o su cedula esta vencida.';

    END IF;


    /*
    ================================================================
    3. VALIDAR DIAGNOSTICO
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Diagnosticos

    WHERE id_diagnostico = p_id_diagnostico
      AND activo = TRUE;


    IF v_existe = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El diagnostico no existe o se encuentra inactivo.';

    END IF;


    /*
    ================================================================
    4. VALIDAR QUE NO EXISTA LA CONSULTA
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Consultas

    WHERE id_consulta = p_id_consulta;


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El identificador de consulta ya existe.';

    END IF;


    /*
    ================================================================
    5. VALIDAR QUE NO EXISTA LA RECETA
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Recetas

    WHERE id_receta = p_id_receta;


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El identificador de receta ya existe.';

    END IF;


    /*
    ================================================================
    6. CREAR TABLA TEMPORAL DE MEDICAMENTOS
    ================================================================
    */

    DROP TEMPORARY TABLE IF EXISTS tmp_sp1_medicamentos;


    CREATE TEMPORARY TABLE tmp_sp1_medicamentos
    (
        medicamento VARCHAR(10),
        dosis VARCHAR(100),
        frecuencia VARCHAR(100),
        duracion VARCHAR(100),
        cantidad INT,
        via VARCHAR(30),
        instrucciones TEXT,
        observaciones TEXT
    );


    /*
    ================================================================
    7. CARGAR LOS MEDICAMENTOS RECIBIDOS EN FORMATO JSON
    ================================================================
    */

    INSERT INTO tmp_sp1_medicamentos
    (
        medicamento,
        dosis,
        frecuencia,
        duracion,
        cantidad,
        via,
        instrucciones,
        observaciones
    )

    SELECT
        medicamento,
        dosis,
        frecuencia,
        duracion,
        cantidad,
        via,
        instrucciones,
        observaciones

    FROM JSON_TABLE
    (
        p_medicamentos,
        '$[*]'

        COLUMNS
        (
            medicamento VARCHAR(10)
                PATH '$.medicamento',

            dosis VARCHAR(100)
                PATH '$.dosis',

            frecuencia VARCHAR(100)
                PATH '$.frecuencia',

            duracion VARCHAR(100)
                PATH '$.duracion',

            cantidad INT
                PATH '$.cantidad',

            via VARCHAR(30)
                PATH '$.via',

            instrucciones TEXT
                PATH '$.instrucciones',

            observaciones TEXT
                PATH '$.observaciones'
        )

    ) AS jt;


    /*
    ================================================================
    8. VALIDAR QUE EXISTA AL MENOS UN MEDICAMENTO
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM tmp_sp1_medicamentos;


    IF v_existe = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'La receta debe contener al menos un medicamento.';

    END IF;


    /*
    ================================================================
    9. VALIDAR MEDICAMENTOS EXISTENTES Y ACTIVOS
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM tmp_sp1_medicamentos t

    LEFT JOIN Medicamentos m
        ON m.id_medicamento = t.medicamento

    WHERE
        m.id_medicamento IS NULL
        OR m.activo = FALSE;


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Existe un medicamento inexistente o inactivo.';

    END IF;


    /*
    ================================================================
    10. VALIDAR CANTIDADES
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM tmp_sp1_medicamentos

    WHERE cantidad IS NULL
       OR cantidad <= 0;


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Todas las cantidades de medicamento deben ser mayores a cero.';

    END IF;


    /*
    ================================================================
    11. VALIDAR STOCK DISPONIBLE
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM
    (
        SELECT
            t.medicamento,
            t.cantidad,
            COALESCE(
                SUM(i.stock_actual),
                0
            ) AS stock_disponible

        FROM tmp_sp1_medicamentos t

        LEFT JOIN Lotes l
            ON l.medicamento = t.medicamento
           AND l.activo = TRUE
           AND l.fecha_caducidad >= CURDATE()

        LEFT JOIN Inventario i
            ON i.lote = l.id_lote
           AND i.activo = TRUE

        GROUP BY
            t.medicamento,
            t.cantidad

    ) stock_validacion

    WHERE stock_disponible < cantidad;


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'No existe inventario suficiente para uno o mas medicamentos.';

    END IF;


    /*
    ================================================================
    12. VALIDAR ALERGIAS Y CONTRAINDICACIONES
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_conflicto

    FROM tmp_sp1_medicamentos t

    INNER JOIN Historiales_Clinicos h
        ON h.paciente = p_id_paciente

    INNER JOIN Historial_Condicion hc
        ON hc.historial = h.id_historial
       AND hc.activa = TRUE

    INNER JOIN Medicamento_Condicion mc
        ON mc.condicion = hc.condicion
       AND mc.medicamento = t.medicamento;


    IF v_conflicto > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'La receta contiene un medicamento contraindicado para el paciente.';

    END IF;


    /*
    ================================================================
    13. VALIDAR INTERACCIONES MEDICAMENTOSAS
    ================================================================

    En la estructura actual los niveles de riesgo son:
    leve, moderada y severa.

    Se consideran riesgosas las interacciones moderadas y severas.
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_interaccion

    FROM tmp_sp1_medicamentos a

    INNER JOIN tmp_sp1_medicamentos b
        ON a.medicamento < b.medicamento

    INNER JOIN Interacciones_Medicamentosas i
        ON
        (
            i.medicamento_a = a.medicamento
            AND i.medicamento_b = b.medicamento
        )
        OR
        (
            i.medicamento_a = b.medicamento
            AND i.medicamento_b = a.medicamento
        )

    WHERE
        i.nivel_riesgo IN
        (
            'moderada',
            'severa'
        )
        AND i.activa = TRUE;


    IF v_interaccion > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'La receta contiene una interaccion medicamentosa de riesgo.';

    END IF;


    /*
    ================================================================
    14. VALIDAR DOSIS Y CONCENTRACION
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM tmp_sp1_medicamentos t

    INNER JOIN Medicamentos m
        ON m.id_medicamento = t.medicamento

    WHERE
        LOWER(t.dosis)
        NOT LIKE CONCAT(
            '%',
            LOWER(m.concentracion),
            '%'
        );


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'La dosis indicada no coincide con la concentracion del medicamento.';

    END IF;


    /*
    ================================================================
    15. VALIDAR DURACION MAXIMA
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM tmp_sp1_medicamentos t

    INNER JOIN Medicamentos m
        ON m.id_medicamento = t.medicamento

    WHERE
        m.duracion_maxima_dias IS NOT NULL
        AND CAST(
            REGEXP_SUBSTR(
                t.duracion,
                '[0-9]+'
            ) AS UNSIGNED
        ) > m.duracion_maxima_dias;


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'La duracion indicada supera el maximo permitido para un medicamento.';

    END IF;


    /*
    ================================================================
    16. REGISTRAR LA CONSULTA
    ================================================================
    */

    INSERT INTO Consultas
    (
        id_consulta,
        paciente,
        medico,
        diagnostico,
        fecha,
        motivo,
        costo_consulta,
        tratamiento_indicado,
        observaciones
    )

    VALUES
    (
        p_id_consulta,
        p_id_paciente,
        p_id_medico,
        p_id_diagnostico,
        p_fecha_consulta,
        p_motivo,
        p_costo_consulta,
        p_tratamiento,
        p_observaciones_consulta
    );


    /*
    ================================================================
    17. REGISTRAR LA RECETA
    ================================================================
    */

    INSERT INTO Recetas
    (
        id_receta,
        consulta,
        folio,
        fecha_emision,
        fecha_vencimiento,
        estado,
        lugar_emision,
        diagnostico_texto,
        indicaciones,
        observaciones
    )

    SELECT
        p_id_receta,
        p_id_consulta,
        p_folio,
        p_fecha_emision,
        p_fecha_vencimiento,
        'emitida',
        p_lugar_emision,
        d.nombre,
        p_indicaciones,
        p_observaciones_receta

    FROM Diagnosticos d

    WHERE d.id_diagnostico = p_id_diagnostico;


    /*
    ================================================================
    18. REGISTRAR LOS DETALLES DE LA RECETA
    ================================================================
    */

    INSERT INTO Detalles_Receta
    (
        receta,
        medicamento,
        dosis,
        frecuencia,
        duracion,
        cantidad_prescrita,
        via_administracion,
        instrucciones_especificas,
        observaciones
    )

    SELECT
        p_id_receta,
        medicamento,
        dosis,
        frecuencia,
        duracion,
        cantidad,
        via,
        instrucciones,
        observaciones

    FROM tmp_sp1_medicamentos;


    /*
    ================================================================
    19. DESCONTAR INVENTARIO SI EL SURTIMIENTO ES INMEDIATO
    ================================================================

    Se genera una tabla temporal de movimientos utilizando los lotes
    con fecha de caducidad más próxima.

    Esto permite aplicar FEFO:
    First Expired, First Out.
    ================================================================
    */

    IF p_surtir_inmediatamente = TRUE THEN

        DROP TEMPORARY TABLE IF EXISTS tmp_descuento_inventario;


        CREATE TEMPORARY TABLE tmp_descuento_inventario AS

        SELECT
            x.medicamento,
            x.id_inventario,
            x.stock_actual,

            GREATEST
            (
                0,

                LEAST
                (
                    x.stock_actual,

                    x.cantidad_solicitada
                    -
                    COALESCE
                    (
                        SUM(x.stock_actual) OVER
                        (
                            PARTITION BY x.medicamento

                            ORDER BY
                                x.fecha_caducidad,
                                x.id_lote

                            ROWS BETWEEN
                                UNBOUNDED PRECEDING
                                AND
                                1 PRECEDING
                        ),

                        0
                    )
                )

            ) AS cantidad_salida

        FROM
        (
            SELECT
                t.medicamento,
                t.cantidad AS cantidad_solicitada,

                i.id_inventario,
                i.stock_actual,

                l.id_lote,
                l.fecha_caducidad

            FROM tmp_sp1_medicamentos t

            INNER JOIN Lotes l
                ON l.medicamento = t.medicamento
               AND l.activo = TRUE
               AND l.fecha_caducidad >= CURDATE()

            INNER JOIN Inventario i
                ON i.lote = l.id_lote
               AND i.activo = TRUE
               AND i.stock_actual > 0
        ) x;


        /*
        ============================================================
        20. ACTUALIZAR EL STOCK
        ============================================================
        */

        UPDATE Inventario i

        INNER JOIN tmp_descuento_inventario d
            ON d.id_inventario = i.id_inventario

        SET
            i.stock_actual =
                i.stock_actual - d.cantidad_salida,

            i.ultimo_movimiento = 'surtido',

            i.fecha_ultimo_conteo = NOW(),

            i.observaciones =
                CONCAT(
                    COALESCE(i.observaciones, ''),
                    ' | Surtimiento inmediato de receta ',
                    p_id_receta
                )

        WHERE
            d.cantidad_salida > 0;


        DROP TEMPORARY TABLE IF EXISTS tmp_descuento_inventario;

    END IF;


    /*
    ================================================================
    21. FINALIZAR OPERACION
    ================================================================
    */

    COMMIT;


    DROP TEMPORARY TABLE IF EXISTS tmp_sp1_medicamentos;


    /*
    ================================================================
    RESULTADO DEL PROCEDIMIENTO
    ================================================================
    */

    SELECT

        'Consulta y receta registradas correctamente.' AS mensaje,

        p_id_consulta AS id_consulta,

        p_id_receta AS id_receta,

        CASE
            WHEN p_surtir_inmediatamente = TRUE
                THEN 'Inventario descontado'
            ELSE 'Inventario no descontado'
        END AS resultado_inventario;


END$$

DELIMITER ;


/*
====================================================================
MATEO - TRIGGER
VALIDACION DE DETALLE DE RECETA
====================================================================

Este trigger se ejecuta antes de insertar un medicamento en una
receta.

Se utiliza Detalles_Receta porque en esta tabla se encuentran los
datos específicos del medicamento, dosis, duración y cantidad.

El trigger valida:

1. Paciente activo.
2. Médico activo.
3. Cédula profesional vigente.
4. Medicamento activo.
5. Stock suficiente.
6. Alergias y contraindicaciones.
7. Medicamento duplicado dentro de la receta.
8. Dosis compatible con la concentración.
9. Duración máxima permitida.

Si alguna condición no se cumple, la inserción es rechazada.
====================================================================
*/

DROP TRIGGER IF EXISTS trg_validar_detalle_receta;

DELIMITER $$

CREATE TRIGGER trg_validar_detalle_receta

BEFORE INSERT ON Detalles_Receta

FOR EACH ROW

BEGIN

    DECLARE v_paciente VARCHAR(10);
    DECLARE v_medico VARCHAR(10);

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_stock DECIMAL(12,2) DEFAULT 0;

    DECLARE v_concentracion VARCHAR(100);
    DECLARE v_duracion_max INT;


    /*
    ================================================================
    1. OBTENER PACIENTE Y MEDICO DE LA RECETA
    ================================================================
    */

    SELECT
        c.paciente,
        c.medico

    INTO
        v_paciente,
        v_medico

    FROM Recetas r

    INNER JOIN Consultas c
        ON c.id_consulta = r.consulta

    WHERE
        r.id_receta = NEW.receta;


    /*
    ================================================================
    2. VALIDAR PACIENTE
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Pacientes

    WHERE
        id_paciente = v_paciente
        AND activo = TRUE;


    IF v_existe = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El paciente de la receta no existe o esta inactivo.';

    END IF;


    /*
    ================================================================
    3. VALIDAR MEDICO
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Medicos

    WHERE
        id_medico = v_medico
        AND activo = TRUE
        AND cedula_vigencia >= CURDATE();


    IF v_existe = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El medico no esta activo o su cedula profesional esta vencida.';

    END IF;


    /*
    ================================================================
    4. VALIDAR MEDICAMENTO
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Medicamentos

    WHERE
        id_medicamento = NEW.medicamento
        AND activo = TRUE;


    IF v_existe = 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El medicamento no existe o se encuentra inactivo.';

    END IF;


    /*
    ================================================================
    5. VALIDAR STOCK
    ================================================================
    */

    SELECT COALESCE(
        SUM(i.stock_actual),
        0
    )

    INTO v_stock

    FROM Inventario i

    INNER JOIN Lotes l
        ON l.id_lote = i.lote

    WHERE
        l.medicamento = NEW.medicamento
        AND l.activo = TRUE
        AND l.fecha_caducidad >= CURDATE()
        AND i.activo = TRUE;


    IF v_stock < NEW.cantidad_prescrita THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'No existe stock suficiente para el medicamento solicitado.';

    END IF;


    /*
    ================================================================
    6. VALIDAR ALERGIAS Y CONTRAINDICACIONES
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Historiales_Clinicos h

    INNER JOIN Historial_Condicion hc
        ON hc.historial = h.id_historial

    INNER JOIN Medicamento_Condicion mc
        ON mc.condicion = hc.condicion
       AND mc.medicamento = NEW.medicamento

    WHERE
        h.paciente = v_paciente
        AND hc.activa = TRUE;


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El medicamento esta contraindicado para el paciente.';

    END IF;


    /*
    ================================================================
    7. VALIDAR MEDICAMENTO DUPLICADO
    ================================================================
    */

    SELECT COUNT(*)
    INTO v_existe

    FROM Detalles_Receta

    WHERE
        receta = NEW.receta
        AND medicamento = NEW.medicamento;


    IF v_existe > 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'El medicamento ya se encuentra registrado en esta receta.';

    END IF;


    /*
    ================================================================
    8. OBTENER CONCENTRACION Y DURACION MAXIMA
    ================================================================
    */

    SELECT
        concentracion,
        duracion_maxima_dias

    INTO
        v_concentracion,
        v_duracion_max

    FROM Medicamentos

    WHERE
        id_medicamento = NEW.medicamento;


    /*
    ================================================================
    9. VALIDAR DOSIS
    ================================================================
    */

    IF LOWER(NEW.dosis)
       NOT LIKE CONCAT(
            '%',
            LOWER(v_concentracion),
            '%'
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'La dosis indicada no coincide con la concentracion del medicamento.';

    END IF;


    /*
    ================================================================
    10. VALIDAR DURACION
    ================================================================
    */

    IF v_duracion_max IS NOT NULL
       AND CAST(
            REGEXP_SUBSTR(
                NEW.duracion,
                '[0-9]+'
            ) AS UNSIGNED
       ) > v_duracion_max THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'La duracion supera el maximo permitido para el medicamento.';

    END IF;

END$$

DELIMITER ;


/*
====================================================================
VALIDACIONES DEL STORED PROCEDURE
====================================================================

Se presentan tres casos:

1. Caso correcto.
2. Paciente inexistente.
3. Stock insuficiente.

====================================================================
*/

/*
/*
====================================================================
VALIDACIÓN 1 - CASO CORRECTO
====================================================================

OBJETIVO:
Demostrar que el procedimiento almacenado permite registrar
correctamente una consulta médica y generar su receta cuando
todos los datos y validaciones son correctos.

DATOS UTILIZADOS:

- PAC-000018: paciente existente y activo.
- MDC-000005: médico existente, activo y con cédula vigente.
- DIA-000006: diagnóstico existente y activo.
- MED-000001: medicamento existente, activo y con inventario
  suficiente.

RESULTADO ESPERADO:
La consulta, la receta y el detalle de la receta deben registrarse
correctamente en sus respectivas tablas.
*/

CALL sp_registrar_consulta_emitir_receta
(
    'CON019',
    'PAC-0000018',
    'MDC-000005',
    'DIA-000006',

    '2026-09-24 10:00:00',
    'Seguimiento de rinitis alergica.',
    450.00,
    'Continuar tratamiento sintomatico.',
    'Consulta registrada mediante procedimiento almacenado.',

    'REC019',
    'FOL-2026-0019',
    '2026-09-24 10:00:00',
    '2026-10-05',
    'Consultorio Farmacia Centro',
    'Tomar segun indicaciones.',
    'Receta generada mediante Stored Procedure.',

    JSON_ARRAY
    (
        JSON_OBJECT
        (
            'medicamento', 'MED-000001', 
            'dosis', '500 mg',
            'frecuencia', 'Cada 8 horas',
            'duracion', '5 dias',
            'cantidad', 5,
            'via', 'oral',
            'instrucciones', 'Tomar despues de los alimentos.',
            'observaciones', NULL
        )
    ),

    FALSE
);


-- Comprobar la consulta y receta creadas exitosamente:
SELECT * FROM Consultas WHERE id_consulta = 'CON-000019';
SELECT * FROM Recetas WHERE id_receta = 'REC-000019';
SELECT * FROM Detalles_Receta WHERE receta = 'REC-000019';


/*
====================================================================
VALIDACION 2 - PACIENTE INEXISTENTE
====================================================================

PAC999 no existe.

El procedimiento debe rechazar la operación y mostrar el mensaje
correspondiente.
====================================================================
*/

CALL sp_registrar_consulta_emitir_receta
(
    'CON-000014',
    'PAC-000999',
    'MED-000001',
    'DIA-000003',

    '2026-09-24 11:00:00',

    'Consulta de prueba.',

    450.00,

    'Tratamiento de prueba.',

    'Validacion de paciente inexistente.',

    'REC-000014',

    'FOL-2026-0014',

    '2026-09-24 11:00:00',

    '2026-10-05',

    'Consultorio Farmacia Centro',

    'Tomar segun indicaciones.',

    'Prueba de validacion.',

    JSON_ARRAY
    (
        JSON_OBJECT
        (
            'medicamento', 'MED-000002',
            'dosis', '10 mg',
            'frecuencia', 'Cada 24 horas',
            'duracion', '5 dias',
            'cantidad', 5,
            'via', 'oral',
            'instrucciones', 'Tomar por la manana.',
            'observaciones', NULL
        )
    ),

    FALSE
);


/*
====================================================================
VALIDACION 3 - STOCK INSUFICIENTE
====================================================================

MED003 tiene actualmente una existencia limitada.

Se solicitan 99999 unidades, por lo que el procedimiento debe
rechazar la operación.
====================================================================
*/

CALL sp_registrar_consulta_emitir_receta
(
    'CON-000015',
    'PAC-000001',
    'MED-000001',
    'DIA-000003',

    '2026-09-24 12:00:00',

    'Consulta de prueba de inventario.',

    450.00,

    'Tratamiento de prueba.',

    'Validacion de stock insuficiente.',

    'REC-000015',

    'FOL-2026-0015',

    '2026-09-24 12:00:00',

    '2026-10-05',

    'Consultorio Farmacia Centro',

    'Tomar segun indicaciones.',

    'Prueba de stock insuficiente.',

    JSON_ARRAY
    (
        JSON_OBJECT
        (
            'medicamento', 'MED-000003',
            'dosis', '400 mg',
            'frecuencia', 'Cada 12 horas',
            'duracion', '5 dias',
            'cantidad', 99999,
            'via', 'oral',
            'instrucciones', 'Tomar despues de los alimentos.',
            'observaciones', NULL
        )
    ),

    FALSE
);


/*
====================================================================
VALIDACIONES DEL TRIGGER
====================================================================

Se presentan tres casos:

1. Inserción correcta.
2. Medicamento contraindicado.
3. Medicamento duplicado.

====================================================================
*/


/*
====================================================================
VALIDACION DEL TRIGGER 1 - INSERCION CORRECTA
====================================================================

REC013 pertenece a PAC001.

MED006 tiene existencia disponible y no presenta una
contraindicación registrada para PAC001.

La inserción debe realizarse correctamente.
====================================================================
*/

INSERT INTO Detalles_Receta
(
    receta,
    medicamento,
    dosis,
    frecuencia,
    duracion,
    cantidad_prescrita,
    via_administracion,
    instrucciones_especificas,
    observaciones
)

VALUES
(
    'REC-000013',
    'MED-000006',
    '10 mg',
    'Cada 24 horas',
    '5 dias',
    5,
    'oral',
    'Tomar por la manana.',
    'Validacion correcta del trigger.'
);


/*
Comprobar la inserción.
*/

SELECT *
FROM Detalles_Receta
WHERE receta = 'REC-000013'
  AND medicamento = 'MED-000001';


/*
====================================================================
VALIDACION DEL TRIGGER 2 - CONTRAINDICACION
====================================================================

PAC001 tiene registrada una alergia a la penicilina:

HIS001 -> CON001

MED004 = Amoxicilina.

MED004 esta relacionado con CON001 con nivel de riesgo severo.

Por lo tanto, el trigger debe rechazar la inserción.
====================================================================
*/

INSERT INTO Detalles_Receta
(
    receta,
    medicamento,
    dosis,
    frecuencia,
    duracion,
    cantidad_prescrita,
    via_administracion,
    instrucciones_especificas,
    observaciones
)

VALUES
(
    'REC-000013',
    'MED-000004',
    '500 mg',
    'Cada 8 horas',
    '5 dias',
    5,
    'oral',
    'Tomar despues de los alimentos.',
    'Prueba de medicamento contraindicado.'
);


/*
====================================================================
VALIDACION DEL TRIGGER 3 - MEDICAMENTO DUPLICADO
====================================================================

MED006 ya fue registrado anteriormente en REC013.

La llave primaria y la validacion del trigger deben impedir que el
mismo medicamento se agregue nuevamente a la misma receta.
====================================================================
*/

INSERT INTO Detalles_Receta
(
    receta,
    medicamento,
    dosis,
    frecuencia,
    duracion,
    cantidad_prescrita,
    via_administracion,
    instrucciones_especificas,
    observaciones
)

VALUES
(
    'REC-000013',
    'MED-000006',
    '10 mg',
    'Cada 24 horas',
    '5 dias',
    5,
    'oral',
    'Tomar por la manana.',
    'Prueba de medicamento duplicado.'
);


/*
====================================================================
CONSULTA FINAL DE COMPROBACION
====================================================================
*/

SELECT
    r.id_receta,
    r.folio,
    r.estado,
    r.fecha_emision,

    p.id_paciente,
    CONCAT(
        p.nombre,
        ' ',
        p.apellidos
    ) AS paciente,

    m.id_medicamento,
    m.nombre AS medicamento,

    dr.dosis,
    dr.frecuencia,
    dr.duracion,
    dr.cantidad_prescrita

FROM Recetas r

INNER JOIN Consultas c
    ON c.id_consulta = r.consulta

INNER JOIN Pacientes p
    ON p.id_paciente = c.paciente

INNER JOIN Detalles_Receta dr
    ON dr.receta = r.id_receta

INNER JOIN Medicamentos m
    ON m.id_medicamento = dr.medicamento

WHERE
    r.id_receta = 'REC-000013';


/*
====================================================================
FIN DEL CÓDIGO DE PRESENTACIÓN
====================================================================
