import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Catalogo de las tres vistas del proyecto, en el orden en que aparecen en la
 * pagina. Solo declara pistas de presentacion: la lista real de columnas se
 * descubre en tiempo de ejecucion desde {@code ResultSetMetaData}, y cualquier
 * columna no mencionada aqui se rinde como {@link Prioridad#SECUNDARIA} con una
 * etiqueta derivada de su nombre.
 *
 * <p>Los nombres de vista y las clausulas {@code ORDER BY} son constantes de
 * compilacion: nada proveniente del exterior llega al texto SQL, y el nombre se
 * revalida contra {@link #IDENTIFICADOR_SQL} antes de componer la consulta.</p>
 */
public final class Catalogo {

    /** Identificador SQL aceptado: sin comillas, sin espacios, maximo 64 caracteres. */
    static final Pattern IDENTIFICADOR_SQL = Pattern.compile("^[A-Za-z_][A-Za-z0-9_]{0,63}$");

    /** Las tres vistas, en orden de pagina. */
    public static final List<EspecVista> VISTAS = List.of(
            new EspecVista(
                    "historial-clinico",
                    "Vista 1: Historial clinico completo del paciente",
                    "Consultas, diagnosticos y recetas de cada paciente, con las alergias y "
                            + "contraindicaciones relevantes para el medicamento indicado.",
                    "vista_historial_clinico_completo",
                    "ORDER BY id_paciente, fecha_consulta, id_receta, medicamento",
                    Set.of("paciente", "fecha_consulta", "diagnostico", "medicamento", "estado_receta"),
                    Set.of("correo", "telefono", "contraindicaciones", "id_receta", "fecha_emision"),
                    Map.ofEntries(
                            Map.entry("id_paciente", "ID paciente"),
                            Map.entry("paciente", "Paciente"),
                            Map.entry("edad", "Edad"),
                            Map.entry("telefono", "Telefono"),
                            Map.entry("correo", "Correo"),
                            Map.entry("fecha_consulta", "Fecha de consulta"),
                            Map.entry("motivo", "Motivo"),
                            Map.entry("diagnostico", "Diagnostico"),
                            Map.entry("tratamiento_indicado", "Tratamiento indicado"),
                            Map.entry("id_receta", "ID receta"),
                            Map.entry("fecha_emision", "Fecha de emision"),
                            Map.entry("estado_receta", "Estado de la receta"),
                            Map.entry("medicamento", "Medicamento"),
                            Map.entry("dosis", "Dosis"),
                            Map.entry("frecuencia", "Frecuencia"),
                            Map.entry("duracion", "Duracion"),
                            Map.entry("cantidad_prescrita", "Cantidad prescrita"),
                            Map.entry("alergias", "Alergias"),
                            Map.entry("contraindicaciones", "Contraindicaciones"),
                            Map.entry("medico", "Medico")),
                    Set.of("estado_receta")),

            new EspecVista(
                    "inventario",
                    "Vista 2: Inventario con alertas de stock minimo",
                    "Existencias por medicamento frente a su stock minimo, con el lote proximo a "
                            + "caducar, el proveedor y el consumo promedio mensual.",
                    "vista_inventario_medicamentos_alerta",
                    "ORDER BY medicamento, id_medicamento",
                    Set.of("medicamento", "stock_actual", "stock_minimo", "estado_stock", "fecha_caducidad"),
                    Set.of("id_proveedor", "ultima_reposicion", "presentacion"),
                    Map.ofEntries(
                            Map.entry("id_medicamento", "ID medicamento"),
                            Map.entry("medicamento", "Medicamento"),
                            Map.entry("principio_activo", "Principio activo"),
                            Map.entry("presentacion", "Presentacion"),
                            Map.entry("concentracion", "Concentracion"),
                            Map.entry("stock_actual", "Stock actual"),
                            Map.entry("stock_minimo", "Stock minimo"),
                            Map.entry("estado_stock", "Estado del stock"),
                            Map.entry("lote_proximo_caducar", "Lote proximo a caducar"),
                            Map.entry("fecha_caducidad", "Fecha de caducidad"),
                            Map.entry("id_proveedor", "ID proveedor"),
                            Map.entry("proveedor", "Proveedor"),
                            Map.entry("ultima_reposicion", "Ultima reposicion"),
                            Map.entry("consumo_promedio_mensual", "Consumo promedio mensual")),
                    Set.of("estado_stock")),

            new EspecVista(
                    "mas-recetados",
                    "Vista 3: Medicamentos mas recetados y surtidos",
                    "Cuantas veces se receto cada medicamento, cuantas se surtio y el porcentaje "
                            + "de conversion entre ambas cifras.",
                    "vista_medicamentos_mas_recetados",
                    "ORDER BY veces_recetado DESC, medicamento, id_medicamento",
                    Set.of("medicamento", "veces_recetado", "veces_surtido", "porcentaje_conversion"),
                    Set.of("id_medicamento"),
                    Map.of(
                            "id_medicamento", "ID medicamento",
                            "medicamento", "Medicamento",
                            "principio_activo", "Principio activo",
                            "veces_recetado", "Veces recetado",
                            "veces_surtido", "Veces surtido",
                            "porcentaje_conversion", "Porcentaje de conversion"),
                    Set.of()));

    private Catalogo() {
        // Clase de utilidad: no se instancia.
    }
}
