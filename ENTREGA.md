# App de voluntariado y donaciones (NODARA): guía de entrega

> Entrega y presentación: **martes 3 de noviembre de 2026**
> Complementa a `PLAN.md`. Este documento manda en todo lo que tenga que ver con la evaluación.

---

## 1. Cómo nos evalúan

| Componente | Modalidad | Peso | Qué evalúa | Qué hacemos |
|---|---|---|---|---|
| **A. Presentación grupal** | Equipo, nota compartida | 20 % | Alcance cumplido respecto de la ficha, demo del flujo principal, arquitectura, comunicación, uso declarado de IA | Demo del recorrido completo (§6) + diagrama de capas (§7) + declaración honesta de IA |
| **B. Defensa técnica individual** | Pregunta sorteada del banco de la *Guía de defensa* | **50 %** | Dominio del propio código: demo, justificación, explicación línea a línea, repregunta | Cada quien defiende **su pantalla de punta a punta** (§3) |
| **C. Conocimientos del ciclo** | Repreguntas integradoras | 30 % | Integración de temas, bibliografía, depuración y pruebas, uso crítico de la IA | Cada quien conecta su pantalla con los temas del ciclo (§5) |

**El 80 % de la nota es individual.** Lo que más pesa es que **cada quien entienda y pueda explicar su propio código**.

> **Pendiente:** conseguir la **Guía de defensa** (el banco de preguntas). Sin ella estamos estudiando a ciegas.

---

## 2. Reglas de IA del curso (obligatorias)

| Modalidad | Se puede | No se puede |
|---|---|---|
| Consultor | Preguntar qué opciones hay y compararlas antes de decidir | Que elija y escriba la solución completa |
| Consejero | Pedir revisión de código **propio ya escrito** | Aceptar cambios sin entender por qué funcionan |
| Aclarar un término | Que explique un concepto o un error | Pegar el error y aplicar la corrección sin entender la causa |
| Profundizar | Ejemplos extra de temas vistos | Reemplazar la lectura asignada |
| **Desarrollador** | **Nunca** | Que la IA genere pantallas, clases o módulos que se entregan como propios |

### ⚠️ Riesgo que hay que resolver YA

- El diseño salió de Stitch y la base del código (incluida la reestructuración F0/F1) la generó una IA. Según la tabla de arriba, eso cae en **"Desarrollador"**.
- La hoja individual termina con este checkbox: *"Declaro que el código de Mi aporte fue escrito y comprendido por mí y que la IA no actuó como desarrolladora"*. **Nadie puede marcarlo sobre código que no escribió.**

**Qué hacemos:**
1. **Hablar con el docente antes del martes** (hoy o mañana) y declarar con transparencia que la base visual y la arquitectura inicial se generaron con IA. Preguntarle cómo quiere que lo tratemos. Es mejor declararlo nosotros que que lo descubra en la defensa: la tabla de la Parte A ya pide "uso declarado de IA".
2. **"Mi aporte" de cada persona = solo lo que esa persona escribe a mano desde ahora:** su pantalla, su provider/método, su DataSource de Firebase y su test.
3. **La IA queda solo como Consultor, Consejero o para aclarar dudas.** Cada quien escribe su código y lo pasa por revisión.
4. Cada quien guarda **evidencia** para su hoja individual: commits con su propia cuenta de GitHub, la pregunta que le hizo a la IA y cómo verificó la respuesta.

---

## 3. Una pantalla por persona

Cada integrante construye y defiende **una pantalla completa de arriba a abajo**: Pantalla → Provider → Repository → DataSource (Firebase) → Test.

| Persona | Su pantalla | Requisito que cubre | Archivos que le pertenecen |
|---|---|---|---|
| **Jhonnatan** | Onboarding + Login + Registro (`AuthGate`) | **R1** registro < 3 min, ≤ 5 campos | `features/auth/*`, `firebase_auth_data_source.dart`, `firestore.rules`, proyecto Firebase |
| **Josué** | **Explorar**: feed, búsqueda, chips de causa, hoja de filtros | **R2** ≥ 4 convocatorias vigentes · filtro por categoría | `features/explore/*`, `firestore_opportunity_data_source.dart` |
| **Javier** | **Detalle de convocatoria + Mis postulaciones** (postularse, retirarse) | **R3** postular en ≤ 3 toques | `features/opportunity_detail/*`, `features/applications/*`, `firestore_application_data_source.dart` (crear, leer las mías, retirar) |
| **José Napoleón** | **Panel de organización**: crear convocatoria, ver postulantes, aceptar/rechazar/completar | Panel de organizaciones (alcance de la ficha) | `features/organization/*`, `organization_provider.dart`, `updateEstado` + batch (estado + cupo + aviso) |
| **Alejandra** | **Puntos de donación + Avisos** (notificación local) | Puntos de donación · **R4** aviso < 5 s | `features/donations/*`, `features/notifications/*`, `firestore_donation_data_source.dart`, `firestore_notification_data_source.dart` |
| **Rogelio** | **Perfil + Reporte PDF** con código de validación | **R5** PDF < 3 s | `features/profile/*`, `firestore_certificate_data_source.dart`, generación del PDF |

**QA ya no es un rol aparte:** cada quien prueba su pantalla. Javier además coordina las evidencias R1–R5 y el ensayo general.

### Puntos de contacto entre pantallas (acordarlos el viernes)

| Contrato | Lo escribe | Lo usa |
|---|---|---|
| `Opportunity` en Firestore (campos de §6 del PLAN) | Josué | Javier, José |
| `Application` + estados | Javier | José, Rogelio |
| Aviso al cambiar estado (`users/{uid}/notifications`) | José | Alejandra |
| Horas completadas (`ApplicationsProvider.horasCompletadas`) | Javier | Rogelio |

---

## 4. Reglas del equipo

1. **Cada quien toca solo sus archivos.** Si necesitas algo de otro módulo, lo pides en el grupo.
2. **Una rama por persona:** `pantalla/<tu-nombre>` (ej. `pantalla/josue-explorar`).
3. **Commits con tu propia cuenta** y el formato del curso: `explorar: chips de causa [CARNET]`. Esos commits son la prueba de "Mi aporte".
4. **Nada entra a `main` sin un PR revisado por otra persona**, con `flutter analyze` en 0 y `flutter test` en verde.
5. **Checklist del curso en cada PR** (PLAN.md §2): sin `!`, `mounted` después de cada `await`, `ListView.builder` con datos de la base, 4 estados de UI, 48 dp, nada de `dynamic`, `watch` en build y `read` en callbacks.
6. **Bitácora personal desde hoy** (`docs/bitacora/<nombre>.md`): cada error con síntoma, herramienta, causa y solución. Así se llena el punto 3 de la hoja individual.
7. **Nadie toca la paleta de colores** (`lib/theme/app_colors.dart`).
8. **Congelamiento:** lunes 2 a las 12:00 m.d. Después de esa hora solo se corrigen bugs.

---

## 5. Definición de "pantalla terminada"

Una pantalla está lista cuando cumple todo esto:

- [ ] Lee y escribe en **Firebase real** (no en el Fake)
- [ ] Muestra **4 estados**: cargando, datos, vacío y error
- [ ] No tiene botones que no hagan nada (si no se implementa, se quita)
- [ ] Funciona a **360 px** de ancho y con la fuente del sistema grande
- [ ] Tiene **al menos 1 test** (unitario o de widget usando el Fake)
- [ ] `flutter analyze` en 0
- [ ] Puedes explicar **cada línea** y responder: *¿por qué esta capa?, ¿qué pasa si falla la red?, ¿por qué `watch` y no `read` aquí?, ¿qué pasaría sin `mounted`?*
- [ ] Puedes conectarla con **al menos 2 temas del ciclo** (Provider, Repository/SOLID-D, Firestore/streams, formularios, ciclo de vida, Material 3/accesibilidad, testing con Fakes)

---

## 6. Demo del flujo principal (Parte A, máximo 5 minutos)

Cada quien presenta su pantalla en este orden, como una sola historia:

| # | Paso | Quién | Evidencia |
|---|---|---|---|
| 1 | Se registra un voluntario (cronometrado) | Jhonnatan | R1 |
| 2 | Explora, filtra por "Animales" y ve ≥ 4 convocatorias vigentes | Josué | R2 |
| 3 | Abre el detalle y se postula (contando los toques) | Javier | R3 |
| 4 | La organización acepta la postulación desde su panel | José | — |
| 5 | Al voluntario le llega el aviso en menos de 5 s; además muestra puntos de donación | Alejandra | R4 |
| 6 | La org marca la postulación como completada; el perfil suma las horas y se descarga el PDF | Rogelio | R5 |

**Para el paso 4 se necesitan 2 celulares o emuladores:** uno con la cuenta de voluntario y otro con la de organización.

---

## 7. Parte A: datos para el documento

### A1. Acceso

| Campo | Valor |
|---|---|
| Repositorio | `https://github.com/Dae51/nodara` (si es privado, agregar al docente como colaborador) |
| Rama o etiqueta | `v1.0-entrega` (etiqueta sobre `main` el lunes 2) |
| Versión de Flutter | *salida de `flutter --version` en la PC de Jhonnatan* |
| Cómo ejecutar | `flutter pub get` y `flutter run` · sin Firebase: `flutter run --dart-define=NODARA_FAKE=true` |
| Configuración | `lib/firebase_options.dart` ya viene en el repo; no hace falta nada más |

### Cuentas de prueba (crearlas en Firebase el domingo)

| Rol | Correo | Datos precargados |
|---|---|---|
| Voluntario | `voluntario.demo@nodara.app` | 1 postulación aceptada + 2 completadas (horas en el perfil) |
| Organización | `org.demo@nodara.app` | ≥ 4 convocatorias vigentes de distintas causas + 1 postulante pendiente |

Las contraseñas se crean solo para la demo y nunca son las personales.

### A2. Diagrama de capas (ya con nuestras clases reales)

| Capa | En nuestro repo |
|---|---|
| **Presentación** | `lib/features/*/…_screen.dart` (Explorar, Detalle, Mis postulaciones, Panel org, Donar, Avisos, Perfil, Login/Registro) + `lib/core/widgets/` |
| ▼ | |
| **Estado** | Provider: `AuthProvider`, `ExploreProvider`, `ApplicationsProvider`, `DonationsProvider`, `NotificationsProvider` (ChangeNotifier en `MultiProvider`, `main.dart`) |
| ▼ | |
| **Repository** | `lib/data/repositories/*_repository.dart`: reciben un DataSource abstracto por constructor (`AppDependencies`) |
| ▼ | |
| **Fuentes de datos** | Contratos en `lib/data/datasources/*_data_source.dart` · Remota: `firebase/` (Auth + Firestore) · Fake: `fake/` (en memoria, para tests) · Local: `SharedAppPreferences` (`shared_preferences`) |
| ▼ | |
| **Servicios externos** | Firebase Authentication, Cloud Firestore (plan Spark), Google Maps (link con `url_launcher`), `flutter_local_notifications`, `pdf`/`printing` |

**Decisión de arquitectura y costo asumido (borrador, máximo 5 líneas):**
> Separamos la UI de Firebase con Repository y DataSources abstractos inyectados por constructor (SOLID-D). Así cada integrante desarrolló y probó su pantalla con un Fake en memoria mientras se conectaba Firebase. El costo asumido de $0 se mantuvo usando el plan Spark. Cambió el aviso de estado: pasó de push (requería Cloud Functions y el plan de pago Blaze) a notificación local disparada por un listener de Firestore, que no llega con la app cerrada.

---

## 8. Parte B: hoja individual (cómo llenarla)

| Punto | Qué escribir | De dónde sale |
|---|---|---|
| 1. Mi aporte | Tu pantalla y tus archivos (§3) + enlaces a **tus** commits/PR | Tu rama |
| 2. Mis decisiones técnicas | Qué decidiste, qué descartaste y por qué + el tema del ciclo | Ej.: `StreamBuilder` en vez de `FutureBuilder`; `SliverList.builder` en vez de `ListView(children)`; batch atómico al aceptar |
| 3. Un error que solucioné | Síntoma · herramienta (logs, DevTools, analizador, breakpoint) · causa raíz · corrección | Tu bitácora |
| 4. Pruebas | Tipo · qué verifica · resultado | Tu test + tu evidencia R |
| 5. Uso de la IA | Modalidad + un caso: qué preguntaste, qué hiciste con la respuesta, cómo lo verificaste | Guardar la conversación |
| Declaración | Marcarla **solo si es verdad** | §2 |

---

## 9. Pasos a seguir

| Cuándo | Qué | Quién |
|---|---|---|
| **Vie 30 (hoy)** | Hablar con el docente sobre la IA (§2) y pedir la Guía de defensa | Jhonnatan (como vocero) |
| **Vie 30** | `flutter pub add …` + `flutter analyze` + `flutter test` + crear Firebase + `flutterfire configure` + publicar reglas + merge de la base a `main` | Jhonnatan |
| **Vie 30 noche** | Todos clonan, corren la app en modo Fake y crean su rama | Todos |
| **Sáb 31** | Cada quien: su DataSource de Firebase + su pantalla conectada | Todos |
| **Dom 1** | Su test + checklist §5 + PR + crear cuentas demo y datos precargados | Todos / Jhonnatan |
| **Lun 2, 12:00** | Congelamiento, etiqueta `v1.0-entrega`, documento final (Parte A + hojas B) | Todos |
| **Lun 2, noche** | Ensayo: demo de 5 min + cada quien responde 3 preguntas del banco | Todos (coordina Javier) |
| **Mar 3** | Presentación | Todos |
