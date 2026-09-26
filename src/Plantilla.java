import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Motor de plantillas minimo: sustituye marcadores {@code {{CLAVE}}} dentro de
 * {@code web/plantilla.html}.
 *
 * Reglas del motor (requisito 5.5):
 * <ul>
 *   <li>Un marcador es exactamente {@code {{CLAVE}}} con CLAVE en mayusculas,
 *       digitos o guion bajo; cualquier otra secuencia se deja intacta.</li>
 *   <li>La sustitucion es de una sola pasada sobre la plantilla: el texto
 *       insertado nunca se vuelve a analizar, por lo que un valor que contenga
 *       los caracteres <code>{{</code> (CSS, JavaScript o un dato de la base)
 *       no produce un falso marcador sin resolver ni una segunda sustitucion.</li>
 *   <li>Si queda algun marcador sin valor, se lanza {@link IllegalStateException}
 *       con la lista completa de marcadores pendientes, no solo el primero.</li>
 *   <li>Si se entrega una clave que la plantilla no usa, tambien se falla, con un
 *       mensaje distinto que identifica el otro tipo de error.</li>
 *   <li>Un valor vacio es valido: {@code {{SCRIPT}}} se resuelve a la cadena
 *       vacia cuando se genera con {@code --sinScript}.</li>
 * </ul>
 */
public final class Plantilla {

    /** Marcador aceptado: dos llaves, clave en mayusculas, dos llaves. */
    private static final Pattern MARCADOR = Pattern.compile("\\{\\{([A-Z][A-Z0-9_]*)\\}\\}");

    private Plantilla() {
    }

    /**
     * Sustituye cada marcador {@code {{CLAVE}}} de la plantilla por su valor.
     *
     * @param plantilla texto de la plantilla; no nulo
     * @param valores   valores por clave, sin las llaves; no nulo y sin valores nulos
     * @return la plantilla con todos los marcadores resueltos
     * @throws IllegalStateException    si queda algun marcador sin resolver o si
     *                                  alguna clave entregada no se usa
     * @throws IllegalArgumentException si algun valor es nulo
     */
    public static String render(String plantilla, Map<String, String> valores) {
        if (plantilla == null) {
            throw new IllegalArgumentException("Plantilla: el texto de la plantilla es nulo.");
        }
        if (valores == null) {
            throw new IllegalArgumentException("Plantilla: el mapa de valores es nulo.");
        }
        for (Map.Entry<String, String> entrada : valores.entrySet()) {
            if (entrada.getValue() == null) {
                throw new IllegalArgumentException(
                        "Plantilla: valor nulo para la clave " + entrada.getKey() + ".");
            }
        }

        // Una sola pasada: se copia el texto literal y se anexa el valor tal cual,
        // de modo que el contenido insertado jamas se vuelve a analizar.
        StringBuilder salida = new StringBuilder(plantilla.length() + 1024);
        Set<String> usadas = new LinkedHashSet<>();
        Matcher m = MARCADOR.matcher(plantilla);
        int cursor = 0;
        while (m.find()) {
            String clave = m.group(1);
            String valor = valores.get(clave);
            if (valor == null) {
                continue; // marcador sin valor: se deja intacto y se reporta al final
            }
            salida.append(plantilla, cursor, m.start());
            salida.append(valor);
            cursor = m.end();
            usadas.add(clave);
        }
        salida.append(plantilla, cursor, plantilla.length());

        List<String> pendientes = new ArrayList<>();
        for (String marcador : marcadoresPendientes(plantilla)) {
            String clave = marcador.substring(2, marcador.length() - 2);
            if (!valores.containsKey(clave) && !pendientes.contains(marcador)) {
                pendientes.add(marcador);
            }
        }

        List<String> sinUsar = new ArrayList<>();
        for (String clave : valores.keySet()) {
            if (!usadas.contains(clave)) {
                sinUsar.add(clave);
            }
        }

        if (!pendientes.isEmpty() || !sinUsar.isEmpty()) {
            StringBuilder mensaje = new StringBuilder("Plantilla: sustitucion incompleta.");
            if (!pendientes.isEmpty()) {
                mensaje.append(" Marcadores sin resolver: ").append(String.join(", ", pendientes)).append('.');
            }
            if (!sinUsar.isEmpty()) {
                mensaje.append(" Claves entregadas que la plantilla no usa: ")
                        .append(String.join(", ", sinUsar)).append('.');
            }
            throw new IllegalStateException(mensaje.toString());
        }

        return salida.toString();
    }

    /**
     * Lista, en orden de aparicion y con las llaves incluidas, todos los
     * marcadores {@code {{CLAVE}}} presentes en un texto.
     *
     * Sirve tanto para construir el mensaje de error de {@link #render} como para
     * que el generador verifique que el documento final no conserva marcadores.
     *
     * @param salida texto a inspeccionar; nulo se trata como vacio
     * @return marcadores encontrados, con repeticiones
     */
    static List<String> marcadoresPendientes(String salida) {
        List<String> encontrados = new ArrayList<>();
        if (salida == null) {
            return encontrados;
        }
        Matcher m = MARCADOR.matcher(salida);
        while (m.find()) {
            encontrados.add(m.group());
        }
        return encontrados;
    }
}
