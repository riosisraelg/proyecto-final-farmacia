/**
 * Rango de visibilidad de una columna en la estrategia responsiva.
 *
 * Se traduce a las clases CSS {@code col-1}, {@code col-2} y {@code col-3}:
 * las columnas TERCIARIA se ocultan primero y las SECUNDARIA despues, mientras
 * que las ESENCIAL permanecen visibles en todos los anchos de pantalla.
 */
public enum Prioridad {
    ESENCIAL,
    SECUNDARIA,
    TERCIARIA
}
