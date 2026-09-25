Proyecto Final
Objetivo de la actividad
El reto final está enfocado en implementar operaciones CRUD (crear, leer,
actualizar y eliminar) en la base de datos a través del uso de sentencias SQL,
así como en ejecutar operaciones avanzadas con SQL (stored procedures
y triggers), considerando el uso de bases de datos desde Java (JDBC) u otro
lenguaje de programación (ODBC).
Descripción de la actividad
Realizar la implementación total de la funcionalidad de la base de datos,
que permita realizar operaciones CRUD de acuerdo al caso de negocio
asignado.

Proyecto Final
Instrucciones para el alumno
De acuerdo al caso de negocio asignado, determina la información básica que maneja la
empresa, así como el uso que se le da, elige los datos que almacenan e identifica la forma
en que están organizados y cómo se comparten con otras áreas. Con base en esta
información, sabrás el nombre de las tablas, el nombre de los campos y los tipos de datos
para cada uno de ellos y qué tipo de relaciones se dan entre sí.
Parte I
1. Realiza el Modelo Conceptual, determina las entidades, sus relaciones (cardinalidad),
restricciones de integridad y todos los elementos que consideres necesarios para una
correcta creación de la base de datos.
2. Escribe el código para representar visualmente el Modelo E-R en la plataforma de
dbdiagram.io

Proyecto Final
| Instrucciones |     | para | el  | alumno |     |
| ------------- | --- | ---- | --- | ------ | --- |
| Parte II      |     |      |     |        |     |
1. Lleva a cabo el Modelo Lógico de la base de datos a través de la especificación de los
tipos de datos para cada campo (carácter, entero, flotante, etc.), define las claves primarias
| y foráneas | para cada | tabla. |     |     |     |
| ---------- | --------- | ------ | --- | --- | --- |
2. Escribe el código en SQL para crear las tablas y muestra visualmente las tablas creadas
en MySQL.
3. Una vez creadas las tablas, agrega datos lo más reales posibles para poder generar las
| consultas | (queries) | que serán | usados | por los | reportes. |
| --------- | --------- | --------- | ------ | ------- | --------- |

Proyecto Final
| Instrucciones |     | para | el alumno |     |
| ------------- | --- | ---- | --------- | --- |
Parte III
1. Realiza consultas avanzadas en SQL para crea Vistas (views) que permitan ver
| información | relevante | de acuerdo | al negocio | asignado. |
| ----------- | --------- | ---------- | ---------- | --------- |
2. Genera el código SQL para crear Stored Procedures que permitan ser mandados a llamar
| para realizar | transacciones. |     |     |     |
| ------------- | -------------- | --- | --- | --- |
3. De igual manera genera el código SQL para crear Triggers que puedan ser mandados a
llamar en los eventos de Inserción y Actualización de diversas tablas.
4. Crea una tabla de LOG para que se guarden los cambios hechos en las tablas de acuerdo
a requerimientos específicos.

Proyecto Final
| Instrucciones |     | para | el alumno |
| ------------- | --- | ---- | --------- |
Parte IV
1. Realizar una conexión a una Base de Datos relacional (MySQL) mediante algún lenguaje
| de programación | (JAVA, | PHP, .Net). |     |
| --------------- | ------ | ----------- | --- |
2. Genera el código en el lenguaje de programación seleccionado donde se muestren tanto
los parámetros de la conexión como la forma como se obtienen y despliegan los datos
seleccionados.
3. Mostrar visualmente los datos obtenidos mediante un Dataset usando la conexión y la
sentencia SQL.

Proyecto Final
Entregables para el alumno
De acuerdo al caso de negocio asignado entregar lo siguiente:
1. Descripción del caso de negocio
a) Problema
b) Solución
c) Beneficio
2. Diseño conceptual de la BD propuesta (modelo entidad-relación) en
dbdiagram.io.
a) Guardar en un archivo .TXT el código del modelo entidad-relación.
b) Guardar una imagen del modelo entidad-relación (evidencia en PDF).

Proyecto Final
Entregables para el alumno
3. Diseño lógico de la BD propuesta (descripción de la estructura de datos en
SQL).
a) Guardar en el archivo .SQL el script para la creación de las tablas y sus
relaciones.
4. Base de datos final que muestre cada una de las tablas creadas en MySQL.
a) Guardar en el archivo .SQL el script con la inserción de datos las tablas.
b) Mostrar las tablas con los datos reales en todos los campos (evidencia en
PDF).

Proyecto Final
Entregables para el alumno
5. Código de las Vistas, Stored Procedures y Triggers creados por cada caso de
negocio.
a) Guardar en el archivo .SQL el código de cada View, SP, Trigger.
b) Explicar con pseudocódigo que hace cada objeto programado (evidencia
en PDF).
6. Código de la conexión a la base de datos
a) Mostrar el código utilizado para la conexión a la BD y la visualización de
los datos.
b) Mostrar el Dataset con el resultado de la ejecución del query.

Proyecto Final
| Entregables     |     |     | para    | el alumno    |     |
| --------------- | --- | --- | ------- | ------------ | --- |
| 6. Presentación |     |     | técnica | del Proyecto |     |
a) Presentar el caso de negocio asignado (que tipo de empresa son y
|     | cual | es su | problemática |     | actual) |
| --- | ---- | ----- | ------------ | --- | ------- |
b) Explicar la estructura de la BD con el diagrama Entidad Relación
| c)  | Mostrar |     | TODAS | las tablas | con datos |
| --- | ------- | --- | ----- | ---------- | --------- |
d) Explicar la funcionalidad y el objetivo de cada uno de los objetos
|     | solicitados |     | (vista, | SP, trigger). |     |
| --- | ----------- | --- | ------- | ------------- | --- |
e) Realizar al menos 3 ejemplos para validar la funcionalidad de los SP y
Triggers.

Rubrica - Proyecto Final
3. Programación
| 20-18 | 17-15 | 14-0 |     |
| ----- | ----- | ---- | --- |
avanzada en SQL
La programación no
(Vistas, SPs,
| La programación  | La programación cumple  |     |     |
| ---------------- | ----------------------- | --- | --- |
cumple con el
Triggers)
| cumple con el  | parcialmente con el  |     | 20  |
| -------------- | -------------------- | --- | --- |
propósito y no
| propósito y muestra /  | propósito y/o muestra /  |     |     |
| ---------------------- | ------------------------ | --- | --- |
muestra / valida los
| valida los datos  de  | valida los datos  de  |     |     |
| --------------------- | --------------------- | --- | --- |
datos  de manera
| manera adecuada | manera aceptable |     |     |
| --------------- | ---------------- | --- | --- |
adecuada

Rubrica - Proyecto Final

Rubrica de formato de documentos