# Jhonnatan Peñate — Acceso (20245184)

## Alcance

- Pantallas: Onboarding, Login (incluye recuperar contraseña), Registro y AuthGate.
- Datos: `AuthProvider`, `AuthRepository`, `AuthDataSource` (Fake y Firebase), `AppPreferences`, `Validators`.
- Proyecto Firebase `nodara-community` (Auth + Firestore, plan Spark), `firestore.rules`, `firebase.json`, CI de GitHub Actions.
- Ramas: `base/estructura` (PR #1), `feat/jhonnatan-acceso` (PR #2), `feat/jhonnatan-reset-password` (PR #3), `feat/jhonnatan-cierre`.

## Errores que solucioné

| # | Síntoma | Herramienta | Causa raíz | Solución |
|---|---|---|---|---|
| 1 | `flutter pub add` falló: *"nodara requires SDK version ^3.13.5"* | Flutter CLI | Dart 3.13.1 instalado; el proyecto pide ≥ 3.13.5 | `flutter upgrade` → Flutter 3.47.9 / Dart 3.13.7 |
| 2 | `flutterfire` no se reconoce | PowerShell | La carpeta `Pub\Cache\bin` no estaba en el PATH | Agregar `%LOCALAPPDATA%\Pub\Cache\bin` al PATH del usuario |
| 3 | `flutterfire configure`: *"Found 0 Firebase projects"* | FlutterFire CLI | Faltaba Firebase CLI y la carpeta de npm no estaba en el PATH | `npm install -g firebase-tools`, agregar la carpeta de npm al PATH y hacer `firebase login` |
| 4 | Test *"el feed carga y la búsqueda filtra"* falló | `flutter test` | El feed se ordena por fecha de cierre y `SliverList.builder` solo construye lo visible; la tarjeta buscada quedó fuera de pantalla | El test valida la primera tarjeta visible (no se cambió la lista) |
| 5 | GitHub: *"Google API Key secret detected"* | GitHub Secret Scanning | La API key de Firebase del cliente está en `firebase_options.dart` | Es pública por diseño (documentación de Firebase). Se cierra como falso positivo y se restringe la clave a las APIs de Firebase en Google Cloud |
| 6 | `firebase deploy --only firestore:rules`: *"No targets match"* | Firebase CLI | `firebase.json` no tenía la sección `firestore` | Agregar `"firestore": {"rules": "firestore.rules"}` |
| 7 | Si la sesión fallaba (sin red), la app quedaba en error sin salida | Prueba manual | `AuthGate` mostraba el error sin acción | Botón "Reintentar" que recrea el stream de sesión con `setState` |

## Decisiones técnicas

- **`StreamBuilder` en la raíz (`AuthGate`)** en vez de navegar a mano: al iniciar o cerrar sesión, la pantalla cambia sola (navegación reactiva vista en clase). El stream se crea en `initState`, no en `build`, para no abrir una suscripción nueva en cada reconstrucción.
- **Repository + DataSource abstracto** (SOLID-D): las pantallas no importan Firebase y los tests usan el Fake sin internet.
- **Simplificación a temas de clase**: se reemplazó un `StreamController` manual por `authStateChanges().asyncMap(...)`, el `switch` como expresión por un `switch` clásico, y una función que recibía otra función (`_run`) por `try/catch` dentro de `signIn` y `register`.
- **Reintento al leer el perfil** (`_leerPerfil`, 3 intentos de 500 ms): justo después de registrarse, Firebase avisa la sesión antes de terminar de guardar `users/{uid}`.
- **Registro con 5 campos obligatorios** (R1): rol, nombre, correo, contraseña y tipo; horas e intereses son opcionales.

## Pruebas

### Automáticas

| Prueba | Tipo | Qué verifica | Resultado |
|---|---|---|---|
| `test/core/validators_test.dart` | Unitaria | Casos válidos e inválidos de email, password, nombre y horas | ✅ Aprobado (13 tests) |
| `test/widget_test.dart` (grupo Autenticación) | Widget con Fake | Onboarding → login, error de credenciales, registro con validaciones, panel de organización y cerrar sesión | ✅ Aprobado |

### Manuales (con capturas en `docs/bitacora/`)

| # | Pasos | Esperado | Obtenido | Captura |
|---|---|---|---|---|
| M1 | Primera apertura de la app | Se muestra el Onboarding | ☐ | `jhonnatan-01-onboarding.png` |
| M2 | Registro desde "Empezar ahora" con un correo nuevo, cronometrado | Llega a Explorar en < 3 min (R1) | ☐ ___ min ___ s | `jhonnatan-02-registro.png` |
| M3 | Tocar "Crear cuenta" con el formulario vacío | Mensajes "Ingresa tu nombre." e "Ingresa tu correo." | ☐ | `jhonnatan-03-validaciones.png` |
| M4 | Registrar un correo ya existente | "Ya existe una cuenta con ese correo." | ☐ | `jhonnatan-04-correo-repetido.png` |
| M5 | Login con contraseña incorrecta | "Correo o contraseña incorrectos." | ☐ | `jhonnatan-05-login-error.png` |
| M6 | "¿Olvidaste tu contraseña?" | Snackbar de correo enviado y correo recibido | ☐ | `jhonnatan-06-reset.png` |
| M7 | Login como organización | Entra al Panel de organización | ☐ | `jhonnatan-07-rol-org.png` |
| M8 | Cerrar sesión y volver a abrir la app | Va a Login; el Onboarding no vuelve a salir | ☐ | `jhonnatan-08-sin-onboarding.png` |
| M9 | Firebase Console después de M2 | Usuario en Authentication y documento en `users/{uid}` | ☐ | `jhonnatan-09-firebase.png` |
| M10 | Ancho de 360 px (DevTools de Edge, modo móvil) | Sin desbordes en Login y Registro | ☐ | `jhonnatan-10-360px.png` |

## Uso de la IA

| Modalidad | Caso concreto | Qué hice con la respuesta | Cómo lo verifiqué |
|---|---|---|---|
| Aclarar un término | Error del SDK de Dart y del PATH de `flutterfire` / `firebase` | Actualicé Flutter y agregué las rutas al PATH | Los comandos se reconocieron y `flutterfire configure` generó los archivos |
| Consultor | Opciones para proteger la API key de Firebase | Elegí: reglas + Auth + restricción de APIs; App Check como mejora futura | Documentación oficial de Firebase sobre API keys |
| Consejero | Revisión de la parte de acceso para dejar solo temas de clase | Se cambiaron `StreamController`, `switch` expresión y `_run` | `flutter analyze` sin hallazgos y tests en verde |
| _(agregar)_ | | | |

## Evidencias

- Capturas de las pruebas manuales: pendientes. Se guardarán en esta carpeta como `jhonnatan-XX-*.png` y se insertarán aquí con `![descripción](jhonnatan-02-registro.png)`.
- CI: _enlace del run de GitHub Actions del PR_
