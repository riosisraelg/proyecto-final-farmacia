/**
 * Tipo de presentacion de una columna.
 *
 * Se deriva de {@code java.sql.Types} y de las pistas declaradas en
 * {@link Catalogo}: NUMERO y PORCENTAJE se alinean a la derecha con cifras
 * tabulares, FECHA se muestra tal como la entrega la base, y ESTADO se dibuja
 * como insignia monocroma.
 */
public enum TipoCol {
    TEXTO,
    NUMERO,
    FECHA,
    ESTADO,
    PORCENTAJE
}
