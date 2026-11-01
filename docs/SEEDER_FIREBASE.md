# Seeder de Firebase

El seeder crea o actualiza datos de demostración con IDs `seed-*`. Es
idempotente: puede ejecutarse varias veces sin duplicar documentos. No borra
datos existentes.

Incluye un mínimo de diez registros por entidad:

| Entidad | Cantidad |
| --- | ---: |
| Usuarios en Firebase Auth y `users` | 10 |
| `opportunities` | 10 |
| `applications` | 10 |
| `donationPoints` | 10 |
| `certificates` | 10 |
| `users/{uid}/notifications` | 10 en total |

## Ejecutarlo

1. Descarga una cuenta de servicio del proyecto Firebase y guarda su JSON
   fuera del repositorio.
2. Define las variables de entorno y ejecuta el script:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/ruta/segura/service-account.json"
export NODARA_SEED_PASSWORD="una-clave-de-demo-segura"
export FIREBASE_PROJECT_ID="nodara-community" # opcional, es el valor por defecto

cd tool/firebase_seeder
npm install
npm run seed
```

Las diez cuentas se crean con la contraseña indicada. Algunas útiles para la
demo son `sofia@nodara.demo` (voluntaria) y `futuro.joven@nodara.demo`
(organización).

El script usa Firebase Admin SDK, por lo que no está limitado por las reglas
de Firestore. Solo debe correrse contra un proyecto de desarrollo o el
emulador, nunca con credenciales de producción sin autorización explícita.
