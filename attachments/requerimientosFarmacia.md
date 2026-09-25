# Farmacia con Consultorio Médico – Gestión de Consultas y Medicamentos Recetados

## VISTAS

### Vista 1: Historial Clínico Completo del Paciente

**Objetivo:**
Brindar a los médicos del consultorio una vista consolidada del historial clínico de cada paciente, mostrando consultas previas, diagnósticos, tratamientos indicados, recetas emitidas y alergias conocidas. Esto elimina la pérdida de historiales en expedientes físicos, permite una atención más segura y facilita la continuidad del tratamiento entre consultas.

**Información a visualizar:**

- Datos del paciente (identificación, edad, contacto)
- Fecha y motivo de cada consulta
- Diagnóstico y tratamiento indicado
- Medicamentos recetados con dosis y duración
- Alergias y contraindicaciones registradas
- Médico responsable de cada consulta

### Vista 2: Inventario de Medicamentos con Alertas de Stock Mínimo

**Objetivo:**
Permitir a la farmacia y al área de compras conocer en tiempo real el inventario disponible de cada medicamento, mostrando stock actual, stock mínimo configurado, lote, fecha de vencimiento y estado de abastecimiento. Facilita detectar desabastecimiento de fármacos clave y programar reposiciones a tiempo.

**Información a visualizar:**

- Nombre del medicamento, presentación y concentración
- Stock actual y stock mínimo
- Estado (suficiente, bajo, crítico, agotado)
- Lote y fecha de vencimiento más próxima
- Proveedor y última fecha de reposición
- Consumo promedio mensual

### Vista 3: Reporte de Medicamentos Más Recetados y Surtidos

**Objetivo:**
Proporcionar a la gerencia médica y comercial un resumen de los medicamentos más recetados por los médicos y más surtidos por la farmacia en un período, junto con su nivel de conversión receta–venta. Sirve para tomar decisiones de compra, detectar recetas no surtidas y evaluar la demanda real del consultorio.

**Información a visualizar:**

- Medicamento y principio activo
- Cantidad de veces recetado por período
- Cantidad de veces surtido en farmacia
- Porcentaje de conversión receta–venta
- Médicos que más lo recetan
- Tendencia de consumo (creciente, estable, decreciente)

## STORED PROCEDURES

### SP 1: Registrar Consulta y Emitir Receta Médica

**Entidad que afecta:** Consultas / Recetas / Pacientes / Médicos / Medicamentos

**Regla de negocio que implementa:**

Antes de registrar una consulta y emitir una receta, el procedimiento debe validar que:

- El paciente exista y esté activo en el sistema.
- El médico exista, esté activo y tenga licencia vigente.
- Los medicamentos recetados existan en el catálogo y estén disponibles en inventario.
- No exista interacción o contraindicación entre los medicamentos recetados y las alergias del paciente.
- La dosis y duración del tratamiento sean válidas según el medicamento.

Si alguna validación falla, rechaza la emisión con un mensaje explicativo. Si todo es correcto, inserta la consulta, genera la receta y descuenta del inventario los medicamentos surtidos en el momento.

### SP 2: Surtir Receta y Actualizar Inventario

**Entidad que afecta:** Recetas / Inventario / Ventas / Medicamentos

**Regla de negocio que implementa:**

Al surtir una receta en la farmacia, el procedimiento debe:

- Verificar que la receta exista, esté vigente y no haya sido surtida previamente.
- Validar que haya stock suficiente de cada medicamento recetado.
- Verificar que el lote a dispensar no esté vencido.
- Calcular el total a pagar según precios vigentes y aplicar descuentos si corresponde.
- Descontar del inventario los medicamentos dispensados.
- Registrar la venta asociada a la receta y actualizar el estado de la receta a "surtida".

Si el stock es insuficiente, el procedimiento genera una alerta de reposición y sugiere alternativas terapéuticas equivalentes.

### SP 3: Generar Orden de Reposición por Stock Mínimo

**Entidad que afecta:** Inventario / Compras / Proveedores / Medicamentos

**Regla de negocio que implementa:**

Permite generar automáticamente órdenes de reposición para los medicamentos cuyo stock esté por debajo del mínimo configurado. Antes de generar la orden:

- Verifica que el medicamento esté activo en el catálogo.
- Valida que el stock actual sea menor o igual al stock mínimo.
- Considera el consumo promedio mensual y el tiempo de entrega del proveedor.
- Evita duplicar órdenes de reposición pendientes para el mismo medicamento.

El procedimiento genera la orden de compra, notifica al proveedor y registra la solicitud en el sistema.

## TRIGGERS

### Trigger 1: BEFORE INSERT – Validación de Nueva Receta

**Evento que lo dispara:** Inserción en la tabla de Recetas

**Comportamiento:**
Antes de insertar una nueva receta, el trigger invoca al Stored Procedure de validación para verificar que:

- El paciente y el médico existan y estén activos.
- Los medicamentos recetados existan en el catálogo.
- No existan interacciones peligrosas entre los medicamentos recetados.
- No existan contraindicaciones con las alergias registradas del paciente.
- La dosis y duración estén dentro de los rangos permitidos.

Si la validación falla, el trigger cancela la inserción y lanza un mensaje de error. Esto garantiza la seguridad del paciente y evita errores en la dispensación.

### Trigger 2: AFTER UPDATE – Auditoría de Movimientos de Inventario

**Evento que lo dispara:** Actualización en la tabla de Inventario (stock)

**Comportamiento:**
Después de que se modifica el stock de un medicamento (por surtido de receta, reposición, ajuste por vencimiento o merma), el trigger registra en una tabla de auditoría/log:

- ID del medicamento y lote
- Stock anterior y stock nuevo
- Tipo de movimiento (surtido, reposición, ajuste, merma, vencimiento)
- Fecha y hora del movimiento
- Usuario o proceso que realizó la modificación
- Receta o documento de compra asociado

Esto permite trazabilidad completa del inventario, facilita auditorías sanitarias y ayuda a detectar pérdidas o errores en la dispensación.
