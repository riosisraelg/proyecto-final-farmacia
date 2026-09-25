Farmacia con Consultorio Médico –

Ges(cid:415)ón de Consultas y Medicamentos Recetados

VISTAS

Vista 1: Historial Clínico Completo del Paciente

Obje(cid:415)vo:
Brindar a los médicos del consultorio una vista consolidada del historial clínico de cada paciente,
mostrando  consultas  previas,  diagnós(cid:415)cos,  tratamientos  indicados,  recetas  emi(cid:415)das  y  alergias
conocidas. Esto elimina la pérdida de historiales en expedientes (cid:304)sicos, permite una atención más
segura y facilita la con(cid:415)nuidad del tratamiento entre consultas.

Información a visualizar:

  Datos del paciente (iden(cid:415)ﬁcación, edad, contacto)



Fecha y mo(cid:415)vo de cada consulta

  Diagnós(cid:415)co y tratamiento indicado

  Medicamentos recetados con dosis y duración

  Alergias y contraindicaciones registradas

  Médico responsable de cada consulta

Vista 2: Inventario de Medicamentos con Alertas de Stock Mínimo

Obje(cid:415)vo:
Permi(cid:415)r a la farmacia y al área de compras conocer en (cid:415)empo real el inventario disponible de cada
medicamento,  mostrando  stock  actual,  stock  mínimo  conﬁgurado,  lote,  fecha  de  vencimiento  y
estado  de  abastecimiento.  Facilita  detectar  desabastecimiento  de  fármacos  clave  y  programar
reposiciones a (cid:415)empo.

Información a visualizar:

  Nombre del medicamento, presentación y concentración



Stock actual y stock mínimo

  Estado (suﬁciente, bajo, crí(cid:415)co, agotado)



Lote y fecha de vencimiento más próxima

  Proveedor y úl(cid:415)ma fecha de reposición

  Consumo promedio mensual

Vista 3: Reporte de Medicamentos Más Recetados y Sur(cid:415)dos

Obje(cid:415)vo:
Proporcionar a la gerencia médica y comercial un resumen de los medicamentos más recetados por
los médicos y más sur(cid:415)dos por la farmacia en un período, junto con su nivel de conversión receta–
venta. Sirve para tomar decisiones de compra, detectar recetas  no sur(cid:415)das y evaluar la demanda
real del consultorio.

Información a visualizar:

  Medicamento y principio ac(cid:415)vo

  Can(cid:415)dad de veces recetado por período

  Can(cid:415)dad de veces sur(cid:415)do en farmacia

  Porcentaje de conversión receta–venta

  Médicos que más lo recetan

  Tendencia de consumo (creciente, estable, decreciente)

STORED PROCEDURES

SP 1: Registrar Consulta y Emi(cid:415)r Receta Médica

En(cid:415)dad que afecta: Consultas / Recetas / Pacientes / Médicos / Medicamentos

Regla de negocio que implementa:

Antes de registrar una consulta y emi(cid:415)r una receta, el procedimiento debe validar que:

  El paciente exista y esté ac(cid:415)vo en el sistema.

  El médico exista, esté ac(cid:415)vo y tenga licencia vigente.



Los medicamentos recetados existan en el catálogo y estén disponibles en inventario.

  No exista interacción o contraindicación entre los medicamentos recetados y las alergias del

paciente.



La dosis y duración del tratamiento sean válidas según el medicamento.

Si alguna validación falla, rechaza la emisión con un mensaje explica(cid:415)vo. Si todo es correcto, inserta
la consulta, genera la receta y descuenta del inventario los medicamentos sur(cid:415)dos en el momento.

SP 2: Sur(cid:415)r Receta y Actualizar Inventario

En(cid:415)dad que afecta: Recetas / Inventario / Ventas / Medicamentos

Regla de negocio que implementa:

Al sur(cid:415)r una receta en la farmacia, el procedimiento debe:

  Veriﬁcar que la receta exista, esté vigente y no haya sido sur(cid:415)da previamente.

  Validar que haya stock suﬁciente de cada medicamento recetado.

  Veriﬁcar que el lote a dispensar no esté vencido.

  Calcular el total a pagar según precios vigentes y aplicar descuentos si corresponde.

  Descontar del inventario los medicamentos dispensados.

  Registrar la venta asociada a la receta y actualizar el estado de la receta a "sur(cid:415)da".

Si el stock es insuﬁciente, el procedimiento genera una alerta de reposición y sugiere alterna(cid:415)vas
terapéu(cid:415)cas equivalentes.

SP 3: Generar Orden de Reposición por Stock Mínimo

En(cid:415)dad que afecta: Inventario / Compras / Proveedores / Medicamentos

Regla de negocio que implementa:

Permite generar automá(cid:415)camente órdenes de reposición para los medicamentos cuyo stock esté
por debajo del mínimo conﬁgurado. Antes de generar la orden:

  Veriﬁca que el medicamento esté ac(cid:415)vo en el catálogo.

  Valida que el stock actual sea menor o igual al stock mínimo.

  Considera el consumo promedio mensual y el (cid:415)empo de entrega del proveedor.

  Evita duplicar órdenes de reposición pendientes para el mismo medicamento.

El  procedimiento  genera  la  orden  de  compra,  no(cid:415)ﬁca  al  proveedor  y  registra  la  solicitud  en  el
sistema.

TRIGGERS

Trigger 1: BEFORE INSERT – Validación de Nueva Receta

Evento que lo dispara: Inserción en la tabla de Recetas

Comportamiento:
Antes de insertar una nueva receta, el trigger invoca al Stored Procedure de validación para veriﬁcar
que:

  El paciente y el médico existan y estén ac(cid:415)vos.



Los medicamentos recetados existan en el catálogo.

  No existan interacciones peligrosas entre los medicamentos recetados.

  No existan contraindicaciones con las alergias registradas del paciente.



La dosis y duración estén dentro de los rangos permi(cid:415)dos.

Si la  validación  falla, el trigger  cancela  la inserción y  lanza  un  mensaje  de  error. Esto  garan(cid:415)za  la
seguridad del paciente y evita errores en la dispensación.

Trigger 2: AFTER UPDATE – Auditoría de Movimientos de Inventario

Evento que lo dispara: Actualización en la tabla de Inventario (stock)

Comportamiento:
Después de que se modiﬁca el stock de un medicamento (por sur(cid:415)do de receta, reposición, ajuste
por vencimiento o merma), el trigger registra en una tabla de auditoría/log:





ID del medicamento y lote

Stock anterior y stock nuevo

  Tipo de movimiento (sur(cid:415)do, reposición, ajuste, merma, vencimiento)



Fecha y hora del movimiento

  Usuario o proceso que realizó la modiﬁcación

  Receta o documento de compra asociado

Esto permite trazabilidad completa del inventario, facilita auditorías sanitarias y ayuda a detectar
pérdidas o errores en la dispensación.

