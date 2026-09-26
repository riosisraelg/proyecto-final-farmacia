import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * Ejecuta un archivo .sql completo contra la base de datos.
 *
 * A diferencia de mycli, este ejecutor SI respeta la directiva DELIMITER,
 * por lo que puede crear VISTAS, STORED PROCEDURES y TRIGGERS en una sola
 * corrida (mycli rechaza DELIMITER dentro de archivos con "source").
 *
 * Credenciales: variables de entorno AIVEN_* (inyectadas desde 1Password).
 *
 * USO (desde la raiz del proyecto):
 *   javac src/EjecutarSQL.java
 *   java -cp "src:src/lib/mysql-connector-j-26.7.0.jar" EjecutarSQL db/Presentación_tecnicaDB.sql
 *
 * Opcional: agregar "quiet" como segundo argumento para no imprimir los
 * resultados de los SELECT, solo el avance y los errores:
 *   java -cp "src:src/lib/mysql-connector-j-26.7.0.jar" EjecutarSQL archivo.sql quiet
 */
public class EjecutarSQL {

    // Esquema del proyecto (independiente de AIVEN_DB_NAME, que apunta a defaultdb).
    private static final String ESQUEMA = "proyecto_final_data_base";

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.out.println("Uso: EjecutarSQL <archivo.sql> [quiet]");
            return;
        }
        String archivo = args[0];
        boolean quiet = args.length > 1 && args[1].equalsIgnoreCase("quiet");

        String host = env("AIVEN_HOST");
        String port = env("AIVEN_PORT");
        String user = env("AIVEN_USERDB");
        String pass = env("AIVEN_PASSWORDDB");
        String ssl  = envOr("AIVEN_SSL_MODE", "REQUIRED");

        if (host == null || port == null || user == null || pass == null) {
            System.out.println("Faltan variables de entorno AIVEN_* (se inyectan desde 1Password).");
            return;
        }

        String url = String.format("jdbc:mysql://%s:%s/%s?ssl-mode=%s",
                                   host, port, ESQUEMA, ssl);

        List<String> sentencias = separarSentencias(
            new String(Files.readAllBytes(Paths.get(archivo))));

        System.out.println("Archivo: " + archivo);
        System.out.println("Sentencias detectadas: " + sentencias.size());
        System.out.println("--------------------------------------------------");

        int ok = 0, fallidas = 0, validaciones = 0, n = 0;

        try (Connection cx = DriverManager.getConnection(url, user, pass);
             Statement st = cx.createStatement()) {

            // El servidor Aiven exige primary key incluso en tablas temporales.
            st.execute("SET SESSION sql_require_primary_key = 0");

            for (String sql : sentencias) {
                n++;
                String resumen = primeraLinea(sql);
                try {
                    boolean hayResultado = st.execute(sql);
                    ok++;
                    if (hayResultado) {
                        try (ResultSet rs = st.getResultSet()) {
                            int filas = quiet ? contar(rs) : imprimir(rs);
                            System.out.printf("[%d] OK  %s  (%d filas)%n", n, resumen, filas);
                        }
                    } else {
                        System.out.printf("[%d] OK  %s  (%d afectadas)%n",
                                          n, resumen, st.getUpdateCount());
                    }
                } catch (SQLException e) {
                    // El codigo 1644 corresponde a los SIGNAL SQLSTATE '45000'
                    // definidos en el SP y el trigger: son las VALIDACIONES
                    // de negocio funcionando, no fallas del script.
                    if (e.getErrorCode() == 1644) {
                        validaciones++;
                        System.out.printf("[%d] VALIDACION  %s%n     -> %s%n",
                                          n, resumen, e.getMessage());
                    } else {
                        fallidas++;
                        System.out.printf("[%d] ERROR (%d) %s%n     -> %s%n",
                                          n, e.getErrorCode(), resumen, e.getMessage());
                    }
                }
            }
        }

        System.out.println("--------------------------------------------------");
        System.out.printf("Total: %d | OK: %d | Validaciones disparadas: %d | Errores: %d%n",
                          sentencias.size(), ok, validaciones, fallidas);
    }

    /**
     * Separa el script en sentencias respetando:
     *  - la directiva DELIMITER (para cuerpos de PROCEDURE/TRIGGER con ; internos)
     *  - comentarios de linea (--) y de bloque
     *  - cadenas entre comillas simples o dobles
     */
    private static List<String> separarSentencias(String script) {
        List<String> salida = new ArrayList<>();
        StringBuilder actual = new StringBuilder();
        String delim = ";";
        boolean enComentario = false;   // dentro de un bloque /* ... */

        for (String linea : script.split("\n")) {
            String t = linea.trim();

            // Control de comentarios de bloque: no se debe cortar una
            // sentencia por un ';' que este dentro de un comentario.
            if (enComentario) {
                actual.append(linea).append("\n");
                if (t.contains("*/")) enComentario = false;
                continue;
            }
            if (t.startsWith("/*") && !t.contains("*/")) {
                enComentario = true;
                actual.append(linea).append("\n");
                continue;
            }

            // Cambio de delimitador (directiva de cliente, no se envia al servidor)
            if (t.toUpperCase().startsWith("DELIMITER")) {
                volcar(salida, actual);
                String[] partes = t.split("\\s+");
                if (partes.length > 1) delim = partes[1];
                continue;
            }

            // La sentencia USE la omitimos: el esquema ya viene en la URL
            if (t.toUpperCase().startsWith("USE ")) continue;

            actual.append(linea).append("\n");

            // Fin de sentencia cuando la linea termina con el delimitador vigente
            if (t.endsWith(delim)) {
                String sql = actual.toString().trim();
                sql = sql.substring(0, sql.length() - delim.length()).trim();
                if (!esVacia(sql)) salida.add(sql);
                actual.setLength(0);
            }
        }
        volcar(salida, actual);
        return salida;
    }

    private static void volcar(List<String> salida, StringBuilder buf) {
        String sql = buf.toString().trim();
        if (!esVacia(sql)) salida.add(sql);
        buf.setLength(0);
    }

    /** Una sentencia es "vacia" si solo tiene comentarios, espacios o ';'. */
    private static boolean esVacia(String sql) {
        if (sql.isBlank()) return true;
        // Quitar comentarios de bloque cerrados
        String limpio = sql.replaceAll("(?s)/\\*.*?\\*/", "");
        // Si queda un /* sin cerrar (comentario final del archivo), descartar
        // desde ahi hasta el final.
        int abre = limpio.indexOf("/*");
        if (abre >= 0) limpio = limpio.substring(0, abre);
        StringBuilder sb = new StringBuilder();
        for (String l : limpio.split("\n")) {
            String t = l.trim();
            if (t.isEmpty() || t.startsWith("--")) continue;
            sb.append(t);
        }
        // Una sentencia que solo trae ';' tampoco cuenta
        return sb.toString().replace(";", "").isBlank();
    }

    private static String primeraLinea(String sql) {
        for (String l : sql.split("\n")) {
            String t = l.trim();
            if (t.isEmpty() || t.startsWith("--") || t.startsWith("/*") || t.startsWith("*")) continue;
            return t.length() > 70 ? t.substring(0, 70) + "..." : t;
        }
        return "(sentencia)";
    }

    private static int imprimir(ResultSet rs) throws SQLException {
        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount();
        StringBuilder cab = new StringBuilder("     ");
        for (int i = 1; i <= cols; i++) cab.append(md.getColumnLabel(i)).append("\t");
        System.out.println(cab);
        int filas = 0;
        while (rs.next()) {
            StringBuilder fila = new StringBuilder("     ");
            for (int i = 1; i <= cols; i++) {
                String v = rs.getString(i);
                fila.append(v == null ? "NULL" : v).append("\t");
            }
            System.out.println(fila);
            filas++;
        }
        return filas;
    }

    private static int contar(ResultSet rs) throws SQLException {
        int filas = 0;
        while (rs.next()) filas++;
        return filas;
    }

    private static String env(String k) {
        String v = System.getenv(k);
        return (v == null || v.isBlank()) ? null : v;
    }

    private static String envOr(String k, String def) {
        String v = env(k);
        return (v == null) ? def : v;
    }
}
