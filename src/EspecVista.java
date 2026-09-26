import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * Pistas de presentacion de una vista. No declara la lista de columnas: esa se
 * descubre desde {@code ResultSetMetaData}, de modo que un cambio en el
 * {@code SELECT} de la vista no obliga a tocar codigo Java.
 *
 * <p>El registro es profundamente inmutable: el constructor copia los conjuntos
 * y el mapa recibidos con {@code Set.copyOf} y {@code Map.copyOf}, cuyas vistas
 * son no modificables.</p>
 *
 * @param id                  slug unico usado como ancla y como {@code id} de seccion
 * @param titulo              encabezado visible de la seccion
 * @param subtitulo           descripcion breve bajo el titulo
 * @param vista               nombre del objeto SQL; debe cumplir
 *                            {@link Catalogo#IDENTIFICADOR_SQL}
 * @param ordenSql            clausula {@code ORDER BY} literal que hace
 *                            determinista la salida
 * @param columnasEsenciales  columnas siempre visibles
 * @param columnasTerciarias  columnas que se ocultan primero
 * @param etiquetas           sobrescrituras de etiqueta por nombre de columna
 * @param columnasEstado      columnas dibujadas como insignia monocroma
 */
public record EspecVista(
        String id,
        String titulo,
        String subtitulo,
        String vista,
        String ordenSql,
        Set<String> columnasEsenciales,
        Set<String> columnasTerciarias,
        Map<String, String> etiquetas,
        Set<String> columnasEstado) {

    public EspecVista {
        Objects.requireNonNull(id, "id");
        Objects.requireNonNull(titulo, "titulo");
        Objects.requireNonNull(subtitulo, "subtitulo");
        Objects.requireNonNull(vista, "vista");
        Objects.requireNonNull(ordenSql, "ordenSql");

        if (id.isBlank()) {
            throw new IllegalArgumentException("El id de la vista no puede estar vacio");
        }
        if (titulo.isBlank()) {
            throw new IllegalArgumentException("El titulo de la vista '" + id + "' no puede estar vacio");
        }
        if (!Catalogo.IDENTIFICADOR_SQL.matcher(vista).matches()) {
            throw new IllegalArgumentException("Nombre de vista invalido: " + vista);
        }

        // Copias defensivas no modificables (rechazan elementos nulos).
        columnasEsenciales = Set.copyOf(Objects.requireNonNull(columnasEsenciales, "columnasEsenciales"));
        columnasTerciarias = Set.copyOf(Objects.requireNonNull(columnasTerciarias, "columnasTerciarias"));
        etiquetas = Map.copyOf(Objects.requireNonNull(etiquetas, "etiquetas"));
        columnasEstado = Set.copyOf(Objects.requireNonNull(columnasEstado, "columnasEstado"));

        for (String columna : columnasTerciarias) {
            if (columnasEsenciales.contains(columna)) {
                throw new IllegalArgumentException(
                        "La columna '" + columna + "' de la vista '" + id
                        + "' no puede ser esencial y terciaria a la vez");
            }
        }
    }
}
