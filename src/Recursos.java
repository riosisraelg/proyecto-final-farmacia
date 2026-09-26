import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;

/**
 * Lectura de las fuentes autoradas de {@code web/} y minificacion conservadora
 * de CSS.
 *
 * La lectura falla de inmediato (requisito 13.2): si la plantilla o la hoja de
 * estilos no se puede leer, se lanza {@link UncheckedIOException} con la ruta
 * afectada y el generador lo traduce a codigo de salida 3 antes de abrir
 * cualquier conexion.
 */
public final class Recursos {

    private Recursos() {
    }

    /**
     * Lee un archivo de texto en UTF-8.
     *
     * @param archivo ruta del archivo; no nula
     * @return el contenido, sin la marca de orden de bytes inicial si la hubiera
     * @throws UncheckedIOException     si el archivo falta, no es un archivo regular
     *                                  o no se puede leer
     * @throws IllegalArgumentException si la ruta es nula
     */
    public static String leer(Path archivo) {
        if (archivo == null) {
            throw new IllegalArgumentException("Recursos: la ruta del archivo es nula.");
        }
        if (!Files.isRegularFile(archivo)) {
            throw new UncheckedIOException(
                    "Recursos: no se encontro el archivo " + archivo + ".",
                    new NoSuchFileException(archivo.toString()));
        }
        try {
            String contenido = Files.readString(archivo, StandardCharsets.UTF_8);
            if (!contenido.isEmpty() && contenido.charAt(0) == '\uFEFF') {
                contenido = contenido.substring(1);
            }
            return contenido;
        } catch (IOException e) {
            throw new UncheckedIOException("Recursos: no se pudo leer " + archivo + ".", e);
        }
    }

    /**
     * Quita comentarios {@code /* ... *&#47;} y lineas en blanco de una hoja de
     * estilos.
     *
     * Es deliberadamente conservadora: no reescribe selectores, no colapsa los
     * espacios dentro de los valores y no altera la semantica. Los comentarios se
     * detectan solo fuera de cadenas entre comillas, de modo que un valor como
     * {@code content: "/*"} o una ruta {@code url("a/*b")} queda intacta.
     *
     * @param css hoja de estilos; nula se trata como cadena vacia
     * @return la hoja sin comentarios ni lineas vacias
     */
    public static String minificarCss(String css) {
        if (css == null || css.isEmpty()) {
            return "";
        }

        StringBuilder sinComentarios = new StringBuilder(css.length());
        char comilla = 0;      // comilla abierta, 0 fuera de cadena
        boolean comentario = false;
        for (int i = 0; i < css.length(); i++) {
            char c = css.charAt(i);
            if (comentario) {
                if (c == '*' && i + 1 < css.length() && css.charAt(i + 1) == '/') {
                    comentario = false;
                    i++;
                }
                continue;
            }
            if (comilla != 0) {
                sinComentarios.append(c);
                if (c == '\\' && i + 1 < css.length()) {
                    sinComentarios.append(css.charAt(i + 1));
                    i++;
                } else if (c == comilla) {
                    comilla = 0;
                }
                continue;
            }
            if (c == '"' || c == '\'') {
                comilla = c;
                sinComentarios.append(c);
                continue;
            }
            if (c == '/' && i + 1 < css.length() && css.charAt(i + 1) == '*') {
                comentario = true;
                i++;
                continue;
            }
            sinComentarios.append(c);
        }

        StringBuilder resultado = new StringBuilder(sinComentarios.length());
        for (String linea : sinComentarios.toString().split("\n", -1)) {
            if (linea.isBlank()) {
                continue;
            }
            resultado.append(linea).append('\n');
        }
        return resultado.toString();
    }
}
