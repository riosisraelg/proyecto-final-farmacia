-- =====================================================================
--  VISTA 3 (VERSION SIMPLE / NIVEL ESTUDIANTE)
--  Medicamentos Mas Recetados y Surtidos
--  Proyecto Final - Farmacia con Consultorio Medico
-- ---------------------------------------------------------------------
--  Esta es una version SENCILLA de la Vista 3, pensada para aprender.
--  Usa solo conceptos basicos de SQL:
--    - SELECT / FROM
--    - JOIN (unir tablas)
--    - LEFT JOIN (unir aunque no haya coincidencia)
--    - COUNT() para contar
--    - GROUP BY para agrupar
--    - COALESCE() para reemplazar valores nulos por 0
--    - CASE para calcular condicionalmente
--    - ORDER BY para ordenar el resultado
--
--  NO usa temas avanzados como funciones de ventana (ROW_NUMBER),
--  subconsultas anidadas de varios niveles ni manejo de fechas.
--
--  Requiere: 01_schema.sql y 02_data.sql ejecutados antes.
-- =====================================================================

-- Seleccionamos la base de datos con la que vamos a trabajar.
USE proyecto_final_data_base;

-- CREATE OR REPLACE VIEW crea la vista; si ya existe, la reemplaza.
-- Una VISTA es como una "consulta guardada" a la que le ponemos nombre
-- y podemos consultar despues como si fuera una tabla.
CREATE OR REPLACE VIEW vista_medicamentos_mas_recetados AS

SELECT
    -- Datos basicos del medicamento (vienen de la tabla Medicamentos, alias "m").
    m.id_medicamento,
    m.nombre            AS medicamento,
    m.principio_activo,

    -- Cuantas veces fue RECETADO este medicamento.
    -- COALESCE cambia NULL por 0 (por si un medicamento nunca se receto).
    COALESCE(r.veces_recetado, 0) AS veces_recetado,

    -- Cuantas veces fue SURTIDO (vendido) este medicamento.
    COALESCE(v.veces_surtido, 0)  AS veces_surtido,

    -- Porcentaje de conversion = (veces surtido / veces recetado) * 100.
    -- Usamos CASE para EVITAR dividir entre cero:
    --   si nunca se receto (0), devolvemos 0 en lugar de calcular.
    CASE
        WHEN COALESCE(r.veces_recetado, 0) = 0 THEN 0
        ELSE ROUND(COALESCE(v.veces_surtido, 0) * 100.0 / r.veces_recetado, 2)
    END AS porcentaje_conversion

-- Partimos de la tabla Medicamentos (le damos el alias "m").
FROM Medicamentos m

-- ---------------------------------------------------------------------
-- SUBCONSULTA 1: contar cuantas veces se receto cada medicamento.
-- Detalles_Receta tiene una fila por cada medicamento dentro de una receta,
-- asi que contar sus filas nos da las "veces recetado".
-- La subconsulta agrupa por medicamento y cuenta; luego la unimos con LEFT JOIN.
-- Usamos LEFT JOIN para que aparezcan TODOS los medicamentos, aunque no
-- tengan recetas (en ese caso el conteo sera NULL y COALESCE lo pone en 0).
-- ---------------------------------------------------------------------
LEFT JOIN (
    SELECT
        medicamento,
        COUNT(*) AS veces_recetado
    FROM Detalles_Receta
    GROUP BY medicamento
) AS r ON r.medicamento = m.id_medicamento

-- ---------------------------------------------------------------------
-- SUBCONSULTA 2: contar cuantas veces se surtio (vendio) cada medicamento.
-- Misma idea, pero sobre la tabla Detalles_Venta.
-- ---------------------------------------------------------------------
LEFT JOIN (
    SELECT
        medicamento,
        COUNT(*) AS veces_surtido
    FROM Detalles_Venta
    GROUP BY medicamento
) AS v ON v.medicamento = m.id_medicamento

-- Ordenamos: primero los mas recetados, y a igualdad, los mas surtidos.
ORDER BY veces_recetado DESC, veces_surtido DESC;


-- =====================================================================
--  COMO USAR LA VISTA
--  Una vez creada, se consulta como si fuera una tabla normal:
-- =====================================================================
-- SELECT * FROM vista_medicamentos_mas_recetados;
