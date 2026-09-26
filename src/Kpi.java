import java.util.Objects;

/**
 * Chip numerico que resume una vista sobre su tabla.
 *
 * Siempre se calcula a partir de un {@link TablaDatos} ya leido, nunca con SQL
 * adicional, de modo que el resumen y la tabla no puedan discrepar.
 *
 * @param etiqueta  texto descriptivo del indicador
 * @param valor     valor ya formateado como texto
 * @param destacado true cuando el chip debe resaltarse (por ejemplo, alertas)
 */
public record Kpi(String etiqueta, String valor, boolean destacado) {

    public Kpi {
        Objects.requireNonNull(etiqueta, "etiqueta");
        Objects.requireNonNull(valor, "valor");
        if (etiqueta.isBlank()) {
            throw new IllegalArgumentException("La etiqueta del KPI no puede estar vacia");
        }
    }
}
