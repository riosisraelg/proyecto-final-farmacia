import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;

/**
 * Conexion JDBC de ejemplo al Proyecto Final (Farmacia con Consultorio Medico).
 *
 * Las credenciales NO estan en el codigo: se construyen a partir de variables
 * de entorno inyectadas desde 1Password (item "Developer"). Base gestionada en
 * Aiven (MySQL). Variables usadas:
 *
 *   AIVEN_HOST        host del servidor Aiven
 *   AIVEN_PORT        puerto
 *   AIVEN_DB_NAME     nombre de la base de datos
 *   AIVEN_USERDB      usuario
 *   AIVEN_PASSWORDDB  password
 *   AIVEN_SSL_MODE    modo SSL (ej. REQUIRED); por defecto REQUIRED
 *
 * Compilar y ejecutar (desde la raiz del proyecto):
 *   javac src/App.java
 *   java -cp "src:src/lib/mysql-connector-j-26.7.0.jar" App
 */
public class App {
    public static void main(String[] args) throws Exception {
        String host = getEnv("AIVEN_HOST");
        String port = getEnv("AIVEN_PORT");
        String dbName = getEnv("AIVEN_DB_NAME");
        String user = getEnv("AIVEN_USERDB");
        String password = getEnv("AIVEN_PASSWORDDB");
        String sslMode = getEnvOr("AIVEN_SSL_MODE", "REQUIRED");

        if (host == null || port == null || dbName == null || user == null || password == null) {
            System.out.println("Faltan variables de entorno de Aiven.");
            System.out.println("Requeridas: AIVEN_HOST, AIVEN_PORT, AIVEN_DB_NAME, "
                    + "AIVEN_USERDB, AIVEN_PASSWORDDB (AIVEN_SSL_MODE opcional).");
            System.out.println("Se inyectan desde 1Password (item Developer).");
            return;
        }

        String url = String.format("jdbc:mysql://%s:%s/%s?ssl-mode=%s",
                host, port, dbName, sslMode);

        System.out.println("Conectando a MYSQL (Aiven)");

        try (Connection conexion = DriverManager.getConnection(url, user, password)) {
            if (conexion != null) {
                System.out.println("Conexion Exitosa");

                // Los IDs del modelo son VARCHAR (ej. PAC-000001), por eso se leen
                // con getString y NO con getInt.
                String query = "SELECT id_paciente, nombre, apellidos, telefono FROM Pacientes";
                try (Statement stmt = conexion.createStatement();
                     ResultSet rs = stmt.executeQuery(query)) {
                    System.out.println("Datos de la tabla Pacientes:");
                    while (rs.next()) {
                        String id = rs.getString("id_paciente");
                        String nombre = rs.getString("nombre");
                        String apellidos = rs.getString("apellidos");
                        String telefono = rs.getString("telefono");
                        System.out.println("ID: " + id
                                + " | Paciente: " + nombre + " " + apellidos
                                + " | Tel: " + telefono);
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Error Conexion");
            e.printStackTrace();
        }
    }

    /** Lee una variable de entorno y devuelve null si esta vacia. */
    private static String getEnv(String key) {
        String v = System.getenv(key);
        return (v == null || v.isBlank()) ? null : v;
    }

    /** Lee una variable de entorno con valor por defecto. */
    private static String getEnvOr(String key, String def) {
        String v = getEnv(key);
        return (v == null) ? def : v;
    }
}
