# Guidelines para poblar datos realistas

Estas reglas se derivan de los **Requerimientos - Farmacia** (Instrucciones 2:
3 Vistas, 3 Stored Procedures y 2 Triggers) y sirven para agregar más datos de
prueba coherentes al script `farmacia_consultorio_v1_datos.sql`.

El objetivo NO es solo llegar a 10+ registros, sino que los datos permitan que
las consultas de las 3 vistas y los reportes devuelvan resultados significativos.

---

## Reglas generales de formato

1. **IDs con patrón fijo:** `PREFIJO-000000` (3 letras + guion + 6 dígitos).
   - `EMP` empleados, `MDC` médicos, `PAC` pacientes, `HCL` historiales,
     `CND` condiciones, `DIA` diagnósticos, `CON` consultas, `MED` medicamentos,
     `ITX` interacciones, `REC` recetas, `PRV` proveedores, `ORD` órdenes,
     `LOT` lotes, `INV` inventario, `VEN` ventas, `AUD` auditoría (12 dígitos).
2. **Continuar la numeración**, nunca reusar un ID ya existente.
3. **Fechas coherentes en el tiempo:** registro < consulta < receta < venta.
   Vencimiento de receta = emisión + 30 días. Caducidad de lote siempre futura
   salvo que se quiera simular un lote vencido.
4. **Texto sin acentos** en los INSERT (evita problemas de collation al importar).
5. **Respetar el orden de FK:** insertar padres antes que hijos
   (Empleados → Medicos → ... → Detalles_Venta → Auditoria_Inventario).

---

## Reglas por VISTA (para que el reporte tenga sentido)

### Vista 1 — Historial Clínico Completo del Paciente
Necesita: paciente + edad + contacto, consultas con fecha/motivo, diagnóstico y
tratamiento, medicamentos recetados con dosis/duración, alergias y
contraindicaciones, y médico responsable.

- Cada paciente que se agregue debe tener **su `Historiales_Clinicos`** (1:1).
- Al menos parte de los pacientes deben tener **`Historial_Condicion`** (alergia
  y/o contraindicación) para que la columna "alergias/contraindicaciones" no
  salga vacía.
- Un paciente realista tiene **varias consultas en distintas fechas** (historial),
  no solo una. Genera 1–3 consultas por paciente para simular seguimiento.
- Toda consulta debe tener **diagnóstico** (FK obligatoria) y de preferencia una
  **receta** con 1–3 medicamentos en `Detalles_Receta`.

### Vista 2 — Inventario con Alertas de Stock Mínimo
Necesita: nombre/presentación/concentración, stock actual vs mínimo, estado
(suficiente/bajo/crítico/agotado), lote y caducidad más próxima, proveedor y
última reposición, consumo promedio mensual.

- Distribuir los `Inventario.stock_actual` para que existan los 4 estados:
  - **suficiente:** stock_actual > stock_minimo con holgura.
  - **bajo:** stock_actual ligeramente por encima o igual a punto_reorden.
  - **crítico:** stock_actual <= stock_minimo pero > 0.
  - **agotado:** stock_actual = 0.
- `Medicamentos.stock_minimo`, `stock_maximo`, `punto_reorden` y
  `consumo_promedio_mensual` deben estar poblados (se usan en el estado y en SP3).
- Incluir **varios lotes por medicamento** (distinta caducidad) para probar el
  criterio "vencimiento más próximo". Al menos un lote **ya vencido**.
- `fecha_ultima_reposicion` debe ser consistente con alguna `Ordenes_Compra`
  recibida.

### Vista 3 — Medicamentos Más Recetados y Surtidos
Necesita: medicamento + principio activo, veces recetado, veces surtido, % de
conversión receta–venta, médicos que más lo recetan, tendencia de consumo.

- Para que el ranking tenga sentido, algunos medicamentos deben aparecer en
  **muchos `Detalles_Receta`** (muy recetados) y otros en pocos.
- La **conversión receta–venta** exige que existan recetas **no surtidas**
  (estado `emitida` o `vencida`, sin venta asociada) junto a recetas surtidas.
  Deja ~20–30% de recetas sin venta.
- Para "médicos que más lo recetan", concentra ciertas recetas de un medicamento
  en 1–2 médicos.
- Para "tendencia de consumo", reparte ventas de un mismo medicamento en
  **meses distintos** (creciente/estable/decreciente).

---

## Reglas por STORED PROCEDURE / TRIGGER (casos de prueba a incluir)

### SP1 / Trigger 1 — Registrar/validar receta
Deben existir datos que permitan probar tanto el camino feliz como los rechazos:

- **Paciente inactivo** (`activo = FALSE`): al menos 1, para probar rechazo.
- **Médico con cédula vencida** (`cedula_vigencia` pasada): al menos 1.
- **Medicamento inactivo** (`activo = FALSE`): al menos 1.
- **Contraindicación med–condición:** que un paciente tenga una condición
  (`Historial_Condicion`) que choque con un medicamento vía
  `Medicamento_Condicion` (ej. paciente alérgico a penicilina + amoxicilina).
- **Interacción peligrosa:** una receta que combine dos medicamentos con una
  fila en `Interacciones_Medicamentosas` de nivel `severa`.
- **Dosis/duración fuera de rango:** algún `Detalles_Receta.duracion` mayor que
  `Medicamentos.duracion_maxima_dias`.

### SP2 — Surtir receta y actualizar inventario
- Recetas **vigentes y no surtidas** (para surtir): estado `emitida`.
- Recetas **ya surtidas** (para probar rechazo por doble surtido).
- Al menos un medicamento con **stock insuficiente** (para la alerta de
  reposición) y un **lote vencido** (para rechazo por caducidad).
- Registrar la **venta asociada a la receta** (`Ventas.receta`) y sus
  `Detalles_Venta` con el `lote` dispensado.

### SP3 — Orden de reposición por stock mínimo
- Varios medicamentos con `stock_actual <= stock_minimo` (candidatos a orden).
- Al menos uno con una **orden pendiente ya existente** (para probar que no se
  duplique).
- Órdenes en distintos `estado` (pendiente, enviada, recibida_total, cancelada).

### Trigger 2 — Auditoría de inventario
- Poblar `Auditoria_Inventario` con los 5 `tipo_movimiento`:
  surtido, reposicion, ajuste, merma, vencimiento.
- Cada fila con `stock_anterior`/`stock_nuevo` coherentes y con el documento
  asociado (`receta` para surtido, `orden_compra` para reposición).

---

## Checklist antes de dar por completo el dataset

- [ ] Cada paciente tiene historial (1:1) y algunos con condiciones.
- [ ] Existen los 4 estados de abastecimiento en inventario.
- [ ] Hay lotes múltiples y al menos uno vencido.
- [ ] Hay recetas surtidas y no surtidas (para conversión).
- [ ] Hay al menos 1 paciente inactivo, 1 médico con cédula vencida, 1
      medicamento inactivo.
- [ ] Hay al menos 1 contraindicación y 1 interacción severa reproducibles.
- [ ] Auditoría cubre los 5 tipos de movimiento.
- [ ] Todas las FK apuntan a registros existentes; sin duplicar PKs.
