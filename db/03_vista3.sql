-- =====================================================================
--  VISTA 3: Medicamentos Mas Recetados y Surtidos
--  Proyecto Final - Farmacia con Consultorio Medico
--  Requiere: 01_schema.sql y 02_data.sql ejecutados previamente.
-- ---------------------------------------------------------------------
--  Muestra: medicamento y principio activo, veces recetado, veces
--  surtido, % de conversion receta-venta, medico que mas lo receta y
--  tendencia de consumo (creciente / estable / decreciente).
-- =====================================================================

USE farmacia_consultorio;

CREATE OR REPLACE VIEW vista_medicamentos_mas_recetados AS
SELECT
    m.id_medicamento,
    m.nombre                                   AS medicamento,
    m.principio_activo,
    COALESCE(r.veces_recetado, 0)              AS veces_recetado,
    COALESCE(v.veces_surtido, 0)               AS veces_surtido,
    CASE
        WHEN COALESCE(r.veces_recetado,0) = 0 THEN 0
        ELSE ROUND(COALESCE(v.veces_surtido,0) * 100.0 / r.veces_recetado, 2)
    END                                        AS porcentaje_conversion,
    COALESCE(md.medico_top, 'Sin recetas')     AS medico_que_mas_receta,
    CASE
        WHEN COALESCE(t.cant_mes_actual,0) > COALESCE(t.cant_mes_previo,0) THEN 'creciente'
        WHEN COALESCE(t.cant_mes_actual,0) < COALESCE(t.cant_mes_previo,0) THEN 'decreciente'
        ELSE 'estable'
    END                                        AS tendencia_consumo
FROM Medicamentos m
-- Veces recetado (renglones de receta por medicamento)
LEFT JOIN (
    SELECT medicamento, COUNT(*) AS veces_recetado
    FROM Detalles_Receta
    GROUP BY medicamento
) r ON r.medicamento = m.id_medicamento
-- Veces surtido (renglones de venta por medicamento)
LEFT JOIN (
    SELECT medicamento, COUNT(*) AS veces_surtido
    FROM Detalles_Venta
    GROUP BY medicamento
) v ON v.medicamento = m.id_medicamento
-- Medico que mas receta cada medicamento (top-1 por numero de recetas)
LEFT JOIN (
    SELECT x.medicamento,
           CONCAT(e.nombre, ' ', e.apellidos) AS medico_top
    FROM (
        SELECT dr.medicamento, c.medico, COUNT(*) AS n,
               ROW_NUMBER() OVER (PARTITION BY dr.medicamento
                                  ORDER BY COUNT(*) DESC, c.medico) AS rn
        FROM Detalles_Receta dr
        JOIN Recetas   rc ON rc.id_receta  = dr.receta
        JOIN Consultas c  ON c.id_consulta = rc.consulta
        GROUP BY dr.medicamento, c.medico
    ) x
    JOIN Medicos   md ON md.id_medico  = x.medico
    JOIN Empleados e  ON e.id_empleado = md.empleado
    WHERE x.rn = 1
) md ON md.medicamento = m.id_medicamento
-- Tendencia: cantidad surtida del ultimo mes con ventas vs el mes previo
LEFT JOIN (
    SELECT medicamento,
           SUM(CASE WHEN ym = (SELECT MAX(DATE_FORMAT(fecha_venta,'%Y-%m')) FROM Ventas)
                    THEN cantidad ELSE 0 END) AS cant_mes_actual,
           SUM(CASE WHEN ym = (SELECT DATE_FORMAT(
                                   DATE_SUB(STR_TO_DATE(CONCAT(MAX(DATE_FORMAT(fecha_venta,'%Y-%m')),'-01'),'%Y-%m-%d'),
                                            INTERVAL 1 MONTH),'%Y-%m')
                               FROM Ventas)
                    THEN cantidad ELSE 0 END) AS cant_mes_previo
    FROM (
        SELECT dv.medicamento, dv.cantidad,
               DATE_FORMAT(ve.fecha_venta,'%Y-%m') AS ym
        FROM Detalles_Venta dv
        JOIN Ventas ve ON ve.id_venta = dv.venta
    ) z
    GROUP BY medicamento
) t ON t.medicamento = m.id_medicamento
ORDER BY veces_recetado DESC, veces_surtido DESC;

-- Consulta de uso:
-- SELECT * FROM vista_medicamentos_mas_recetados;
