import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

/**
 * Contenido de una vista: sus columnas y sus filas de valores crudos, sin
 * escapar (el escapado ocurre una sola vez en el renderizador).
 *
 * <p>Invariante: cada fila tiene exactamente {@link #numeroColumnas()} cadenas
 * no nulas; un {@code NULL} de SQL se guarda como cadena vacia. El registro es
 * profundamente inmutable: el constructor copia las listas recibidas y los
 * accesores solo devuelven vistas no modificables.</p>
 *
 * @param columnas metadatos de columna, en el orden del {@code SELECT}
 * @param filas    filas de valores crudos, en el orden del {@code ORDER BY}
 */
public record TablaDatos(List<Columna> columnas, List<List<String>> filas) {

    public TablaDatos {
        Objects.requireNonNull(columnas, "columnas");
        Objects.requireNonNull(filas, "filas");

        // Copia defensiva profunda: List.copyOf rechaza elementos nulos y
        // devuelve una lista no modificable, tambien para cada fila interna.
        columnas = List.copyOf(columnas);

        List<List<String>> copiaFilas = new ArrayList<>(filas.size());
        int esperado = columnas.size();
        for (List<String> fila : filas) {
            Objects.requireNonNull(fila, "fila");
            if (fila.size() != esperado) {
                throw new IllegalArgumentException(
                        "La fila " + copiaFilas.size() + " tiene " + fila.size()
                        + " valores y se esperaban " + esperado);
            }
            copiaFilas.add(List.copyOf(fila));
        }
        filas = List.copyOf(copiaFilas);
    }

    /** Tabla sin columnas ni filas, util para paneles degradados y pruebas. */
    public static TablaDatos vacia() {
        return new TablaDatos(List.of(), List.of());
    }

    public int numeroFilas() {
        return filas.size();
    }

    public int numeroColumnas() {
        return columnas.size();
    }

    /**
     * Posicion de una columna por nombre. Prefiere la coincidencia exacta y, si
     * no existe, acepta una coincidencia sin distinguir mayusculas.
     *
     * @return el indice de la columna, o {@link Optional#empty()} si no aparece
     */
    public Optional<Integer> indiceDe(String nombreColumna) {
        if (nombreColumna == null) {
            return Optional.empty();
        }
        for (int i = 0; i < columnas.size(); i++) {
            if (columnas.get(i).nombre().equals(nombreColumna)) {
                return Optional.of(i);
            }
        }
        for (int i = 0; i < columnas.size(); i++) {
            if (columnas.get(i).nombre().equalsIgnoreCase(nombreColumna)) {
                return Optional.of(i);
            }
        }
        return Optional.empty();
    }
}
