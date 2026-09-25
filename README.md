# Proyecto Final — Farmacia con Consultorio Médico

Base de datos relacional para la **gestión de consultas y medicamentos recetados**
de un consultorio médico con farmacia asociada. Incluye el modelo entidad-relación,
el esquema físico en MySQL, datos de prueba, una vista de reporte y una aplicación
Java de conexión (JDBC).

## Estructura del proyecto

```
proyectoFinal/
├── README.md                  Este archivo
├── .gitignore
├── src/
│   ├── App.java               Conexión JDBC de ejemplo (credenciales por entorno)
│   └── lib/
│       └── mysql-connector-j-26.7.0.jar
├── db/
│   ├── 01_schema.sql          DDL: creación de las 20 tablas
│   ├── 02_data.sql            DML: datos de prueba
│   ├── 03_vista3.sql          Vista 3: medicamentos más recetados y surtidos
│   └── modelo_der.dbml        Modelo ER (dbdiagram.io)
└── docs/
    ├── guidelines-datos.md    Guía para poblar datos realistas
    └── latex/
        ├── paper/             Documento (APA 7, student)
        └── slides/            Presentación (Beamer, minimalista B/N)
```

## Requisitos

- MySQL 8.x (base gestionada en **Aiven**)
- JDK 21 (o compatible)
- Conector JDBC incluido en `src/lib/`

## Base de datos

Ejecuta los scripts en orden:

```sql
SOURCE db/01_schema.sql;   -- crea la base y las tablas
SOURCE db/02_data.sql;     -- inserta datos de prueba
SOURCE db/03_vista3.sql;   -- crea la vista de reporte
```

## Aplicación Java

Las credenciales se leen de variables de entorno inyectadas desde 1Password
(item **Developer**), apuntando a la instancia de MySQL gestionada en **Aiven**
(SSL requerido). La aplicación construye la URL JDBC a partir de:

| Variable            | Descripción                    |
| ------------------- | ------------------------------ |
| `AIVEN_HOST`        | Host del servidor Aiven        |
| `AIVEN_PORT`        | Puerto                         |
| `AIVEN_DB_NAME`     | Nombre de la base de datos     |
| `AIVEN_USERDB`      | Usuario                        |
| `AIVEN_PASSWORDDB`  | Password                       |
| `AIVEN_SSL_MODE`    | Modo SSL (por defecto REQUIRED)|

```bash
# Las variables AIVEN_* provienen de 1Password (ya montadas en el entorno).
javac src/App.java
java -cp "src:src/lib/mysql-connector-j-26.7.0.jar" App
```

## Requerimientos cubiertos

- **Vista 1:** Historial clínico completo del paciente.
- **Vista 2:** Inventario de medicamentos con alertas de stock mínimo.
- **Vista 3:** Medicamentos más recetados y surtidos (`db/03_vista3.sql`).
- Stored Procedures y Triggers previstos en el modelo (SP1–SP3, Trigger 1–2).

## Documentación

En `docs/latex/` se encuentran las fuentes LaTeX del documento (APA 7) y de la
presentación (Beamer). Los documentos usan capturas de pantalla del trabajo
realizado.
