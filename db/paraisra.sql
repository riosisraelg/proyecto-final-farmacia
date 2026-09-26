-- // PRUEBA DE LA VISTA 1 (ESTA BIEN ESTA VISTA)
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



-- // PRUEBA DE LA VISTA 3 (ESTA VISTA ESTA BIEN)
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
