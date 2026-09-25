import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.io.FileWriter;
import java.io.Writer;

/**
 * Genera un archivo HTML SIMPLE (sin estilos) con el contenido de las tres
 * vistas del proyecto. Consulta la base en Aiven usando las variables de
 * entorno inyectadas desde 1Password (AIVEN_*).
 *
 * Compilar y ejecutar (desde la raiz del proyecto, con el entorno de 1Password):
 *   javac src/GenerarVistasHTML.java
 *   java -cp "src:src/lib/mysql-connector-j-26.7.0.jar" GenerarVistasHTML
 *
 * Salida: docs/vistas.html
 */
public class GenerarVistasHTML {

    // Esquema donde viven las vistas del proyecto (independiente de AIVEN_DB_NAME).
    private static final String ESQUEMA = "proyecto_final_data_base";

    // Nombre visible -> nombre de la vista en la BD
    private static final String[][] VISTAS = {
        {"Vista 1: Historial Clinico Completo del Paciente", "vista_historial_clinico_completo"},
        {"Vista 2: Inventario de Medicamentos con Alertas de Stock Minimo", "vista_inventario_medicamentos_alerta"},
        {"Vista 3: Medicamentos Mas Recetados y Surtidos", "vista_medicamentos_mas_recetados"}
    };

    public static void main(String[] args) throws Exception {
        String host = env("AIVEN_HOST");
        String port = env("AIVEN_PORT");
        String user = env("AIVEN_USERDB");
        String password = env("AIVEN_PASSWORDDB");
        String sslMode = envOr("AIVEN_SSL_MODE", "REQUIRED");

        if (host == null || port == null || user == null || password == null) {
            System.out.println("Faltan variables de entorno de Aiven (AIVEN_*).");
            return;
        }

        String url = String.format("jdbc:mysql://%s:%s/%s?ssl-mode=%s", host, port, ESQUEMA, sslMode);
        String salida = "site/vistas.html";

        try (Connection cx = DriverManager.getConnection(url, user, password);
             Writer out = new FileWriter(salida)) {

            out.write("<!DOCTYPE html>\n");
            out.write("<html lang=\"es\">\n<head>\n");
            out.write("<meta charset=\"utf-8\">\n");
            out.write("<title>Vistas - Farmacia con Consultorio Medico</title>\n");
            out.write("</head>\n<body>\n");
            out.write("<h1>Vistas de Reporte</h1>\n");
            out.write("<p>Proyecto Final - Farmacia con Consultorio Medico.</p>\n");

            for (String[] v : VISTAS) {
                out.write("<h2>" + escape(v[0]) + "</h2>\n");
                try (Statement st = cx.createStatement();
                     ResultSet rs = st.executeQuery("SELECT * FROM " + v[1])) {
                    escribirTabla(out, rs);
                } catch (Exception e) {
                    out.write("<p>No se pudo consultar la vista <code>" + escape(v[1])
                            + "</code>: " + escape(e.getMessage()) + "</p>\n");
                }
                out.write("<hr>\n");
            }

            out.write("</body>\n</html>\n");
            System.out.println("HTML generado en: " + salida);
        }
    }

    private static void escribirTabla(Writer out, ResultSet rs) throws Exception {
        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount();

        out.write("<table border=\"1\">\n<thead>\n<tr>\n");
        for (int i = 1; i <= cols; i++) {
            out.write("<th>" + escape(md.getColumnLabel(i)) + "</th>\n");
        }
        out.write("</tr>\n</thead>\n<tbody>\n");

        int filas = 0;
        while (rs.next()) {
            out.write("<tr>\n");
            for (int i = 1; i <= cols; i++) {
                String val = rs.getString(i);
                out.write("<td>" + escape(val == null ? "" : val) + "</td>\n");
            }
            out.write("</tr>\n");
            filas++;
        }
        out.write("</tbody>\n</table>\n");
        out.write("<p>" + filas + " fila(s).</p>\n");
    }

    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
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
