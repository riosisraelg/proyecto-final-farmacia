import java.util.Objects;

/**
 * Metadato de una columna de una vista, descubierto desde
 * {@code ResultSetMetaData} y completado con las pistas de {@link Catalogo}.
 *
 * @param nombre     nombre de la columna en la base de datos
 * @param etiqueta   texto humano mostrado en el encabezado y en
 *                   {@code data-etiqueta}; nunca vacio
 * @param tipo       tipo de presentacion
 * @param prioridad  rango de visibilidad responsiva
 */
public record Columna(String nombre, String etiqueta, TipoCol tipo, Prioridad prioridad) {

    public Columna {
        Objects.requireNonNull(nombre, "nombre");
        Objects.requireNonNull(etiqueta, "etiqueta");
        Objects.requireNonNull(tipo, "tipo");
        Objects.requireNonNull(prioridad, "prioridad");
        if (nombre.isBlank()) {
            throw new IllegalArgumentException("El nombre de la columna no puede estar vacio");
        }
        if (etiqueta.isBlank()) {
            throw new IllegalArgumentException("La etiqueta de la columna '" + nombre + "' no puede estar vacia");
        }
    }
}
