import java.text.Normalizer;

/**
 * Utilidades de serializacion segura de texto hacia HTML.
 *
 * Tres operaciones, todas totales (nunca lanzan) y tolerantes a {@code null}:
 * <ul>
 *   <li>{@link #escape(String)} sustituye los cinco caracteres significativos
 *       de HTML por sus entidades.</li>
 *   <li>{@link #attr(String)} escapa y entrecomilla un valor de atributo.</li>
 *   <li>{@link #slug(String)} reduce cualquier texto a {@code [a-z0-9-]}
 *       plegando acentos.</li>
 * </ul>
 *
 * <p><b>Convencion de nulos:</b> un argumento {@code null} se trata como la
 * cadena vacia; ningun metodo devuelve {@code null} ni el literal "null".
 * Esta convencion es la misma en los tres metodos.</p>
 *
 * <p>Requisitos: 4.1 (entidades), 4.2 (ida y vuelta), 4.3 (texto inocuo
 * devuelto sin cambios), 4.7 (slug restringido a {@code [a-z0-9-]}).</p>
 */
public final class Html {

    private Html() {
        // Clase de utilidades: sin instancias.
    }

    /**
     * Sustituye {@code & < > " '} por {@code &amp; &lt; &gt; &quot; &#39;}.
     *
     * <p>Recorrido unico: el {@code StringBuilder} se crea solo al encontrar el
     * primer caracter significativo, por lo que un texto que no contiene
     * ninguno de los cinco se devuelve tal cual (criterio 4.3) y nunca se
     * produce doble escapado, ya que el {@code &} de las entidades emitidas no
     * se vuelve a inspeccionar (criterio 4.1).</p>
     *
     * @param texto texto crudo, posiblemente {@code null}
     * @return texto apto para insertarse en contenido o en un atributo HTML
     */
    public static String escape(String texto) {
        if (texto == null || texto.isEmpty()) {
            return "";
        }
        StringBuilder sb = null;
        int copiado = 0;
        final int n = texto.length();
        for (int i = 0; i < n; i++) {
            final String entidad;
            switch (texto.charAt(i)) {
                case '&' -> entidad = "&amp;";
                case '<' -> entidad = "&lt;";
                case '>' -> entidad = "&gt;";
                case '"' -> entidad = "&quot;";
                case '\'' -> entidad = "&#39;";
                default -> entidad = null;
            }
            if (entidad == null) {
                continue;
            }
            if (sb == null) {
                sb = new StringBuilder(n + 16);
            }
            sb.append(texto, copiado, i).append(entidad);
            copiado = i + 1;
        }
        if (sb == null) {
            return texto;
        }
        return sb.append(texto, copiado, n).toString();
    }

    /**
     * Escapa el valor y lo entrecomilla con comillas dobles, listo para
     * concatenarse tras {@code nombre=} en una etiqueta.
     *
     * @param valor valor crudo del atributo, posiblemente {@code null}
     * @return el valor escapado entre comillas dobles, p. ej. {@code "a &amp; b"}
     */
    public static String attr(String valor) {
        return "\"" + escape(valor) + "\"";
    }

    /**
     * Reduce un texto arbitrario a un identificador seguro.
     *
     * <p>Garantia (propiedad 15): la salida contiene exclusivamente caracteres
     * de {@code a-z}, {@code 0-9} y {@code -}; nunca empieza ni termina en
     * {@code -} y nunca contiene dos {@code -} seguidos. Los acentos se pliegan
     * a su letra base ("Critico" para "Crítico", "nono" para "Ñoño") y todo lo
     * demas (emoji, comillas, espacios, puntuacion) se descarta o se colapsa en
     * un unico separador. Un texto sin ningun caracter utilizable produce la
     * cadena vacia.</p>
     *
     * @param texto texto de origen, posiblemente {@code null}
     * @return identificador restringido a {@code [a-z0-9-]}
     */
    public static String slug(String texto) {
        if (texto == null || texto.isEmpty()) {
            return "";
        }
        // NFD separa la letra base de sus marcas diacriticas, que luego se
        // descartan por no pertenecer a [a-z0-9]; asi se pliegan los acentos.
        final String descompuesto = Normalizer.normalize(texto, Normalizer.Form.NFD);
        final int n = descompuesto.length();
        final StringBuilder sb = new StringBuilder(n);
        boolean separadorPendiente = false;
        for (int i = 0; i < n; i++) {
            final char c = descompuesto.charAt(i);
            final char base;
            if (c >= 'a' && c <= 'z') {
                base = c;
            } else if (c >= 'A' && c <= 'Z') {
                base = (char) (c - 'A' + 'a');
            } else if (c >= '0' && c <= '9') {
                base = c;
            } else if (esMarcaDiacritica(c)) {
                // Marca separada por NFD: se descarta sin cortar la palabra,
                // de modo que "Critico" salga de "Crítico".
                continue;
            } else {
                // Cualquier otro caracter actua como separador, pero solo se
                // materializa si despues aparece algo utilizable.
                if (sb.length() > 0) {
                    separadorPendiente = true;
                }
                continue;
            }
            if (separadorPendiente) {
                sb.append('-');
                separadorPendiente = false;
            }
            sb.append(base);
        }
        return sb.toString();
    }

    /** Indica si el caracter es una marca combinante (acento separado por NFD). */
    private static boolean esMarcaDiacritica(char c) {
        final int tipo = Character.getType(c);
        return tipo == Character.NON_SPACING_MARK
                || tipo == Character.COMBINING_SPACING_MARK
                || tipo == Character.ENCLOSING_MARK;
    }
}
