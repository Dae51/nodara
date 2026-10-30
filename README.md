# NODARA

App Flutter que conecta a jóvenes de 18 a 25 años de El Salvador con voluntariados y puntos de donación.
Proyecto final de Desarrollo de Aplicaciones Móviles (ESEN). El plan completo está en [`PLAN.md`](PLAN.md).

## Cómo correrla

```bash
flutter pub get

# Con Firebase (necesita lib/firebase_options.dart)
flutter run

# Sin Firebase: todo en memoria (ideal para trabajar la UI)
flutter run --dart-define=NODARA_FAKE=true

flutter analyze   # debe dar 0 hallazgos
flutter test
```

**Cuentas de prueba en modo Fake** (cualquier contraseña de 6 o más caracteres):

| Correo | Rol |
|---|---|
| `sofia@nodara.app` | Voluntaria (estudiante, 45/80 hrs) |
| `org@nodara.app` | Organización (Fundación Futuro Joven) |

## Arquitectura

```
Pantalla → Provider (ChangeNotifier) → Repository → DataSource (Firebase | Fake)
```

| Carpeta | Qué contiene |
|---|---|
| `lib/theme/` | Colores, tipografía, espaciado y sombras (la paleta **no se cambia**) |
| `lib/core/` | Inyección de dependencias, utilidades (toast, validadores, fechas, íconos) y widgets comunes, incluidos los 4 estados de UI |
| `lib/data/models/` | Modelos puros con `fromMap`/`toMap` (sin `IconData`, sin Firebase) |
| `lib/data/datasources/` | Contratos abstractos + implementaciones `fake/` y `firebase/` |
| `lib/data/repositories/` | Lo único que conocen los providers y las pantallas |
| `lib/features/<módulo>/` | Pantallas, widgets y provider de cada módulo |

**Para conectar un módulo a Firebase:**
1. Crea `lib/data/datasources/firebase/firebase_<modulo>_data_source.dart` que implemente el contrato.
2. Cámbialo en `AppDependencies.firebase()` (`lib/core/di/app_dependencies.dart`).
3. Las pantallas no se tocan.

## Dueños por módulo

| Módulo | Carpeta | Responsable |
|---|---|---|
| Base, Auth, Firebase | `core/`, `data/`, `features/auth/` | Jhonnatan |
| Explorar y Donaciones | `features/explore/`, `features/donations/` | Josué |
| Postulaciones y panel de organización | `features/applications/`, `features/organization/` | José |
| Notificaciones, Perfil y reporte PDF | `features/notifications/`, `features/profile/` | Rogelio |
| Diseño, textos y assets | `assets/` | Alejandra |
| Tests y QA | `test/` | Javier y José |

## Convenciones

- **Ramas:** `f<fase>/<tema>` (ej. `f2/filtros-causa`). Nada entra a `main` sin un PR revisado.
- **Commits:** `f2-filtros: chips de causa [CARNET]`
- **Antes de abrir un PR:** `flutter analyze` en 0, `flutter test` en verde y el checklist de `PLAN.md` §2 revisado.
