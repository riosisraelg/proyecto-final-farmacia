import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;

/**
 * Escritura atomica del documento generado (componente C11 del diseño).
 *
 * El contenido se escribe primero en un archivo temporal creado en el MISMO
 * directorio del destino, se fuerza a disco (fsync) y solo entonces se mueve
 * sobre el destino con ATOMIC_MOVE + REPLACE_EXISTING. El temporal vive en el
 * directorio destino porque ATOMIC_MOVE solo esta garantizado dentro del mismo
 * sistema de archivos; usar el temporal del sistema romperia esa garantia.
 *
 * Con esto el destino nunca queda truncado ni a medio escribir: ante cualquier
 * falla (escritura, fsync o movimiento) se borra el temporal y se propaga una
 * IOException, quedando el destino byte a byte igual a como estaba antes, o
 * ausente si antes no existia.
 *
 * Requisitos: 6.1, 6.2, 6.5. Propiedad P3.
 */
public final class EscritorAtomico {

    private EscritorAtomico() {
        // Utilidad estatica, no instanciable.
    }

    /**
     * Escribe {@code contenido} en {@code destino} de forma atomica y en UTF-8.
     *
     * @param destino   ruta final del documento (por ejemplo site/index.html)
     * @param contenido texto completo del documento
     * @throws IOException si la escritura, el fsync o el movimiento fallan
     */
    public static void escribir(Path destino, String contenido) throws IOException {
        if (destino == null) {
            throw new IOException("La ruta de destino es nula.");
        }
        if (contenido == null) {
            throw new IOException("El contenido a escribir es nulo.");
        }

        Path absoluto = destino.toAbsolutePath();
        Path directorio = absoluto.getParent();
        if (directorio == null) {
            throw new IOException("La ruta de destino no tiene directorio padre: " + destino);
        }
        // site/ es salida de compilacion ignorada por git: puede no existir en
        // un clon nuevo ni en CI.
        Files.createDirectories(directorio);

        Path temporal = Files.createTempFile(directorio, "." + absoluto.getFileName() + ".", ".tmp");
        try {
            escribirYSincronizar(temporal, contenido);
            mover(temporal, absoluto);
        } catch (IOException | RuntimeException e) {
            borrarSilencioso(temporal);
            if (e instanceof IOException io) {
                throw io;
            }
            throw new IOException("Fallo la escritura atomica de " + destino + ": " + e.getMessage(), e);
        }
    }

    /** Escribe el contenido en UTF-8 y lo fuerza a disco antes de cualquier movimiento. */
    private static void escribirYSincronizar(Path temporal, String contenido) throws IOException {
        byte[] bytes = contenido.getBytes(StandardCharsets.UTF_8);
        try (FileChannel canal = FileChannel.open(temporal,
                StandardOpenOption.WRITE,
                StandardOpenOption.TRUNCATE_EXISTING)) {
            ByteBuffer buffer = ByteBuffer.wrap(bytes);
            while (buffer.hasRemaining()) {
                canal.write(buffer);
            }
            // fsync: sin esto el movimiento podria publicar datos aun no
            // volcados y una caida dejaria un destino incompleto.
            canal.force(true);
        }
    }

    private static void mover(Path temporal, Path destino) throws IOException {
        try {
            Files.move(temporal, destino,
                    StandardCopyOption.ATOMIC_MOVE,
                    StandardCopyOption.REPLACE_EXISTING);
        } catch (AtomicMoveNotSupportedException e) {
            // Respaldo para sistemas de archivos sin movimiento atomico (por
            // ejemplo algunos montajes de red). La garantia es mas debil: el
            // reemplazo no es atomico, asi que un lector concurrente o una
            // caida justo en el reemplazo podrian ver el destino incompleto.
            // Se acepta porque un reemplazo no atomico es preferible a fallar
            // la compilacion, y el contenido ya esta completo en disco.
            Files.move(temporal, destino, StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private static void borrarSilencioso(Path temporal) {
        try {
            Files.deleteIfExists(temporal);
        } catch (IOException ignorada) {
            // No se puede hacer mas: la falla original es la que importa.
        }
    }
}
