# José Napoleón Díaz — Publicar (Panel org)

## 1. Alcance
Rama `feat/Napoleon-publicar`, creada desde `origin/master`.
Se implementó de punta a punta la parte asignada a José Napoleón Díaz en el reparto final:
- Panel de organización con lista de convocatorias propias, resumen de métricas y cupos ocupados.
- Formulario completo para crear y editar convocatorias con validaciones síncronas.
- Integración con `ApplicantsScreen` (pantalla de postulantes de Alejandra).
- `OrganizationProvider` para manejo de estado reactivo mediante `ChangeNotifier`.
- Pruebas unitarias y de widgets en `test/features/jose_organization_test.dart`.

## 2. Archivos que pertenecen a esta parte

| Archivo | Capa | Qué hace | Conceptos clave |
|---|---|---|---|
| `lib/features/organization/organization_provider.dart` | Estado | Escucha `watchByOrg` del repositorio, gestiona la lista de convocatorias y los métodos para publicar y actualizar | `ChangeNotifier`, `StreamSubscription`, `notifyListeners` |
| `lib/features/organization/org_home_screen.dart` | UI / Pantalla | Vista principal de la organización: resumen de cupos, lista de convocatorias, navegación a postulantes y edición | `ListView.builder`, 4 estados de UI (`LoadingView`, `EmptyView`, `ErrorView`, datos), `AppCard`, `ImpactProgressBar` |
| `lib/features/organization/opportunity_form_screen.dart` | UI / Pantalla | Formulario para crear o editar convocatorias | `Form`, `GlobalKey<FormState>`, `validators`, `autovalidateMode`, `showDatePicker` |
| `test/features/jose_organization_test.dart` | Pruebas | Comprueba validación de campos obligatorios, publicación de nueva convocatoria y renderizado de métricas en el panel | `testWidgets`, `pumpAndSettle`, dobles de prueba Fake |

## 3. Decisiones técnicas

1. **Uso de Form y GlobalKey<FormState>:**
   Permite validar todos los campos del formulario en un único paso con `_formKey.currentState.validate()` antes de construir el objeto `Opportunity`.

2. **Reutilización del formulario para crear y editar:**
   `OpportunityFormScreen` recibe un `Opportunity? opportunity`. Si es nulo, inicializa los campos vacíos y ejecuta `publicar()`. Si viene con datos, precarga los controladores y ejecuta `actualizar()`.

3. **Manejo de estado desacoplado (`OrganizationProvider`):**
   La lógica de persistencia y suscripción al stream no vive en los widgets. El provider se suscribe al repositorio según el ID de la organización y notifica a la interfaz cuando llegan cambios de Firestore o del Fake.

4. **Navegación e integración limpia:**
   - Para revisar postulantes, el panel abre directamente `ApplicantsScreen(opportunityId: opp.id)` manteniendo la arquitectura del equipo sin tocar archivos ajenos.
   - Para crear/editar se pasa la instancia del provider mediante `ChangeNotifierProvider.value`.

5. **Cumplimiento del checklist de calidad:**
   - Sin force unwraps (`!`).
   - Verificación de `mounted` después de operaciones asíncronas con `await`.
   - Controles interactivos con altura mínima de 48 dp.
   - `ListView.builder` para renderizado eficiente.

## 4. Guía para la defensa oral (Explicación del código)

### ¿Cómo funciona la validación del formulario?
Se utiliza un `Form` asociado a una `GlobalKey<FormState> _formKey`. Cada campo es un `TextFormField` o `DropdownButtonFormField` con una función `validator`. Al presionar el botón de guardar, se invoca `_formKey.currentState!.validate()`. Si algún campo retorna un string de error, el formulario no se envía y se activa `AutovalidateMode.onUserInteraction` para guiar al usuario.

### ¿Cómo se seleccionan las fechas?
Se emplea el método nativo de Flutter `showDatePicker(context, initialDate, firstDate, lastDate)`. Al ser asíncrono, se espera el resultado con `await` y, tras comprobar `if (mounted)`, se actualiza la variable de estado con `setState()`.

### ¿Cómo se comunican la UI y el repositorio?
La pantalla lee `OrganizationProvider` con `context.watch<OrganizationProvider>()` para redibujarse ante cambios en las convocatorias o estados de carga. Las acciones (como guardar) se ejecutan llamando a métodos del provider mediante `context.read<OrganizationProvider>()`. El provider a su vez interactúa con `OpportunityRepository`, garantizando separación de responsabilidades.
