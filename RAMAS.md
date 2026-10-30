# Ramas, PR e integración: NODARA

> Léanlo antes de su primer commit. El reparto completo está en `NODARA_Reparto_Final.docx`.
> Rama principal: **`master`**. Entrega: **martes 3 de noviembre, 12:00 m.d.**

---

## 1. Ramas

| Rama | Para qué | Quién hace merge |
|---|---|---|
| `master` | Lo que se entrega. Siempre tiene que compilar. | Solo Jhonnatan, por PR |
| `base/estructura` | La base (arquitectura, auth, Firebase). **Va primero.** | Jhonnatan |
| `feat/jhonnatan-acceso` | Onboarding, login, registro | Jhonnatan |
| `feat/josue-descubrir` | Explorar + puntos de donación | Josué |
| `feat/javier-postularse` | Detalle + Mis postulaciones | Javier |
| `feat/jose-publicar` | Panel de organización + formulario | José |
| `feat/alejandra-responder` | Postulantes + Avisos | Alejandra |
| `feat/rogelio-acreditar` | Acreditar horas + Perfil + PDF | Rogelio |
| `fix/<tema>` | Arreglo urgente después del congelamiento | Quien lo encuentre |

- **Nadie hace commit directo a `master`.**
- Una sola rama por persona. Si necesitas probar algo raro, crea `exp/<tema>` y no la mezcles.

---

## 2. Qué va primero y qué puede ir en paralelo

```
base/estructura  ──►  master   (BLOQUEANTE: nadie empieza antes)
                        │
        ┌───────┬───────┼───────┬────────┬────────┐
     acceso  descubrir postularse publicar responder acreditar   ← todos en paralelo con el modo Fake
        │       │        │        │        │        │
        └──► se integran a master en este orden ──►┘
             1 acceso · 2 descubrir · 3 postularse · 4 publicar · 5 responder · 6 acreditar
```

- **¿Se puede hacer R2 antes que R1?** Sí. Con `--dart-define=NODARA_FAKE=true` todo funciona en memoria, así que cada quien avanza su pantalla sin esperar a nadie.
- **El orden importa solo al conectar Firebase real**, porque cada parte lee lo que guarda la anterior:

| Parte | Para probar con datos reales necesita |
|---|---|
| Descubrir (Josué) | Firebase configurado (acceso) |
| Postularse (Javier) | Convocatorias reales (Josué) |
| Publicar (José) | DataSource de convocatorias (Josué) |
| Responder (Alejandra) | Postulaciones reales (Javier) + cupos (Josué) |
| Acreditar (Rogelio) | Postulaciones aceptadas (Alejandra) |

- Si alguien se atrasa, **los demás siguen con el Fake** y se integran cuando les toque.

---

## 3. Flujo diario

```powershell
# Al empezar el día: traer lo último de master
git checkout feat/<tu-rama>
git fetch origin
git merge origin/master

# Trabajar y hacer commits pequeños
git add lib/features/<tu-carpeta>
git commit -m "<parte>: <qué hiciste> [CARNET]"

# Antes de subir
dart format lib test
flutter analyze        # 0 hallazgos
flutter test           # TODOS en verde, no solo los tuyos
git push
```

- **Commits:** `<parte>: <qué hiciste> [CARNET]`, por ejemplo `descubrir: hoja de filtros por formato [20230123]`.
- **Con tu propia cuenta de GitHub.** Tus commits son la prueba de tu aporte en la hoja individual.
- **Nunca** `git push --force` a una rama compartida.

---

## 4. Pull Request

**Para abrirlo:**
1. El título dice qué parte es: `Descubrir: explorar conectado a Firestore`.
2. En la descripción: qué hace, captura o GIF de la pantalla y qué probaste.
3. Solo trae archivos de **tus carpetas** (ver tabla de dueños, §6).

**Para aprobarlo (lo revisa otra persona):**
- [ ] `flutter analyze` en 0
- [ ] `flutter test` en verde (GitHub Actions lo corre solo)
- [ ] No toca carpetas de otros ni archivos compartidos
- [ ] Checklist del curso: sin `!`, `mounted` después de cada `await`, `ListView.builder` con datos de la base, 4 estados de UI (cargando, datos, vacío, error), botones de 48 dp, nada de `dynamic`, `watch` en `build` y `read` en callbacks
- [ ] Sin `TODO`, sin código muerto, sin `print`
- [ ] Prueba de humo en modo Fake hecha (§5)

**Merge:** Jhonnatan hace merge a `master` todos los días a las **9:00 p.m.**, en el orden del §2.

---

## 5. Probar sin romper la pantalla de otro

1. **Tests del equipo = red de seguridad.** Si tu cambio rompe el test de otra persona, lo arreglas tú antes del merge.
2. **Cada quien suma al menos 1 test** de su parte en `test/` (unitario o de widget con el Fake).
3. **Prueba de humo antes de cada PR**, en modo Fake (`flutter run --dart-define=NODARA_FAKE=true`):
   - [ ] Registrarse como voluntario nuevo
   - [ ] Explorar, buscar y filtrar por causa
   - [ ] Abrir un detalle y postularse
   - [ ] Ver la postulación en Mis postulaciones
   - [ ] Cerrar sesión y entrar como `org@nodara.app`
   - [ ] Aceptar la postulación y verificar que llega el aviso
   - [ ] Acreditar horas y ver el perfil y el PDF
4. **GitHub Actions** (`.github/workflows/flutter.yml`) corre `analyze` y `test` en cada PR. Si sale en rojo, no se mezcla.

---

## 6. Dueños de archivos

| Ruta | Dueño |
|---|---|
| `lib/features/auth/`, `firebase_auth_data_source.dart` | Jhonnatan |
| `lib/features/explore/`, `lib/features/donations/`, `firestore_opportunity_data_source.dart`, `firestore_donation_data_source.dart` | Josué |
| `lib/features/opportunity_detail/`, `lib/features/applications/`, `firestore_application_data_source.dart` | Javier |
| `lib/features/organization/` | José |
| `lib/features/applicants/`, `lib/features/notifications/`, `firestore_notification_data_source.dart` | Alejandra |
| `lib/features/accreditation/`, `lib/features/profile/`, `firestore_certificate_data_source.dart` | Rogelio |
| **Compartidos:** `main.dart`, `core/di/app_dependencies.dart`, `features/home/home_shell.dart`, `pubspec.yaml`, `firestore.rules`, `lib/data/models/`, los contratos `*_data_source.dart`, `lib/theme/` | **Solo Jhonnatan** (los demás lo piden en el grupo) |

**¿Necesitas un método nuevo en un contrato o un campo en un modelo?** Lo pides en el grupo. Jhonnatan lo agrega en `master` con su versión Fake, y tú haces `git merge origin/master` en tu rama.

**¿Tu pantalla necesita una pestaña o un botón en la pantalla de otro?** Por ejemplo, Rogelio necesita un botón "Acreditar" en Postulantes, que es de Alejandra. El dueño de la pantalla agrega el botón y llama al widget de la otra persona, que vive en la carpeta de esa persona.

---

## 7. Código limpio y defendible

Usamos IA y lo declaramos. Lo que se evalúa es que **cada quien entienda y defienda su código**, así que todo lo que entra a `master` tiene que estar limpio y explicado por su dueño:

- Si no sabes explicar una línea, no la subas.
- Comentarios cortos, en español y con tus palabras, explicando el **porqué**.
- Nombres consistentes en español para el dominio (oportunidad, postulación, horas, cupos).
- Nada de código muerto, `TODO` ni `print`.
- `dart format` antes de cada commit.
- **Bitácora** (`docs/bitacora/<nombre>.md`): cada error con síntoma, herramienta, causa y solución, y cada consulta a la IA con qué preguntaste, qué hiciste y cómo lo verificaste. De ahí sale tu hoja individual.

---

## 8. Calendario

| Cuándo | Qué |
|---|---|
| Vie 30 | `base/estructura` → `master` (Jhonnatan). Todos clonan y crean su rama. |
| Sáb 31 | Cada parte funciona con el Fake + su DataSource de Firebase |
| Dom 1 | Integración a `master` en el orden del §2 |
| **Lun 2, 6:00 p.m.** | **Congelamiento.** Solo ramas `fix/`. Etiqueta `v1.0-entrega`. |
| Lun 2, noche | Ensayo de la demo y de la defensa |
| **Mar 3, 12:00 m.d.** | **Entrega** |
