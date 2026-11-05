# Javier Alejandro Paniagua Morán — R3 — 20245194

Registro mi trabajo del 2 de noviembre de 2026, antes del congelamiento de las 18:00 (El Salvador), con apoyo de Codex como herramienta de IA para apoyo y guia. Mi revisión y defensa personal siguen pendientes.

## 1) Mi aporte

Mi aporte R3 parte de la base del equipo: `origin/master` en `61eccf6dd2a0aeb28116933dd4ee5ff9467fc27d`. Esa base ya incluía pantallas, Provider, Repository, contratos, Fake, autenticación, DI y conexión Firebase; no la presento como creación mía. En la revisión del repositorio que pedí a Codex, la herramienta no encontró `AGENTS.md` y consultó `RAMAS.md`, el reparto final §3.3 y contratos, y `PLAN.md` §2.

Mi rama: `feat/javier-postularse`, creada desde `origin/master` porque no existía local ni remotamente; merge de master sin cambios pendientes. Mi identidad Git quedó configurada solo en este repositorio con los datos que proporcioné; la cuenta autenticada que se comprobó fue la mía: `JarcoVixO`.

Mi entrega: [commit de implementación f0b6416](https://github.com/Dae51/nodara/commit/f0b641663bdf327eb6a1b45ba6f9753279891479) · [PR #4 en borrador](https://github.com/Dae51/nodara/pull/4), hacia `master`. La rama quedó subida con mi cuenta `JarcoVixO`, sin merge.

Estos son los cambios de mi entrega R3 que Codex propuso dentro de las rutas permitidas:

- `opportunity_detail_screen.dart` y `apply_bar.dart`: carga/error/reintento/inexistente, confirmación antes de guardar, acción deshabilitada y navegación real «Ver mi postulación» a la pestaña correspondiente, con regreso.
- `applications_provider.dart`: bloqueo por convocatoria durante el envío y hasta recibir el stream; errores permiten reintento; retiro valida el estado actual y el usuario. Conserva `hasApplied` y la API de horas, progreso y nivel; agrupación con getters del modelo.
- `my_applications_screen.dart`: pestaña inicial opcional, confirmación de retiro con `mounted`, selección de Cerradas solo tras éxito y estados de carga/error/vacío/datos.
- `application_actions.dart`, `application_card.dart`, `applications_header.dart` y `applications_tab_selector.dart`: Cerradas, estado y motivo legibles, Ver detalle conectado; retiro solo si `siguientes` lo permite. Se quitaron acciones simuladas de chat, QR, PDF, compartir logros, filtros y ayuda.
- `progress_dashboard_card.dart`, `detail_info_cards.dart`, `detail_hero.dart` y `detail_content_cards.dart`: ajuste de línea con texto ampliado y controles de 48 dp, reutilizando los tokens. Se conservaron favoritos, compartir texto y abrir la ruta.
- `firebase_application_data_source.dart`: Codex revisó los cuatro métodos del contrato; se conservan consultas `snapshots`, filtros, creación y transacción. Al retirar no se escriben horas; los valores opcionales ausentes no borran campos existentes. Sin cambios en reglas ni nuevas colecciones.
- `test/features/r3_applications_test.dart`: ocho casos de R3, incluido humo con Fake. En `test/widget_test.dart` solo se adaptó el caso R3 a Confirmar y al nuevo texto.

## 2) Mis decisiones técnicas

Registro aquí las soluciones técnicas que Codex propuso para mi aporte.

- Confirmación con `showDialog<bool>` y `Navigator.pop(true/false)`. Cancelar o cerrar devuelve falso/null y no llama al repositorio. Se descartó añadir una pantalla de confirmación: tarjeta → Postularme → Confirmar son tres toques.
- Dos conjuntos de IDs en el Provider evitan escrituras repetidas por postulación/retiro; se liberan cuando el stream refleja el resultado, o al fallar la escritura. Solo bloquear el botón no cubría otra pantalla ni la demora del stream. La pantalla conserva únicamente el bloqueo del diálogo; comprueba `mounted` tras cada espera.
- `Navigator.push(MaterialPageRoute)` abre la pantalla existente con pestaña inicial y regreso. Se descartó duplicar HomeShell o modificar rutas globales.
- El flujo sigue siendo pantalla → ApplicationsProvider → ApplicationRepository → ApplicationDataSource. El Repository existente copia título, organización, horario y demás datos; Fake y Firebase implementan el mismo contrato. Las horas y el progreso siguen siendo getters, sin datos duplicados guardados.
- Se mantuvo la transacción Firebase y su validación de transiciones. Enviar `null` para horas durante el retiro podía borrar información y modificar un campo no permitido al voluntario; ahora ese campo se omite. Codex verificó este punto mediante la lectura del código y las reglas, no con Firebase real.

## 3) Un error que solucioné

En mi entrega quedó corregido un error que detectó la nueva prueba de render a 360 px y escala 1.3: `RenderFlex overflow` en las filas de organización, detalles, cupos y progreso. Las filas suponían que todo cabía en una línea. Codex aplicó la corrección con `Expanded`/`Flexible`/`Wrap`, quitó los truncamientos de estado, título y motivo, y acortó la etiqueta del contador a «Activas». La prueba y los renders finales pasaron. El widget compartido `StatPill` quedó sin cambios.

Durante la construcción de las pruebas, Codex también corrigió selectores de texto y desplazamiento: el panel realmente dice «Panel de organización · en construcción» y el mensaje temporal podía cubrir el enlace inferior de login. No eran fallos nuevos de producción.

## 4) Pruebas técnicas

Pedí a Codex que verificara mi aporte. La herramienta ejecutó estas pruebas con Flutter 3.47.7 / Dart 3.13.5; no las presento como pruebas manuales realizadas por mí.

| Verificación | Resultado esperado | Resultado obtenido |
| --- | --- | --- |
| Base: `flutter analyze` y `flutter test --no-pub` | Distinguir fallos previos | 0 hallazgos; 20 tests aprobados |
| Final: `flutter analyze` y `flutter test` completos | Sin regresiones | 0 hallazgos; 28 tests aprobados |
| Cancelar, cerrar y confirmar diálogo | 0 escrituras al cancelar/cerrar; 1 en Activas al confirmar | Aprobado con Fake |
| Navegación y retiro | Ver mi postulación abre la pestaña correcta; cancelar conserva; confirmar pasa a Cerradas; regreso y Ver detalle funcionan | Aprobado con Fake |
| Carga y demoras | No crear mientras carga, durante envío ni antes del siguiente snapshot | Aprobado con Fake controlado; una sola creación |
| Fallos de guardar, retirar y leer | Error visible, sin éxito falso, reintento posible | Aprobado con Fake controlado |
| Estados y getters | No perder estados; enCurso no permite retiro; horas/nivel/progreso derivados | Aprobado |
| 360 px y texto 1.3 | Sin overflow en detalle y postulaciones, motivos legibles | Aprobado; cuatro renders inspeccionados con Roboto Flex e íconos Material |
| `git diff --check` y límites | Sin errores de whitespace ni archivos compartidos modificados | Aprobado |

Codex ejecutó `flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8765 --dart-define=NODARA_FAKE=true --no-pub`: compiló y sirvió la app. No hubo navegador controlable ni Android conectado; no registro una prueba manual mía en dispositivo. Los renders son de widgets con Fake y sustitutos de imágenes remotas; no son capturas de Firebase. La evidencia local de mi entrega está en `/tmp/nodara-r3-evidence/01-detalle.png` a `04-cerrada.png`; logs `/tmp/nodara-baseline-analyze.log`, `/tmp/nodara-baseline-test.log`, `/tmp/nodara-final-analyze.log` y `/tmp/nodara-final-test.log`.

La prueba de humo automatizada registra un voluntario nuevo, busca y filtra por causa, completa R3 en tres toques, ve Activas, cierra sesión e ingresa como `org@nodara.app`. Se detiene en el panel en construcción. Quedaron bloqueados: panel/publicación (José), aceptación y aviso (Alejandra; entrada desde panel de José), acreditar/perfil editable/PDF (Rogelio). Mi entrega no incluyó el desarrollo de esos módulos.

En mi entrega quedaron sin probar Firebase real, las reglas desplegadas y las notificaciones reales. Codex revisó estáticamente `watchByUser`, `watchByOrg`, `create` y `updateEstado`; Fake no valida transacciones ni permisos del servidor. El detalle depende de las convocatorias vigentes entregadas por ExploreProvider; una convocatoria fuera de esa lista muestra «no disponible». Mi aporte R3 no requiere cambios compartidos para completarse.

## 5) Uso de IA

Usé Codex como herramienta de apoyo, consulta y orientación para mi aporte R3. Le pedí leer íntegramente `Prompt_Codex_NODARA_Javier.txt`, revisar el repositorio y la rama que realice y verificarlo. Su ayuda incluyó proponer e idear la implementacion, el seguimiento, el retiro, el ajuste Firebase, las pruebas y las correcciones de layout dentro de las rutas permitidas.

Proporcioné y autoricé mi identidad local de Git y el PR en borrador. Mi aceptación personal del código y su defensa siguen pendientes. No registro como realizadas lecturas del curso ni decisiones personales que no estén respaldadas en esta bitácora.
