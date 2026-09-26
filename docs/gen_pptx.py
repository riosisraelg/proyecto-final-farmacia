#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Genera la Presentacion Tecnica del Proyecto Final en PowerPoint (.pptx).

Estilo: MINIMALISTA MONOCROMATICO — texto NEGRO sobre fondo BLANCO.
Unico elemento institucional: el LOGO de Tecmilenio SOLO en la portada.

ALINEACION:
  - Secciones = las que dicta "Presentacion del Proyecto Final.md"
    (Exposicion oral: empresa, problematica, impacto, estrategia,
     como ayuda la BD, beneficios, importancia de...).
  - Contenido orientado a la RUBRICA evaluable (100 pts):
      1) Claridad del objetivo (SMART)
      2) Investigacion y analisis (problematica/impacto/estrategia fundamentados)
      3) Desarrollo y estructura (secuencia logica de secciones)
      4) Presentacion y comunicacion (diseno limpio, diagrama a pantalla completa)

Mismo contenido y orden que docs/latex/slides/slides.tex.

Uso:    .venv/bin/python docs/gen_pptx.py
Salida: docs/latex/slides/slides.pptx
"""

import os
import re
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE
from PIL import Image

# --- Rutas -----------------------------------------------------------
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
ATT = os.path.join(ROOT, "attachments")
LOGO = os.path.join(ATT, "Tecmilenio Logo.png")
ER = os.path.join(ATT, "WhatsApp Image 2026-09-25 at 09.53.27.jpeg")
OUT = os.path.join(HERE, "latex", "slides", "slides.pptx")

# --- Paleta monocromatica -------------------------------------------
BLACK = RGBColor(0x00, 0x00, 0x00)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
GRAY = RGBColor(0x40, 0x40, 0x40)
FONT = "Arial"

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)
SW, SH = prs.slide_width, prs.slide_height
BLANK = prs.slide_layouts[6]
MARGIN = Inches(0.7)
CONTENT_W = SW - 2 * MARGIN

_num = [0]  # contador de diapositivas para el pie


def add_slide():
    s = prs.slides.add_slide(BLANK)
    fill = s.background.fill
    fill.solid()
    fill.fore_color.rgb = WHITE
    return s


def add_title(slide, text):
    box = slide.shapes.add_textbox(MARGIN, Inches(0.45), CONTENT_W, Inches(0.9))
    tf = box.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    r = p.add_run()
    r.text = text
    r.font.size = Pt(30)
    r.font.bold = True
    r.font.name = FONT
    r.font.color.rgb = BLACK
    line = slide.shapes.add_connector(1, MARGIN, Inches(1.38),
                                      MARGIN + Inches(5.2), Inches(1.38))
    line.line.color.rgb = BLACK
    line.line.width = Pt(1.5)
    return box


def _add_runs(paragraph, text):
    tokens = re.split(r"(\*\*.*?\*\*|`.*?`)", text)
    for tok in tokens:
        if not tok:
            continue
        run = paragraph.add_run()
        if tok.startswith("**") and tok.endswith("**"):
            run.text = tok[2:-2]
            run.font.bold = True
            run.font.name = FONT
        elif tok.startswith("`") and tok.endswith("`"):
            run.text = tok[1:-1]
            run.font.name = "Courier New"
        else:
            run.text = tok
            run.font.name = FONT
        run.font.color.rgb = BLACK


def add_bullets(slide, items, top=Inches(1.7), left=MARGIN, width=CONTENT_W,
                size=20, height=Inches(5.2)):
    box = slide.shapes.add_textbox(left, top, width, height)
    tf = box.text_frame
    tf.word_wrap = True
    first = True
    for it in items:
        text, level = (it if isinstance(it, tuple) else (it, 0))
        p = tf.paragraphs[0] if first else tf.add_paragraph()
        first = False
        p.level = level
        p.space_after = Pt(8)
        prefix = "– " if level == 0 else "· "
        _add_runs(p, prefix + text)
        for run in p.runs:
            run.font.size = Pt(size if level == 0 else size - 3)
    return box


def add_block(slide, text, top, height=Inches(1.3)):
    """Recuadro (equivalente al block de beamer) con borde negro."""
    w = CONTENT_W
    shp = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, MARGIN, top, w, height)
    shp.fill.solid()
    shp.fill.fore_color.rgb = WHITE
    shp.line.color.rgb = BLACK
    shp.line.width = Pt(1)
    tf = shp.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = MSO_ANCHOR.MIDDLE
    tf.margin_left = Inches(0.2)
    tf.margin_right = Inches(0.2)
    p = tf.paragraphs[0]
    r = p.add_run()
    r.text = text
    r.font.size = Pt(18)
    r.font.name = FONT
    r.font.color.rgb = BLACK
    return shp


def add_paragraph_label(slide, text, top, size=18, bold=True):
    box = slide.shapes.add_textbox(MARGIN, top, CONTENT_W, Inches(0.5))
    tf = box.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    r = p.add_run()
    r.text = text
    r.font.bold = bold
    r.font.size = Pt(size)
    r.font.name = FONT
    r.font.color.rgb = BLACK
    return box


def add_capture_box(slide, caption, top=Inches(2.2), height=Inches(3.0)):
    w = Inches(9.5)
    left = (SW - w) // 2
    shp = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, left, top, w, height)
    shp.fill.solid()
    shp.fill.fore_color.rgb = WHITE
    shp.line.color.rgb = BLACK
    shp.line.width = Pt(1)
    tf = shp.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = MSO_ANCHOR.MIDDLE
    p = tf.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER
    r = p.add_run()
    r.text = f"[Captura de pantalla: {caption}]"
    r.font.italic = True
    r.font.size = Pt(16)
    r.font.name = FONT
    r.font.color.rgb = GRAY


def add_footer(slide):
    _num[0] += 1
    box = slide.shapes.add_textbox(MARGIN, SH - Inches(0.5), CONTENT_W, Inches(0.35))
    p = box.text_frame.paragraphs[0]
    r = p.add_run()
    r.text = "Farmacia con Consultorio Médico"
    r.font.size = Pt(10)
    r.font.name = FONT
    r.font.color.rgb = GRAY
    box2 = slide.shapes.add_textbox(SW - MARGIN - Inches(1.0), SH - Inches(0.5),
                                    Inches(1.0), Inches(0.35))
    p2 = box2.text_frame.paragraphs[0]
    p2.alignment = PP_ALIGN.RIGHT
    r2 = p2.add_run()
    r2.text = str(_num[0])
    r2.font.size = Pt(10)
    r2.font.name = FONT
    r2.font.color.rgb = GRAY


# =====================================================================
# 1. PORTADA (unico lugar con el logo)
# =====================================================================
s = add_slide()
with Image.open(LOGO) as im:
    lw, lh = im.size
logo_h = Inches(0.75)
logo_w = Emu(int(logo_h * lw / lh))
s.shapes.add_picture(LOGO, SW - MARGIN - logo_w, Inches(0.5), height=logo_h)
tb = s.shapes.add_textbox(Inches(1.0), Inches(2.6), SW - Inches(2.0), Inches(2.4))
tf = tb.text_frame
tf.word_wrap = True
for i, (text, size, bold, color) in enumerate([
    ("Farmacia con Consultorio Médico", 40, True, BLACK),
    ("Presentación Técnica del Proyecto Final — Base de Datos Relacional", 20, False, GRAY),
    ("", 10, False, BLACK),
    ("[Tu Nombre]  |  LSTI2311: Bases de Datos", 16, False, BLACK),
    ("26 de septiembre de 2026", 14, False, GRAY),
]):
    p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(6)
    r = p.add_run()
    r.text = text
    r.font.size = Pt(size)
    r.font.bold = bold
    r.font.name = FONT
    r.font.color.rgb = color

# =====================================================================
# 2. AGENDA
# =====================================================================
s = add_slide()
add_title(s, "Agenda")
agenda = [
    "La empresa", "Problemática actual", "Impacto",
    "Objetivo del proyecto", "Estrategia", "Modelo Entidad-Relación",
    "¿Cómo ayuda la BD? — Gestión de datos",
    "¿Cómo ayuda la BD? — Automatización",
    "Conexión Java (JDBC)", "Validación", "Beneficios", "Conclusión",
]
box = s.shapes.add_textbox(MARGIN, Inches(1.6), CONTENT_W, Inches(5.4))
tf = box.text_frame
tf.word_wrap = True
for i, a in enumerate(agenda, 1):
    p = tf.paragraphs[0] if i == 1 else tf.add_paragraph()
    p.space_after = Pt(4)
    r = p.add_run()
    r.text = f"{i}.  {a}"
    r.font.size = Pt(18)
    r.font.name = FONT
    r.font.color.rgb = BLACK
add_footer(s)

# =====================================================================
# 3. LA EMPRESA
# =====================================================================
s = add_slide()
add_title(s, "¿Qué empresa representamos?")
add_bullets(s, [
    "Consultorio médico con farmacia asociada.",
    "Atiende consultas, emite recetas y surte medicamentos en el mismo lugar.",
    "Áreas involucradas: consultorio (médicos), farmacia (dispensación), compras (proveedores) y administración.",
])
add_footer(s)

# =====================================================================
# 4. PROBLEMATICA ACTUAL
# =====================================================================
s = add_slide()
add_title(s, "¿Cuál es su problemática actual?")
add_bullets(s, [
    "Historiales clínicos en papel: se extravían y fragmentan la atención.",
    "Inventario sin control: desabasto de fármacos clave y mermas por caducidad.",
    "Recetas y ventas desvinculadas: no hay trazabilidad receta–venta.",
    "Procesos manuales: reposición tardía y errores de dispensación.",
])
add_footer(s)

# =====================================================================
# 5. IMPACTO
# =====================================================================
s = add_slide()
add_title(s, "¿Cuál es su impacto?")
add_bullets(s, [
    "**Clínico:** riesgo para el paciente por alergias/interacciones no detectadas.",
    "**Económico:** pérdidas por caducidad, desabasto y ventas no registradas.",
    "**Operativo:** decisiones de compra sin datos y auditorías difíciles.",
    "**Reputacional:** menor confianza del paciente en la atención.",
])
add_footer(s)

# =====================================================================
# 6. OBJETIVO DEL PROYECTO (SMART)  -> rubrica criterio 1
# =====================================================================
s = add_slide()
add_title(s, "Objetivo del proyecto (SMART)")
add_block(s, ("Implementar una base de datos relacional para el consultorio-farmacia "
              "que centralice historial clínico, inventario y ventas, con validaciones "
              "automáticas, reduciendo errores de dispensación y desabasto."),
          top=Inches(1.6), height=Inches(1.5))
add_bullets(s, [
    "**Específico:** historial, inventario y recetas en una sola base.",
    "**Medible:** 20 tablas, 3 vistas, 3 SP y 2 triggers operativos.",
    "**Alcanzable:** MySQL + acceso desde Java (JDBC).",
    "**Relevante:** ataca las causas de riesgo clínico y pérdidas.",
    "**Temporal:** entregable al cierre del proyecto final.",
], top=Inches(3.3), size=18, height=Inches(3.2))
add_footer(s)

# =====================================================================
# 7. ESTRATEGIA
# =====================================================================
s = add_slide()
add_title(s, "Estrategia: atacar la causa raíz operativa")
add_paragraph_label(s, "Primero la operación, luego la tecnología.", Inches(1.6), size=18)
add_bullets(s, [
    "Estandarizar el flujo: paciente → consulta → receta → surtido → venta → inventario → reposición.",
    "Definir reglas de negocio: vigencia de cédula médica, control de alergias/interacciones, stock mínimo y caducidad.",
    "Después, llevar esas reglas a la base de datos como restricciones, procedimientos y triggers.",
], top=Inches(2.2), height=Inches(4.0))
add_footer(s)

# =====================================================================
# 8. IMPORTANCIA DE...
# =====================================================================
s = add_slide()
add_title(s, "¿Cuál es la importancia de...?")
add_bullets(s, [
    "**Entender las reglas de negocio:** evita errores clínicos y define qué debe validar el sistema.",
    "**Mapear el flujo de información:** muestra qué datos se comparten entre consultorio, farmacia y compras.",
    "**Integrar operación y tecnología:** una sola fuente de verdad, sin islas de información.",
    "**Gestionar la ejecución de la estrategia:** vistas, SP y triggers garantizan que las reglas se cumplan.",
])
add_footer(s)

# =====================================================================
# 9. MODELO ER a PANTALLA COMPLETA (solo, sin titulo ni pie)
# =====================================================================
s = add_slide()
with Image.open(ER) as im:
    iw, ih = im.size
scale = min(SW / iw, SH / ih)
img_w = Emu(int(iw * scale))
img_h = Emu(int(ih * scale))
s.shapes.add_picture(ER, (SW - img_w) // 2, (SH - img_h) // 2, width=img_w, height=img_h)

# =====================================================================
# 10. MODELO ER: estructura (texto)
# =====================================================================
s = add_slide()
add_title(s, "Modelo Entidad-Relación: estructura")
box = s.shapes.add_textbox(MARGIN, Inches(1.7), CONTENT_W, Inches(4.6))
tf = box.text_frame
tf.word_wrap = True
p = tf.paragraphs[0]
r = p.add_run(); r.text = "20 tablas organizadas en:"
r.font.bold = True; r.font.size = Pt(20); r.font.name = FONT; r.font.color.rgb = BLACK
for t in [
    "Personas: Empleados, Médicos, Pacientes.",
    "Clínico: Historiales, Condiciones, Consultas, Recetas.",
    "Farmacia: Medicamentos, Lotes, Inventario.",
    "Comercial: Ventas, Proveedores, Órdenes de Compra.",
    "Auditoría: Auditoria_Inventario (LOG).",
]:
    p = tf.add_paragraph(); p.space_after = Pt(6); p.level = 1
    r = p.add_run(); r.text = "– " + t
    r.font.size = Pt(18); r.font.name = FONT; r.font.color.rgb = BLACK
p = tf.add_paragraph(); p.space_before = Pt(10)
r = p.add_run(); r.text = ("Claves primarias y foráneas por tabla; convención de IDs con prefijo "
                           "(p. ej. PAC-000001). Normalización 1FN–3FN.")
r.font.size = Pt(15); r.font.name = FONT; r.font.color.rgb = GRAY
add_footer(s)

# =====================================================================
# 11. ¿COMO AYUDA LA BD? - GESTION DE DATOS (Vistas)
# =====================================================================
s = add_slide()
add_title(s, "¿Cómo ayuda la BD en la gestión de los datos? (Vistas)")
add_bullets(s, [
    "**Vista 1 — Historial clínico completo del paciente.** Consolida consultas, diagnósticos, recetas, dosis y alergias.",
    "**Vista 2 — Inventario con alertas de stock mínimo.** Estado (suficiente/bajo/crítico/agotado), lote y caducidad más próxima.",
    "**Vista 3 — Medicamentos más recetados y surtidos.** Conversión receta–venta y tendencia de consumo para decidir compras.",
], top=Inches(1.7), height=Inches(3.0))
add_capture_box(s, "resultado de una vista en MySQL", top=Inches(4.7), height=Inches(2.1))
add_footer(s)

# =====================================================================
# 12. ¿COMO AYUDA LA BD? - AUTOMATIZACION (Stored Procedures)
# =====================================================================
s = add_slide()
add_title(s, "Automatización de procesos: Stored Procedures")
add_bullets(s, [
    "**SP1 — Registrar consulta y emitir receta.** Valida paciente activo, médico con cédula vigente y alergias; inserta consulta, receta y detalle.",
    "**SP2 — Surtir receta y actualizar inventario.** Verifica vigencia, asigna lote no vencido, registra la venta y descuenta stock automáticamente.",
    "**SP3 — Generar órdenes de reposición por stock mínimo.** Evalúa stock ≤ mínimo y crea la orden sin duplicados.",
])
add_footer(s)

# =====================================================================
# 13. AUTOMATIZACION Y TRAZABILIDAD (Triggers y LOG)
# =====================================================================
s = add_slide()
add_title(s, "Automatización y trazabilidad: Triggers y LOG")
add_bullets(s, [
    "**Trigger 1 — BEFORE INSERT en Detalles_Receta.** Bloquea recetas con contraindicaciones, interacciones o datos inválidos.",
    "**Trigger 2 — AFTER UPDATE en Inventario.** Registra cada movimiento de stock en la tabla LOG Auditoria_Inventario para trazabilidad total.",
], top=Inches(1.7), height=Inches(3.4))
add_paragraph_label(s, "La automatización aplica las reglas de negocio sin intervención manual.",
                    Inches(5.4), size=15, bold=False)
add_footer(s)

# =====================================================================
# 14. CONEXION JDBC
# =====================================================================
s = add_slide()
add_title(s, "Los datos en uso: conexión Java (JDBC)")
add_bullets(s, [
    "App.java conecta a MySQL (instancia gestionada en Aiven, SSL).",
    "Credenciales fuera del código (variables de entorno seguras).",
    "Consulta Pacientes y despliega el Dataset resultante.",
], top=Inches(1.7), height=Inches(1.8))
add_capture_box(s, "salida de la ejecución de App.java", top=Inches(3.6), height=Inches(2.6))
add_footer(s)

# =====================================================================
# 15. VALIDACION
# =====================================================================
s = add_slide()
add_title(s, "Validación: 3 ejemplos de SP y Triggers")
box = s.shapes.add_textbox(MARGIN, Inches(1.7), CONTENT_W, Inches(2.6))
tf = box.text_frame
tf.word_wrap = True
examples = [
    ("SP1:", " receta a paciente con alergia ⇒ el sistema la rechaza con mensaje de riesgo clínico."),
    ("SP2:", " surtir receta vigente ⇒ se registra la venta y disminuye el stock."),
    ("Trigger 2:", " tras el surtido ⇒ registro automático en Auditoria_Inventario."),
]
for i, (b, rest) in enumerate(examples, 1):
    p = tf.paragraphs[0] if i == 1 else tf.add_paragraph()
    p.space_after = Pt(8)
    r = p.add_run(); r.text = f"{i}.  "; r.font.size = Pt(19); r.font.name = FONT; r.font.color.rgb = BLACK
    r = p.add_run(); r.text = b; r.font.size = Pt(19); r.font.bold = True; r.font.name = FONT; r.font.color.rgb = BLACK
    r = p.add_run(); r.text = rest; r.font.size = Pt(19); r.font.name = FONT; r.font.color.rgb = BLACK
add_capture_box(s, "ejecución de los 3 ejemplos con su resultado", top=Inches(4.4), height=Inches(2.4))
add_footer(s)

# =====================================================================
# 16. BENEFICIOS
# =====================================================================
s = add_slide()
add_title(s, "¿Qué beneficios se obtendrán?")
add_bullets(s, [
    "**Atención más segura:** validaciones clínicas automáticas.",
    "**Menos pérdidas:** control de inventario, caducidades y reposición.",
    "**Trazabilidad:** vínculo receta–venta y auditoría de inventario.",
    "**Mejores decisiones:** reportes de consumo para compras.",
    "**Escalabilidad:** base para un sistema de gestión completo.",
])
add_footer(s)

# =====================================================================
# 17. CONCLUSION
# =====================================================================
s = add_slide()
add_title(s, "Conclusión")
add_bullets(s, [
    "El problema operativo se atacó antes de la solución tecnológica.",
    "La base de datos integra historial, inventario y ventas con reglas de negocio automatizadas.",
    "Resultado: atención más segura, menos pérdidas y trazabilidad total.",
])
add_footer(s)

# =====================================================================
# 18. GRACIAS
# =====================================================================
s = add_slide()
box = s.shapes.add_textbox(Inches(1.0), Inches(3.0), SW - Inches(2.0), Inches(1.6))
tf = box.text_frame
p = tf.paragraphs[0]
p.alignment = PP_ALIGN.CENTER
r = p.add_run(); r.text = "Gracias"
r.font.size = Pt(44); r.font.bold = True; r.font.name = FONT; r.font.color.rgb = BLACK
p = tf.add_paragraph(); p.alignment = PP_ALIGN.CENTER; p.space_before = Pt(10)
r = p.add_run(); r.text = "¿Preguntas?"
r.font.size = Pt(20); r.font.name = FONT; r.font.color.rgb = GRAY

prs.save(OUT)
print(f"OK -> {OUT}  ({len(prs.slides._sldIdLst)} slides)")
