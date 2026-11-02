# Alejandra Pérez — Responder (20245160)

## Alcance

Rama `feat/alejandra-responder`, creada desde `origin/master` (e25b23f). No se modifica master ni carpetas de otros integrantes. La fuente de avisos en este repositorio se llama `firebase_notification_data_source.dart` (equivalente a la ruta `firestore_...` del reparto).

## Consulta a IA

Solicitud: leer el reparto y completar R4 sin romper el trabajo del equipo. Se revisaron contratos, estados, Fake, reglas y navegación. Se implementaron Postulantes por convocatoria, aceptación, rechazo con motivo, avisos, contador existente y servicio de alertas locales. Alejandra debe revisar el código y reproducir las pruebas antes de defenderlo; esta bitácora registra asistencia de IA, no afirma que ella ya realizó esos pasos.

## Errores y decisiones

- Síntoma: `flutter pub get` falla. Herramienta: Flutter CLI. Causa: SDK instalado Dart 3.13.2, proyecto requiere ^3.13.5. Solución: SDK Flutter 3.47.9 separado dentro del directorio de trabajo de Codex. No se baja el requisito del proyecto ni se cambia el Flutter global.
- La transición pendiente → aceptado no está permitida por el modelo actual. Se pasa primero a enRevision y después a aceptado usando ApplicationRepository. El Fake no valida transiciones: se respeta el contrato para que también funcione en Firebase.
- Si falla cambiar estado después de reservar cupo, se intenta liberar ese cupo. Si falla enviar aviso después de guardar respuesta, se ofrece Reenviar aviso sin repetir aceptación ni cupo mientras esta pantalla siga abierta.
- El historial inicial de avisos no dispara alertas locales. Se recuerda cada ID observado durante la sesión. Marcar leído no vuelve a notificar. Al cambiar usuario se limpian datos y alertas.

## Integración que deben realizar los dueños

José: desde cada convocatoria, abrir `ApplicantsScreen(opportunityId: convocatoria.id)` usando Navigator y MaterialPageRoute. Import: `package:nodara/features/applicants/applicants_screen.dart`. La pantalla crea su provider leyendo el AppDependencies ya instalado en main. El panel actual todavía es PlaceholderView; no se editó.

Rogelio: `ApplicantsScreen` admite `onAccredit: (context, application) { ... }`. El callback debe abrir su diálogo de acreditación. El botón aparece en enCurso, porque el contrato permite completar únicamente desde ese estado. La navegación del ciclo aceptado → confirmado/enCurso corresponde a la integración del equipo; no se inventan cambios en sus modelos.

Jhonnatan: comprobar configuración iOS y recursos de icono de producción. Se confirmó que flutter_local_notifications 22.3.3 ya declara android.permission.POST_NOTIFICATIONS en el manifiesto del plugin; falta verificar permiso permitido/denegado en celular. El servicio pide permiso Android y configura iOS con flutter_local_notifications. Hay que probar permiso permitido/denegado en celular; no se afirma que esta validación esté hecha. Android ya tiene desugaring configurado en la base.

## Límite de los contratos compartidos

ocuparCupo, cambiarEstado y enviar son tres operaciones independientes. El bloqueo de botones evita dobles toques en esta instancia; no proporciona una transacción entre dos coordinadores/celulares. Para garantizar cupos y aceptación atómica, Jhonnatan y los dueños de datos deben acordar un contrato transaccional y su Fake (lectura de postulación y cupos, cambio de estado y aviso en una sola operación). No se modifican sus contratos ni sus reglas desde esta rama.

Un corte de conexión tras confirmar una escritura puede dejar resultado incierto; la compensación no reemplaza una transacción. Los avisos pendientes de reenvío se conservan solo mientras vive el provider. No cerrar la pantalla con un aviso pendiente; el equipo debe acordar persistencia/reconciliación para cubrir reinicios. La fuente Firebase usa IDs nuevos porque las reglas actuales solo permiten a la organización crear avisos ajenos, no leerlos ni actualizarlos.

Las alertas son locales: necesitan que el proceso reciba el stream. No son push y no garantizan entrega con la app cerrada. La lista persistida de avisos sigue disponible al iniciar sesión.

## Defensa breve

El provider escucha las postulaciones de la organización y filtra por ID de convocatoria. La UI usa watch en build y read en acciones, cuatro estados y listas con builder. La aceptación ocupa cupo, cambia estado y crea un aviso en users/{uid}/notifications. Rechazar exige motivo y no ocupa cupo. NotificationsProvider deriva unreadCount de los documentos no leídos y home_shell ya lo muestra en la barra. El servicio local se inyecta para probarlo sin depender del celular.

## Validación

Flutter 3.47.9 / Dart 3.13.7: dart format aplicado solo a archivos propios; flutter analyze --no-pub: 0 hallazgos; flutter test --no-pub: 35 tests aprobados (incluye 7 nuevos de R4). La prueba de humo completa depende de conectar el panel de organización y la acreditación por sus dueños; no se presenta como aprobada.

- Síntoma: flutter analyze aborta con FormatException del servidor LSP. Causa: ruta con caracteres no ASCII en Windows. Solución para analizar y ejecutar tests: ruta alternativa mediante junction dentro del directorio work de Codex. No se cambió el código por este fallo de herramienta.
- Síntoma: Gradle rechaza la ruta original con Ñ. Herramienta: flutter build apk. Solución para verificar compilación: copia temporal del proyecto a work/nodara-build, sin modificar gradle.properties del equipo.
- Síntoma: primer test de widget nuevo no encontraba Aceptar. Causa: FakeSeed ya trae la postulación aceptada. Solución: preparar explícitamente un estado pendiente en el fixture del test. Se repitió la suite completa y pasó.

Referencia consultada para la API 22 de alertas y permisos: https://pub.dev/packages/flutter_local_notifications (también se revisó el código instalado de la versión 22.3.3). Las alertas usan los parámetros nombrados settings y notificationDetails.

Captura: alejandra-postulantes.png, obtenida de un test de widget con datos Fake a 390 px y tema Material de prueba. No sustituye la prueba en celular.

Compilación Android: en curso en la copia temporal; se registrará su resultado por separado.
