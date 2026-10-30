# Mi parte: Acceso (R1), Jhonnatan Peñate

> Rama: `feat/jhonnatan-acceso` · Regla: solo temas vistos en clase · La IA es consultor/consejero, no desarrollador.

## 1. Pantallas que presento (demo de unos 45 s)

| Orden | Pantalla | Qué muestro |
|---|---|---|
| 1 | **Onboarding** | Las 3 slides; sale solo la primera vez |
| 2 | **Registro** | Rol (voluntario/org), nombre, correo, contraseña, tipo · validaciones en vivo · **cronómetro < 3 min (R1)** |
| 3 | **Login** | Error en español con contraseña mala → login correcto |
| 4 | **AuthGate** | El voluntario entra a Explorar, la organización al Panel, cerrar sesión regresa a Login (sin `Navigator`) |

## 2. Mis archivos

| Archivo | Capa | Qué hace | Tema de clase |
|---|---|---|---|
| `lib/main.dart` | Arranque | `Firebase.initializeApp`, modo Fake, `MultiProvider` | Firebase, Provider |
| `lib/core/di/app_dependencies.dart` | Dependencias | Crea repositorios y les inyecta el DataSource | Repository, SOLID-D |
| `lib/features/auth/auth_gate.dart` | Pantalla | `StreamBuilder` sobre la sesión; decide la pantalla | Navegación reactiva, `initState`, `mounted` |
| `lib/features/auth/onboarding_screen.dart` | Pantalla | `PageView` + puntos | StatefulWidget, `setState`, `dispose` |
| `lib/features/auth/login_screen.dart` | Pantalla | Formulario de login | `Form`, `GlobalKey<FormState>`, `validator`, `FocusNode` |
| `lib/features/auth/register_screen.dart` | Pantalla | Formulario de registro | `Form`, `SegmentedButton`, `ChoiceChip`, `FilterChip` |
| `lib/features/auth/widgets/auth_header.dart` | Widgets | Encabezado, banner de error, botón con carga | Composición de widgets |
| `lib/features/auth/auth_provider.dart` | Estado | Usuario, `isBusy`, `error`, login, registro y logout | `ChangeNotifier`, `notifyListeners`, `try/catch` |
| `lib/core/utils/validators.dart` | Utilidad | Reglas de cada campo (`null` = válido) | Validación, null safety |
| `lib/data/preferences/app_preferences.dart` | Local | ¿Ya vio el onboarding? | `SharedPreferences`, clase abstracta |
| `lib/data/datasources/auth_data_source.dart` | Contrato | Clase abstracta de autenticación | Repository / DataSource |
| `lib/data/datasources/fake/fake_auth_data_source.dart` | Fake | Login en memoria para tests | Dobles de prueba (Fake) |
| `lib/data/datasources/firebase/firebase_auth_data_source.dart` | Firebase | Auth + `users/{uid}` + errores en español | Firebase Auth, Firestore, `async/await` |
| `lib/data/repositories/auth_repository.dart` | Repository | Lo único que conoce el provider | Repository |
| `firestore.rules` | Seguridad | Quién lee/escribe qué | Reglas de seguridad |

## 3. Pendientes

- [x] Base en `master` (PR mezclado)
- [x] Simplificar: sin `StreamController`, sin `switch` expresión, sin `_run`
- [ ] `flutter analyze` + `flutter test` + probar en Edge → commit
- [ ] Leer cada archivo de la tabla y anotar en la bitácora qué hace cada parte
- [ ] Calidad: 360 px, zoom 150 %, errores en español, modo sin conexión, onboarding 1 vez, roles
- [ ] **Escribir yo** `test/core/validators_test.dart` (válido e inválido por método)
- [ ] Grabar R1 con cronómetro (< 3 min)
- [ ] `docs/bitacora/jhonnatan.md`: errores (SDK de Dart, PATH, alerta de GitHub, test del feed) + consultas a la IA
- [ ] PR de mi rama → `master`
- [ ] Domingo: cuentas demo y datos · Lunes: Parte A del documento final

## 4. Preguntas de defensa que debo saber responder

1. ¿Por qué `StreamBuilder` y no `FutureBuilder` en `AuthGate`?
2. ¿Por qué el stream se crea en `initState` y no dentro de `build`?
3. ¿Qué pasa si quito `if (!mounted) return;` después de un `await`?
4. ¿Por qué `_leerPerfil` reintenta 3 veces?
5. ¿Cómo cambian de Fake a Firebase sin tocar las pantallas?
6. ¿Qué evita que una organización se cambie el rol? (regla `rol == resource.data.rol`)
7. ¿Por qué la API key de Firebase está en el repo?
8. ¿Por qué `context.watch` en `build` y `context.read` en `onPressed`?

## 5. Cómo pedirle ayuda a la IA (según las reglas del curso)

- **Aclarar:** "Explícame qué hace esta línea y por qué está aquí: …"
- **Consejero:** "Escribí este test, ¿qué casos me faltan o qué está mal?"
- **Consultor:** "¿Qué opciones vistas en clase hay para …? Compáralas."
- **No:** "Hazme la pantalla …". Si la IA cambia código, verificarlo con `git diff` antes del commit.
- Anotar cada consulta en la bitácora: qué pregunté, qué hice y cómo lo verifiqué.
