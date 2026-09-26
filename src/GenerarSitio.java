import java.sql.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.time.ZonedDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * Genera un sitio de UNA PAGINA, autocontenido, con las tres vistas del
 * proyecto. Estilo monocromatico (blanco y negro) con glassmorphism.
 *
 * Credenciales por variables de entorno (1Password / GitHub Secrets):
 *   AIVEN_HOST, AIVEN_PORT, AIVEN_USERDB, AIVEN_PASSWORDDB, AIVEN_SSL_MODE
 *
 * Uso:
 *   javac -encoding UTF-8 -cp "src/lib/mysql-connector-j-26.7.0.jar" -d build src/GenerarSitio.java
 *   java -cp "build:src/lib/mysql-connector-j-26.7.0.jar" GenerarSitio
 *
 * Salida: site/index.html
 */
public class GenerarSitio {

    static final String ESQUEMA = "proyecto_final_data_base";

    /** id de seccion, titulo, vista SQL, ORDER BY, columna de estado. */
    record Vista(String id, String titulo, String sql, String orden, String colEstado) {}

    static final List<Vista> VISTAS = List.of(
        new Vista("historial", "Vista 1 &middot; Historial cl\u00ednico completo",
                  "vista_historial_clinico_completo", "ORDER BY id_paciente, fecha_consulta", ""),
        new Vista("inventario", "Vista 2 &middot; Inventario con alertas de stock",
                  "vista_inventario_medicamentos_alerta", "ORDER BY stock_actual", "estado_stock"),
        new Vista("recetados", "Vista 3 &middot; Medicamentos m\u00e1s recetados y surtidos",
                  "vista_medicamentos_recetados_surtidos", "", "")
    );

    public static void main(String[] args) throws Exception {
        String host = env("AIVEN_HOST"), port = env("AIVEN_PORT");
        String user = env("AIVEN_USERDB"), pass = env("AIVEN_PASSWORDDB");
        String ssl = System.getenv("AIVEN_SSL_MODE");
        if (ssl == null || ssl.isBlank()) ssl = "REQUIRED";

        if (host == null || port == null || user == null || pass == null) {
            System.err.println("Faltan variables AIVEN_HOST, AIVEN_PORT, AIVEN_USERDB, AIVEN_PASSWORDDB.");
            System.exit(1);
        }

        String url = "jdbc:mysql://" + host + ":" + port + "/" + ESQUEMA + "?ssl-mode=" + ssl;
        StringBuilder secciones = new StringBuilder();
        StringBuilder nav = new StringBuilder();

        try (Connection cx = DriverManager.getConnection(url, user, pass)) {
            cx.setReadOnly(true);
            for (Vista v : VISTAS) {
                nav.append("<a href=\"#").append(v.id()).append("\">")
                   .append(v.titulo()).append("</a>\n");
                try (Statement st = cx.createStatement();
                     ResultSet rs = st.executeQuery("SELECT * FROM " + v.sql() + " " + v.orden())) {
                    secciones.append(seccion(v, rs));
                }
            }
        }

        String html = documento(nav.toString(), secciones.toString());
        Path salida = Path.of("site", "index.html");
        Files.createDirectories(salida.getParent());
        Path tmp = salida.resolveSibling("index.html.tmp");
        Files.writeString(tmp, html, StandardCharsets.UTF_8);
        try {
            Files.move(tmp, salida, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
        } catch (AtomicMoveNotSupportedException e) {
            Files.move(tmp, salida, StandardCopyOption.REPLACE_EXISTING);
        }
        System.out.println("Sitio generado: " + salida.toAbsolutePath());
    }

    /** Renderiza una vista completa como seccion con panel de vidrio. */
    static String seccion(Vista v, ResultSet rs) throws SQLException {
        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount();

        List<String> etiquetas = new ArrayList<>();
        List<Boolean> numerica = new ArrayList<>();
        for (int i = 1; i <= cols; i++) {
            etiquetas.add(etiqueta(md.getColumnLabel(i)));
            int t = md.getColumnType(i);
            numerica.add(t == Types.INTEGER || t == Types.BIGINT || t == Types.DECIMAL
                      || t == Types.NUMERIC || t == Types.DOUBLE || t == Types.FLOAT);
        }

        int idxEstado = -1;
        if (!v.colEstado().isEmpty()) {
            for (int i = 1; i <= cols; i++) {
                if (md.getColumnLabel(i).equalsIgnoreCase(v.colEstado())) { idxEstado = i; break; }
            }
        }

        StringBuilder filas = new StringBuilder();
        int n = 0, enAlerta = 0;
        while (rs.next()) {
            filas.append("<tr>");
            for (int i = 1; i <= cols; i++) {
                String valor = rs.getString(i);
                if (valor == null) valor = "";
                String et = " data-etiqueta=\"" + esc(etiquetas.get(i - 1)) + "\"";
                String clase = numerica.get(i - 1) ? " class=\"num\"" : "";

                String contenido;
                if (valor.isEmpty()) {
                    contenido = "<span class=\"nulo\" aria-label=\"sin dato\">&mdash;</span>";
                } else if (i == idxEstado) {
                    contenido = "<span class=\"estado estado--" + slug(valor) + "\">"
                              + glifo(valor) + " " + esc(valor) + "</span>";
                    if (!valor.equalsIgnoreCase("suficiente")) enAlerta++;
                } else {
                    contenido = esc(valor);
                }

                if (i == 1) filas.append("<th scope=\"row\"").append(et).append(">")
                                 .append(contenido).append("</th>");
                else filas.append("<td").append(clase).append(et).append(">")
                          .append(contenido).append("</td>");
            }
            filas.append("</tr>\n");
            n++;
        }

        StringBuilder cab = new StringBuilder();
        for (int i = 0; i < cols; i++) {
            cab.append("<th scope=\"col\"").append(numerica.get(i) ? " class=\"num\"" : "")
               .append(">").append(esc(etiquetas.get(i))).append("</th>");
        }

        StringBuilder chips = new StringBuilder();
        chips.append("<li class=\"chip\">").append(n).append(" filas</li>");
        chips.append("<li class=\"chip\">").append(cols).append(" columnas</li>");
        if (idxEstado > 0) {
            chips.append("<li class=\"chip chip--alerta\">").append(enAlerta).append(" en alerta</li>");
        }

        return """
            <section id="%s" class="panel seccion" aria-labelledby="%s-t">
              <h2 id="%s-t">%s</h2>
              <ul class="chips">%s</ul>
              <div class="tabla-envoltura" role="region" tabindex="0" aria-label="Tabla: %s">
                <table>
                  <caption class="sr-only">%s</caption>
                  <thead><tr>%s</tr></thead>
                  <tbody>
            %s      </tbody>
                </table>
              </div>
            </section>
            """.formatted(v.id(), v.id(), v.id(), v.titulo(), chips, v.sql(),
                          v.titulo(), cab, filas);
    }

    /** Documento completo con CSS embebido: autocontenido, sin dependencias externas. */
    static String documento(String nav, String secciones) {
        String generado = ZonedDateTime.now(ZoneId.of("America/Mexico_City"))
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
        return """
            <!DOCTYPE html>
            <html lang="es">
            <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <meta name="color-scheme" content="dark">
            <title>Vistas &middot; Farmacia con Consultorio M\u00e9dico</title>
            <style>
            *{box-sizing:border-box}
            :root{
              --fondo:#080808; --tinta:#f5f5f5; --tinta2:#c9c9c9;
              --vidrio:rgba(17,17,17,.78); --luz:rgba(255,255,255,.06);
              --borde:rgba(255,255,255,.16); --brillo:rgba(255,255,255,.22);
              --radio:18px;
              --fuente:ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
            }
            html{scroll-behavior:smooth}
            body{
              margin:0; padding:2rem 1.25rem 4rem; color:var(--tinta);
              font-family:var(--fuente); line-height:1.5;
              background:
                radial-gradient(60rem 40rem at 12%% -10%%,rgba(255,255,255,.10),transparent 60%%),
                radial-gradient(45rem 45rem at 108%% 18%%,rgba(255,255,255,.07),transparent 55%%),
                repeating-linear-gradient(115deg,rgba(255,255,255,.035) 0 1px,transparent 1px 7px),
                var(--fondo);
              background-attachment:fixed;
            }
            .envoltura{max-width:1200px;margin:0 auto}
            /* --- panel de vidrio --- */
            .panel{
              position:relative; border-radius:var(--radio);
              border:1px solid var(--borde);
              background:linear-gradient(180deg,var(--luz),rgba(255,255,255,.02)),var(--vidrio);
              -webkit-backdrop-filter:blur(16px) saturate(0) brightness(1.04);
              backdrop-filter:blur(16px) saturate(0) brightness(1.04);
              box-shadow:0 24px 48px -24px rgba(0,0,0,.9),inset 0 1px 0 var(--brillo);
            }
            .panel::before{
              content:""; position:absolute; inset:0; padding:1px; border-radius:inherit;
              background:linear-gradient(145deg,rgba(255,255,255,.5),rgba(255,255,255,0) 42%%,rgba(255,255,255,.14));
              -webkit-mask:linear-gradient(#000 0 0) content-box,linear-gradient(#000 0 0);
              mask:linear-gradient(#000 0 0) content-box,linear-gradient(#000 0 0);
              -webkit-mask-composite:xor; mask-composite:exclude; pointer-events:none;
            }
            /* --- cabecera y navegacion --- */
            header.panel{padding:1.5rem 1.75rem;margin-bottom:1.5rem;position:sticky;top:1rem;z-index:10}
            h1{margin:0 0 .35rem;font-size:1.5rem;letter-spacing:-.02em}
            .sub{margin:0 0 1rem;color:var(--tinta2);font-size:.9rem}
            nav{display:flex;flex-wrap:wrap;gap:.5rem}
            nav a{
              color:var(--tinta);text-decoration:none;font-size:.82rem;
              padding:.45rem .8rem;border:1px solid var(--borde);border-radius:999px;
              background:rgba(255,255,255,.05);transition:background .15s,border-color .15s;
            }
            nav a:hover{background:rgba(255,255,255,.14);border-color:rgba(255,255,255,.4)}
            /* --- secciones --- */
            .seccion{padding:1.5rem 1.75rem;margin-bottom:1.5rem}
            h2{margin:0 0 .9rem;font-size:1.1rem;font-weight:600;letter-spacing:-.01em}
            .chips{display:flex;flex-wrap:wrap;gap:.5rem;list-style:none;margin:0 0 1.1rem;padding:0}
            .chip{
              font-size:.74rem;padding:.3rem .7rem;border-radius:999px;
              border:1px solid var(--borde);background:rgba(255,255,255,.05);color:var(--tinta2);
            }
            .chip--alerta{border-color:rgba(255,255,255,.55);color:#fff;font-weight:600}
            /* --- tabla --- */
            .tabla-envoltura{
              overflow:auto;max-height:70vh;border-radius:12px;
              border:1px solid rgba(255,255,255,.1);
            }
            table{border-collapse:collapse;width:100%%;font-size:.8rem}
            thead th{
              position:sticky;top:0;z-index:2;text-align:left;white-space:nowrap;
              padding:.65rem .8rem;font-weight:600;font-size:.72rem;
              text-transform:uppercase;letter-spacing:.04em;color:var(--tinta2);
              background:rgba(12,12,12,.97);border-bottom:1px solid rgba(255,255,255,.22);
            }
            tbody th,tbody td{
              padding:.6rem .8rem;border-bottom:1px solid rgba(255,255,255,.07);
              text-align:left;font-weight:400;vertical-align:top;
            }
            tbody th{font-weight:600;white-space:nowrap}
            tbody tr:hover{background:rgba(255,255,255,.045)}
            .num{text-align:right;font-variant-numeric:tabular-nums}
            .nulo{color:rgba(255,255,255,.35)}
            /* --- insignias de estado: forma + glifo + texto, nunca solo color --- */
            .estado{
              display:inline-flex;align-items:center;gap:.3rem;white-space:nowrap;
              font-size:.72rem;padding:.2rem .55rem;border-radius:999px;
              border:1px solid var(--borde);background:rgba(255,255,255,.06);
            }
            .estado--suficiente{border-style:solid;opacity:.75}
            .estado--bajo{border-style:dashed;border-color:rgba(255,255,255,.45)}
            .estado--critico{border-width:2px;border-color:#fff;font-weight:600}
            .estado--agotado{background:#fff;color:#000;border-color:#fff;font-weight:700}
            /* --- pie --- */
            footer.panel{padding:1rem 1.75rem;font-size:.76rem;color:var(--tinta2)}
            /* --- accesibilidad --- */
            .sr-only{
              position:absolute;width:1px;height:1px;padding:0;margin:-1px;
              overflow:hidden;clip:rect(0 0 0 0);white-space:nowrap;border:0;
            }
            .salto{
              position:absolute;left:-9999px;top:0;padding:.6rem 1rem;
              background:#fff;color:#000;border-radius:0 0 8px 0;z-index:100;
            }
            .salto:focus{left:0}
            a:focus-visible,[tabindex]:focus-visible{outline:2px solid #fff;outline-offset:3px}
            /* --- respaldos de capacidad y preferencias --- */
            @supports not ((backdrop-filter:blur(2px)) or (-webkit-backdrop-filter:blur(2px))){
              .panel{background:#111}
            }
            @media (prefers-reduced-transparency:reduce){
              .panel{-webkit-backdrop-filter:none;backdrop-filter:none;background:#0d0d0d}
            }
            @media (prefers-contrast:more){
              :root{--vidrio:rgba(0,0,0,.95);--borde:rgba(255,255,255,.6)}
              .panel{-webkit-backdrop-filter:none;backdrop-filter:none}
            }
            @media (prefers-reduced-motion:reduce){
              html{scroll-behavior:auto}
              *{transition:none!important;animation:none!important}
            }
            /* --- movil: cada fila como tarjeta con su etiqueta --- */
            @media (max-width:600px){
              body{padding:1rem .75rem 3rem}
              header.panel,.seccion,footer.panel{padding:1.1rem}
              .tabla-envoltura{max-height:none;border:0}
              thead{display:none}
              tbody tr{
                display:block;margin-bottom:.9rem;padding:.6rem;
                border:1px solid var(--borde);border-radius:12px;
                background:rgba(255,255,255,.04);
              }
              tbody th,tbody td{
                display:flex;justify-content:space-between;gap:1rem;
                border-bottom:1px solid rgba(255,255,255,.07);white-space:normal;text-align:right;
              }
              tbody th::before,tbody td::before{
                content:attr(data-etiqueta);font-size:.68rem;text-transform:uppercase;
                letter-spacing:.04em;color:var(--tinta2);text-align:left;flex:0 0 42%%;
              }
              .num{text-align:right}
            }
            </style>
            </head>
            <body>
            <a class="salto" href="#contenido">Ir al contenido</a>
            <div class="envoltura">
            <header class="panel">
              <h1>Farmacia con Consultorio M\u00e9dico</h1>
              <p class="sub">Vistas de reporte generadas desde MySQL con Java y JDBC.</p>
              <nav aria-label="Secciones">
            %s  </nav>
            </header>
            <main id="contenido">
            %s</main>
            <footer class="panel">
              Generado el %s desde el esquema <code>%s</code>.
            </footer>
            </div>
            </body>
            </html>
            """.formatted(nav, secciones, generado, ESQUEMA);
    }

    // ---------- utilidades ----------

    /** Escapa los cinco caracteres con significado en HTML. */
    static String esc(String s) {
        if (s == null || s.isEmpty()) return "";
        StringBuilder b = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '&' -> b.append("&amp;");
                case '<' -> b.append("&lt;");
                case '>' -> b.append("&gt;");
                case '"' -> b.append("&quot;");
                case '\'' -> b.append("&#39;");
                default -> b.append(c);
            }
        }
        return b.toString();
    }

    /** Reduce a [a-z0-9-] plegando acentos: seguro para atributos. */
    static String slug(String s) {
        if (s == null) return "";
        String n = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "").toLowerCase(Locale.ROOT);
        StringBuilder b = new StringBuilder();
        for (char c : n.toCharArray()) {
            if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) b.append(c);
            else if (!b.isEmpty() && b.charAt(b.length() - 1) != '-') b.append('-');
        }
        while (!b.isEmpty() && b.charAt(b.length() - 1) == '-') b.deleteCharAt(b.length() - 1);
        return b.toString();
    }

    /** Glifo por nivel: el significado no depende del color. */
    static String glifo(String estado) {
        return switch (slug(estado)) {
            case "agotado" -> "&#9632;";      // cuadro lleno
            case "critico" -> "&#9650;";      // triangulo
            case "bajo" -> "&#9662;";         // triangulo hacia abajo
            case "suficiente" -> "&#9679;";   // circulo
            default -> "&#9675;";             // circulo vacio
        };
    }

    /** nombre_de_columna -> "Nombre de columna". */
    static String etiqueta(String col) {
        String s = col.replace('_', ' ').trim();
        return s.isEmpty() ? col : Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }

    static String env(String k) {
        String v = System.getenv(k);
        return (v == null || v.isBlank()) ? null : v;
    }
}
