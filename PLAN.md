# NODARA — Plan de trabajo

> Proyecto final · Desarrollo de Aplicaciones Móviles (Flutter + Dart) · ESEN
> Versión 1 · 27/10/2026 · Documento vivo: se actualiza con cada avance.

---

## 1. Decisiones cerradas

| Tema | Decisión |
|---|---|
| Marca | **NODARA** (se elimina "EcháUnaMano" del código) |
| Paleta de colores | **No se modifica.** Solo se decide qué token existente va en cada lugar |
| Manejo de estado | **Provider** (`ChangeNotifier` + `ChangeNotifierProvider`), visto en clase |
| Backend | Firebase **plan Spark (gratis)**: Auth + Firestore. Sin Cloud Functions ni Storage |
| Notificaciones | **Locales** (`flutter_local_notifications`) disparadas por un listener de Firestore |
| Categorías | Dos dimensiones: **Causa** + **Formato** (ver §4) |
| Navegación | `StreamBuilder<User?>` con `authStateChanges()` en la raíz + `Navigator.push`, visto en clase |
| Costo | $0.00 |

---

## 2. Reglas del curso que el código debe cumplir

Salen del material de clase y de la rúbrica. **Se revisan en cada PR.**

- [ ] `flutter analyze` con **0 hallazgos**
- [ ] `const` en todo constructor donde se pueda
- [ ] Prohibido usar `dynamic` si el tipo se conoce
- [ ] **Prohibido el `!`** (aserción de nulo) en producción: usar `?.` y `??`
- [ ] `if (!mounted) return;` después de **todo** `await`, antes de `setState` o de usar `context`
- [ ] **Nunca `ListView(children: [...])` con datos de Firestore o de la API**: usar `ListView.builder`
- [ ] `FutureBuilder`: el `Future` se guarda en `initState`, nunca se crea dentro de `future:`
- [ ] Provider: `context.watch` **solo** en `build`, `context.read` **solo** en callbacks (`onPressed`…)
- [ ] Valores derivados con **getters** (horas, progreso, cupos libres), nunca guardados aparte
- [ ] Extraer widgets como **clases**, no como métodos que retornan `Widget`
- [ ] Toda vista con datos asíncronos muestra **4 estados**: cargando · éxito · vacío · error
- [ ] UI sin overflow a **360 px** de ancho
- [ ] Área táctil mínima de **48×48** en todo lo que se toca
- [ ] El estado nunca se comunica **solo con color** (siempre ícono o texto)
- [ ] Texto escalable: nada de alturas fijas que corten el texto (probar con escala 1.3)
- [ ] Modelos puros: `fromMap`/`toMap`, sin `IconData` ni lógica visual
- [ ] Las pantallas solo conocen al **Repository**, nunca a Firestore directo

> Contraste verificado con la paleta actual: todas las combinaciones de texto principales pasan **4.5:1**.
> `outline` sobre blanco da 4.49: usarlo solo como *hint*, no para texto importante.

---

## 3. Alcance (ficha) vs. estado actual

| # | Alcance / requisito de la ficha | Hoy | Meta |
|---|---|---|---|
| R1 | Registro en < 3 min, ≤ 5 campos (Firebase Auth) | ❌ | Registro: nombre, correo, contraseña, tipo, intereses |
| R2 | ≥ 4 convocatorias activas y vigentes en la vista principal | ⚠️ 3 mocks | ≥ 8 en Firestore, ≥ 4 vigentes |
| R3 | Postularse en ≤ 3 toques desde la tarjeta | ✅ 2 toques | Mantener + confirmación |
| R4 | Aviso de estado Aceptado/Rechazado en < 5 s | ❌ | Notificación local + tab Notificaciones |
| R5 | PDF con código de validación en < 3 s | ❌ | `pdf` + QR, registro en `certificates` |
| — | Puntos de donación | ❌ | Lista + filtro + "Cómo llegar" (Maps) |
| — | Filtro por categoría | ⚠️ | Causa + formato (§4) |
| — | Panel de organizaciones | ❌ | Crear convocatoria, ver postulantes, aceptar/rechazar/completar |

**Ajustes a la ficha:**
- R4 dice "notificación push". Cambiarlo a **"notificación en el dispositivo"**.
- Punto 7: aclarar que se usa el plan **Spark** de Firebase.

---

## 4. Categorías: Causa + Formato

| Dimensión | Valores | UI |
|---|---|---|
| **Causa** | Medio Ambiente · Animales · Comunidades · Educación · Salud · Cultura · Emergencias | Chips del feed (`FilterChip`) |
| **Formato** | Jornada (1 día) · Programa (varias semanas/sesiones) · Permanente (te unes a la org) · Virtual | Hoja de filtros (`showModalBottomSheet`) |
| **Extras** | Acredita horas sí/no · Departamento | Misma hoja |

- La ficha exige medioambiente, animales y comunidades. Agregar más causas **no rompe la ficha**.
- Insignia de la tarjeta: `Educación · Programa`.
- El pie de la tarjeta depende del formato:
  - Jornada: `Sáb 15 nov`
  - Programa: `4 semanas`
  - Permanente: `Convocatoria abierta`

**Datos de ejemplo (contexto SV, con fines académicos):**

| Ejemplo | Causa | Formato |
|---|---|---|
| Reforestación (tipo SalvaNatura) | Medio Ambiente | Jornada |
| Clubes extracurriculares (tipo Glasswing) | Educación | Programa |
| Guía voluntario en museo infantil (tipo Tin Marín) | Educación / Cultura | Programa |
| Construcción de viviendas (tipo TECHO) | Comunidades | Jornada |
| Socorrismo (tipo Cruz Roja) | Emergencias | Permanente |
| Refugio de animales | Animales | Jornada |
| Tutorías en línea | Educación | Virtual |

**Reglas:**
- **Vigente** = `activa == true` y que hoy sea antes de `cierreInscripcion`.
- **Horas acreditadas** = las escribe la org al marcar la postulación como `completado`. Por defecto valen `horasEstimadas`.

---

## 5. Arquitectura

Usa los patrones vistos en clase: Repository + DataSource, inyección por constructor, SOLID (D) y capas.

```
lib/
  main.dart                      ← Firebase.initializeApp + MultiProvider + AuthGate
  firebase_options.dart          ← generado por flutterfire configure
  theme/                         ← (ya existe) app_colors, app_theme, app_spacing, app_shadows
  core/
    utils/                       ← validators, formato de fechas, icon_mapper, toast
    widgets/                     ← app_card, remote_image, stat_pill, empty_view, error_view, loading_view
  data/
    models/                      ← app_user, opportunity, application, donation_point, certificate, app_notification
    datasources/
      opportunity_data_source.dart          ← abstracta
      firestore_opportunity_data_source.dart
      fake_opportunity_data_source.dart     ← mocks actuales → desarrollo y tests
      (igual para auth, application, donation, certificate, notification)
    repositories/
      opportunity_repository.dart           ← recibe el DataSource por constructor
      ...
  features/
    auth/            (auth_gate, onboarding, login, register) + auth_provider
    explore/         (explore_screen, filters_sheet, opportunity_card) + explore_provider
    opportunity_detail/
    applications/    + applications_provider
    donations/       + donations_provider
    notifications/   + notifications_provider
    profile/         (profile, edit_profile, report_pdf)
    organization/    (org_home, create_opportunity_form, applicants_screen) + org_provider
test/
  models/  repositories/  widgets/
```

**Flujo de dependencias:** `Screen → Provider (ChangeNotifier) → Repository → DataSource (Firestore | Fake)`

**Raíz de la app (visto en clase):**
```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
    if (!snapshot.hasData) return const OnboardingOrLogin();
    return const RoleGate(); // voluntario → HomeShell · organizacion → OrgHome
  },
);
```

**Navegación:**
- `Navigator.push(MaterialPageRoute(...))` pasando **solo el `id`**. La pantalla lee el dato desde el Provider o el Repository.
- Se eliminan `onGenerateRoute`, `pushNamed` y los `arguments as`.

---

## 6. Modelo de datos (Firestore)

```
users/{uid}
  nombre, email, tipo: estudiante|graduado|trabajador,
  rol: voluntario|organizacion, intereses[], favoritos[], creadoEn

opportunities/{id}
  orgId, orgNombre, titulo, descripcion,
  causa, formato: jornada|programa|permanente, modalidad: presencial|virtual,
  departamento, ubicacion, direccion,
  fechaInicio?, fechaFin?, cierreInscripcion,
  acreditaHoras, horasEstimadas, compromiso,
  cuposTotal, cuposOcupados,
  requisitos[], beneficios[{iconKey, titulo, subtitulo}],
  imagenKey,            ← imagen por causa en assets/ (sin Storage)
  activa, creadoEn

applications/{id}
  opportunityId, oportunidadTitulo, userId, orgId,
  estado: pendiente|aceptado|rechazado|completado|retirado,
  horasAcreditadas?, motivo?, creadaEn, actualizadaEn

donationPoints/{id}
  orgId, nombre, causa, aceptan[], direccion, departamento, lat, lng, horario, activa

certificates/{codigo}     ← código de validación, ej. NOD-7F3K-92QA
  userId, nombre, applicationIds[], totalHoras, emitidoEn

users/{uid}/notifications/{id}
  titulo, cuerpo, applicationId, leida, creadaEn
```

**Getters (no se guardan):**
- `Opportunity.cuposLibres`
- `Opportunity.estaVigente`
- `perfil.horasCompletadas` = suma de `horasAcreditadas` con estado `completado`
- `perfil.progreso`

**Atomicidad:**
- Aceptar una postulación hace un batch con dos escrituras:
  - `applications/{id}.estado = "aceptado"` + `opportunities/{id}.cuposOcupados: FieldValue.increment(1)`
  - Creación de `users/{uid}/notifications/{nuevo}`

**Reglas de seguridad (mínimo):**
- Un usuario lee y escribe solo su `users/{uid}`
- `opportunities`: todos leen; solo `rol == organizacion` crea, y solo la org dueña edita
- `applications`:
  - El voluntario crea y lee las suyas, y solo puede pasarlas a `retirado`
  - La org dueña lee las de sus oportunidades y cambia su estado
- `notifications`: el dueño lee y marca como leída; la org crea solo para quienes se postularon a sus oportunidades
- `certificates`: lectura pública por código (para validar); solo el dueño crea

---

## 7. Flujos clave

**Postulación completa:**
```
ORG crea convocatoria → VOLUNTARIO filtra → Detalle → "Postularme" → confirma
  → applications (pendiente)
ORG → Postulantes → Aceptar / Rechazar (batch: estado + cupos + notificación)
  → VOLUNTARIO recibe notificación local + badge
ORG → Marcar completado (horasAcreditadas) → horas del perfil suben solas
VOLUNTARIO → Perfil → "Descargar reporte" → PDF con código + QR
```

**Notificación sin costo:**
```
App del voluntario: escucha users/{uid}/notifications where leida == false
  → nuevo documento → flutter_local_notifications.show(...)
  → tocar la notificación → abre el tab Postulaciones
Limitación: no llega con la app cerrada por completo (documentado en DEFENSA.md)
```

**Donación:**
```
Explorar → selector [Voluntariados | Donar] → lista de puntos (causa, qué aceptan, horario)
  → "Cómo llegar" → url_launcher abre Google Maps con lat/lng
```

---

## 8. Fases

Dependencias: **F0 → F1 → (F2 ∥ F3) → (F4 ∥ F5) → F6**

### F0 · Base y refactor (1 persona, 1-2 días; nadie más toca `lib/` mientras tanto)
- [ ] Agregar `provider` y reemplazar `AppState`/`AppScope` por providers
- [ ] Crear la estructura de §5 y mover las pantallas a `features/`
- [ ] Modelos con `fromMap`/`toMap`; reemplazar `IconData` por `iconKey` + `icon_mapper`
- [ ] DataSources abstractos + **Fake** con los mocks actuales; Repositories con inyección por constructor
- [ ] `ListView(children:)` → `ListView.builder` en Explorar y Postulaciones
- [ ] Partir `my_applications_screen` (1054 líneas) y `opportunity_detail_screen` (893) en widgets
- [ ] `app_spacing.dart` y `app_shadows.dart` (mover los hex de sombras repetidos; **sin cambiar valores**)
- [ ] Utilidad única de toast (se elimina `_toast`/`_showToast` duplicados)
- [ ] Eliminar `onGenerateRoute`/`pushNamed`
- [ ] Logo, imágenes y fuente Roboto Flex dentro de `assets/`
- [ ] README real; descripción en `pubspec`
- **Listo cuando:** la app **se ve igual**, `flutter analyze` = 0 y los tests pasan con el Fake

### F1 · Firebase y Auth
- [ ] `flutterfire configure` + `Firebase.initializeApp`
- [ ] `AuthGate` con `StreamBuilder` + `RoleGate`
- [ ] Registro con `Form` + `GlobalKey<FormState>` + `TextFormField` + `validator` + `autovalidateMode.onUserInteraction` + `FocusNode`/`TextInputAction`
- [ ] Login, cerrar sesión, `FirebaseAuthException` traducida al español
- [ ] Onboarding solo la primera vez (`shared_preferences`)
- **Listo cuando:** se cronometra **R1 < 3 min**

### F2 · Contenido real
- [ ] `FirestoreOpportunityDataSource` + feed con `StreamBuilder` y **4 estados**
- [ ] Script o pantalla de *seed*: ≥ 8 oportunidades SV (§4), ≥ 4 vigentes
- [ ] Chips de causa + hoja de filtros (formato, horas, departamento); el empty state ofrece "Limpiar filtros"
- [ ] Selector Voluntariados | Donar + puntos de donación + `url_launcher`
- [ ] Favoritos guardados en el usuario + vista "Guardados" (un solo ícono: corazón)
- [ ] Textos localizados (tú, contexto SV, 2026); quitar los textos de Tutorías repetidos en todas las oportunidades
- [ ] **Quitar los 13 botones que no hacen nada** o implementarlos
- **Listo cuando:** se verifican R2 (≥ 4 vigentes) y R3 (≤ 3 toques)

### F3 · Postulaciones y panel de organización
- [ ] Estados `pendiente|aceptado|rechazado|completado|retirado` con colores de tokens existentes (`error`, `success`, `warning`) + ícono + texto
- [ ] Tabs Activas | Completadas | Cerradas (con motivo)
- [ ] Postularse con confirmación; el botón cambia a "Ver mi postulación"
- [ ] "Retirarme" (antes "Cancelar") con diálogo que retorna `bool` usando `Navigator.pop(context, valor)`
- [ ] Org: formulario de crear convocatoria (validado), lista de postulantes, aceptar/rechazar (batch + `increment`), marcar completado
- [ ] Reglas de seguridad de §6
- **Listo cuando:** el flujo de punta a punta funciona con 2 cuentas (voluntario + org)

### F4 · Notificaciones
- [ ] `notifications_provider` escuchando la subcolección
- [ ] `flutter_local_notifications` + permiso en Android 13+
- [ ] El tab **Notificaciones** reemplaza a Mensajes (lista + marcar leída + `Badge` en la `NavigationBar`)
- **Listo cuando:** se graba un **video de R4 < 5 s** con dos celulares

### F5 · PDF y perfil
- [ ] Generar el código `NOD-XXXX-XXXX` y guardarlo en `certificates/{codigo}`
- [ ] PDF (`pdf` + `printing`): datos del voluntario, tabla de actividades completadas, total de horas, código y QR (`pw.BarcodeWidget`)
- [ ] Perfil: datos reales, editar nombre/intereses, horas calculadas, botón "Descargar reporte", cerrar sesión
- **Listo cuando:** se verifica **R5 < 3 s**

### F6 · QA y entrega
- [ ] Tests unitarios: modelos (`fromMap`/`toMap`), getters (horas, vigencia, cupos)
- [ ] Widget tests con DataSources Fake: feed, filtros, postulación, estados vacío y error
- [ ] Checklist de §2 completo; pruebas a 360 px y con escala de texto 1.3
- [ ] Pruebas en celular real Android
- [ ] Evidencias R1–R5 (cronómetro y video)
- [ ] `BITACORA.md` y `DEFENSA.md` completos

---

## 9. Temas que no se vieron en clase (investigación propia)

Cada uno se registra en `BITACORA.md` con: fuente consultada, decisión tomada y problemas encontrados.

| Tema | Paquete | Alcance mínimo |
|---|---|---|
| PDF + QR | `pdf`, `printing` | Un solo layout de reporte |
| Notificaciones locales | `flutter_local_notifications` | Mostrar y abrir la app al tocar |
| Abrir Maps | `url_launcher` | Un link `geo:`/Google Maps |
| Reglas de Firestore por rol | — | Solo las reglas de §6 |
| Fechas en español | `intl` | `DateFormat` con `es` |

**No se usan:** `go_router`, `firebase_messaging`, Cloud Functions, Storage, `permission_handler` (el permiso de notificaciones lo pide el propio plugin) ni `flutter_secure_storage` (Firebase Auth ya guarda la sesión de forma segura; **nunca** se guardan contraseñas).

---

## 10. Paquetes

| Paquete | ¿Visto en clase? | Uso |
|---|---|---|
| `provider` | ✅ | Estado compartido |
| `firebase_core`, `firebase_auth`, `cloud_firestore` | ✅ | Backend |
| `shared_preferences` | ✅ | Onboarding visto |
| `google_fonts` → fuente en assets | ✅ (assets) | Tipografía offline |
| `url_launcher` | ❌ | Cómo llegar |
| `intl` | ❌ | Fechas |
| `flutter_local_notifications` | ❌ | R4 |
| `pdf`, `printing` | ❌ | R5 |

---

## 11. Convenciones de equipo

**Ramas:**
- `main`: protegida, solo se entra por PR aprobado
- Formato: `f<fase>/<tema-corto>` (ej. `f2/filtros-causa`, `f3/panel-org`)

**Commits** (formato del curso):
```
f2-filtros: chips de causa y hoja de filtros [CARNET]
```

**Pull Request:**
- 1 revisor mínimo (idealmente QA)
- Checklist de §2 marcado
- `flutter analyze` en 0
- Captura o GIF si cambia la UI

**Archivos de proceso:**
- `BITACORA.md`: errores, causa, solución y fuente (*"no funcionaba y lo reinstalé" no es una bitácora*)
- `DEFENSA.md`: decisiones técnicas y respuestas de sustentación
- `IA.md`: herramienta, para qué se usó, qué se ajustó o rechazó y cómo se verificó

**Uso de IA:** permitido para ideas y para explicar errores. **Cada integrante debe poder explicar su código línea por línea.** Aplicar una corrección de IA sin verificarla da cero.

---

## 12. Rúbrica de referencia (laboratorios del curso)

| Criterio | Peso | Cómo lo cubre el plan |
|---|---|---|
| Funcionalidad | 40 % | R1–R5 + panel org + donaciones (F1–F5) |
| Estructura y legibilidad | 25 % | Features + Repository/DataSource + widgets extraídos (F0) |
| Buenas prácticas y rendimiento | 20 % | Checklist §2, `analyze` en 0, `mounted`, `ListView.builder` |
| Sustentación | 15 % | `DEFENSA.md` + cada quien domina su módulo |

---

## 13. Riesgos

| Riesgo | Mitigación |
|---|---|
| Conflictos de merge en F0 | F0 la hace una sola persona y el resto espera o prepara datos/diseño |
| La notificación no llega con la app cerrada | Documentarlo en DEFENSA.md y grabar la demo con la app en segundo plano |
| Defensa oral que contradice el escrito (= 0 en sustentación) | Cada persona escribe su parte de DEFENSA.md |
| Cuotas de Firestore en la demo | Seed pequeño y listeners con `limit()` |

---

## 14. Equipo y asignación

**Entrega final: martes 3 de noviembre de 2026.** Quedan 6 días de trabajo.

**Cada persona es dueña de carpetas distintas** para no pisarse. Al final de cada día se hace merge a `main`.

| Persona | Rol | Es dueño de | Fases |
|---|---|---|---|
| **Jhonnatan Peñate** | Dev · líder técnico | `data/`, `core/`, `features/applications/`, `features/organization/` | **F0**, F3, integración y merges |
| **Rogelio Montalvo** | Dev | `features/auth/`, `features/profile/`, Firebase (proyecto + reglas) | F1, F5 |
| **Josué Portillo** | Dev | `features/explore/`, `features/donations/`, `features/notifications/`, seed | F2, F4 |
| **Alejandra Pérez** | UI/UX | Diseños en Stitch, textos, `assets/`, contenido seed | Apoyo a F1–F5 |
| **José Días** | QA | `test/models/`, revisión del checklist §2 en PRs, evidencias R1 y R5 | F6 (continuo) |
| **Javier Paniagua** | QA | `test/widgets/`, pruebas manuales (360 px, escala 1.3, 48 dp), evidencias R2, R3 y R4 | F6 (continuo) |

### Lo que F0 deja listo para que todos avancen en paralelo ("contratos")

- [ ] Las interfaces de **todos** los DataSources y Repositories definidas, con su versión Fake funcionando
- [ ] Modelos finales de §6 (incluye causa/formato y donaciones)
- [ ] Providers base registrados en `MultiProvider` (aunque estén vacíos)
- [ ] Carpetas de `features/` creadas con **pantallas placeholder** (login, registro, donar, notificaciones, panel org), cada una con su ruta de navegación
- [ ] Widgets comunes: `LoadingView`, `EmptyView`, `ErrorView`
- [ ] PR mergeado a `main` con `flutter analyze` en 0

### Cronograma

| Día | Jhonnatan | Rogelio | Josué | Alejandra | José (QA) | Javier (QA) |
|---|---|---|---|---|---|---|
| **Mié 28** | **F0 completa** y merge en la noche | Crea el proyecto Firebase, `flutterfire configure` y borrador de reglas (sin tocar `lib/`) | Prototipo de PDF y notificación local en un proyecto aparte | Diseños: login/registro, hoja de filtros, Donar, Notificaciones, panel org, PDF | Casos de prueba R1–R5 (pasos + resultado esperado) | Plantillas de `BITACORA.md`, `DEFENSA.md` e `IA.md` |
| **Jue 29** | F3: estados, tabs, postularse/retirarse | **F1**: AuthGate, registro, login, onboarding 1 vez | **F2**: DataSource Firestore + feed con 4 estados | Textos localizados + JSON seed (8 oportunidades, 5 puntos de donación) + imágenes por causa | Tests de modelos (`fromMap`/`toMap`, getters) | Revisa F0 en celular: 360 px, escala 1.3, 48 dp |
| **Vie 30** | F3: panel org (crear convocatoria, postulantes) | F1: errores en español + `RoleGate` + reglas publicadas | F2: filtros causa/formato + Donar + Maps | Revisión de UI en PRs | Revisa PRs con el checklist §2 | Widget tests con Fake: feed y filtros |
| **Sáb 31** | F3: aceptar/rechazar/completar (batch + `increment`) | **F5**: generación del código + PDF + QR | **F4**: listener + notificación local + tab | Guion de la demo | Evidencia R1 (cronómetro) | Evidencia R2 y R3 |
| **Dom 1** | Integración del flujo completo + fixes | F5: perfil con horas reales + descargar reporte | F4: badge + marcar leída + abrir Postulaciones | Ajustes visuales finales | Evidencia R5 | Evidencia R4 (video con 2 celulares) |
| **Lun 2** | **Congelamiento 12:00 m.d.**: solo bugs | Fixes + su parte de DEFENSA | Fixes + su parte de DEFENSA | Su parte de DEFENSA + IA.md | Regresión completa | Regresión completa |
| **Mar 3** | **Entrega** | | | | | |

### Recorte si no da el tiempo (en este orden)
1. Vista "Guardados" (el favorito sigue funcionando)
2. Filtro por departamento
3. Editar perfil (se queda solo lectura)
4. Causas Cultura y Emergencias (se quedan las otras 5)

**No se recorta nunca:** R1–R5, panel org, puntos de donación ni el checklist §2.

### Reglas de la semana
- **`lib/` queda congelado hasta que F0 esté en `main`** (miércoles en la noche). Antes de eso se trabaja fuera de `lib/`: Firebase, diseños, prototipos, tests escritos y documentación.
- Check-in diario de 15 min (WhatsApp o llamada): qué hice, qué sigue, qué me bloquea.
- Nadie hace merge a `main` sin un PR revisado.
- Commits con el formato del curso: `f2-filtros: chips de causa [CARNET]`. Cada quien pone su carnet.
