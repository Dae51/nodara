# Arquitectura propuesta para NODARA

## Situación actual

La aplicación ya tiene una separación saludable: `Screen → Provider →
Repository → DataSource`. Auth ya usa Firebase, pero la fábrica Firebase
todavía usa fuentes fake para oportunidades, donaciones, notificaciones,
certificados y —antes de este cambio— postulaciones. La UI tampoco debe leer
Firestore directamente.

## Arquitectura objetivo

```text
Flutter UI
  └─ ChangeNotifier / Provider
      └─ Repository (casos de uso y reglas de negocio)
          └─ DataSource (Firestore o Fake)
              └─ Firebase Auth / Firestore / Storage / Cloud Functions
```

Cada módulo mantiene su contrato abstracto. Esto permite que la app siga
corriendo con `NODARA_FAKE=true` y que los tests no necesiten red. La fábrica
`AppDependencies.firebase()` es el único lugar donde se elige la implementación
real.

Colecciones principales:

- `users/{uid}`: perfil y rol; la identidad vive en Firebase Auth.
- `opportunities/{id}`: convocatorias publicadas por organizaciones.
- `applications/{id}`: una solicitud por usuario y convocatoria, con datos
  resumidos para evitar lecturas N+1.
- `users/{uid}/notifications/{id}`: notificaciones privadas.
- `certificates/{codigo}`: constancias verificables públicamente.

## Solicitudes como máquina de estados

```text
pendiente → enRevision → entrevista → aceptado → confirmado → enCurso
                  │             └→ listaEspera ───────────────┘
                  └→ rechazado       └→ aceptado

enCurso → completado | noShow | cancelado
activo  → retirado (solo voluntario)
```

Los estados terminales son `rechazado`, `completado`, `noShow`, `retirado` y
`cancelado`. Cada cambio guarda `estado`, `en`, `actorId` y `motivo` en
`historial`. Las transiciones se validan en el modelo y en las reglas; la
transacción Firestore evita que una actualización concurrente sobrescriba el
estado anterior.

## Siguiente paso recomendado para producción

Mover a una Cloud Function callable la operación `changeApplicationStatus`.
Esa función debe validar rol y transición, actualizar la solicitud, ajustar
`opportunities.cuposOcupados` solo al aceptar/revertir, crear la notificación
del voluntario y emitir la constancia al completar. Así el cliente nunca puede
fabricar el actor del historial ni modificar cupos directamente.

Antes de publicar reglas, crear índices para `applications.userId` y
`applications.orgId` si Firebase los solicita. Probar reglas con the Firebase
Emulator Suite y agregar tests de transición para cada estado terminal.
