// Coordina postulaciones para Detalle, Mis postulaciones, Explorar y Perfil.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// Provider, suscripciones y cálculos vienen de la base; R3 reforzó bloqueos y
// validación del retiro.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: Bloqueo de envíos repetidos; Valores derivados; Retiro de postulación;
// Actualización mediante stream.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/data/repositories/auth_repository.dart';

/// Conserva la lista recibida del Repository y avisa a los widgets que la observan.
/// Horas, progreso y nivel se calculan al leerlos: no se guardan por separado.
class ApplicationsProvider extends ChangeNotifier {
  /// Recibe el repositorio de postulaciones y escucha la sesión de AuthRepository.
  ApplicationsProvider(this._repository, AuthRepository authRepository) {
    _authSubscription = authRepository.authStateChanges().listen(
      _onUserChanged,
    );
  }

  // final fija la referencia; los Set finales sí permiten agregar y quitar IDs.
  // El ? del tipo permite null: puede no haber usuario, error o suscripción.
  final ApplicationRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;
  StreamSubscription<List<Application>>? _subscription;

  AppUser? _user;
  List<Application> _applications = const [];
  bool _isLoading = true;
  String? _error;
  final Set<String> _postulando = {};
  final Set<String> _retirando = {};
  bool _disposed = false;

  /// Consulta si opportunityId tiene una creación pendiente de reflejarse.
  bool isSubmitting(String opportunityId) =>
      _postulando.contains(opportunityId);
  /// Consulta si applicationId tiene un retiro pendiente de reflejarse.
  bool isWithdrawing(String applicationId) =>
      _retirando.contains(applicationId);

  /// Permite enviar si hay sesión, datos cargados y ningún envío previo o en curso.
  /// Esta comprobación local no consulta vigencia ni disponibilidad en el servidor.
  bool canApply(String opportunityId) =>
      _user != null &&
      !_isLoading &&
      _error == null &&
      !hasApplied(opportunityId) &&
      !isSubmitting(opportunityId);

  /// Indica si todavía se espera la lista inicial de la suscripción.
  bool get isLoading => _isLoading;
  /// Devuelve el mensaje de lectura fallida, o null si no hay error registrado.
  String? get error => _error;
  /// Expone la última lista del Repository, ordenada por fecha de creación.
  List<Application> get applications => _applications;

  /// Filtra con esActiva del modelo para alimentar la primera pestaña.
  List<Application> get activas =>
      _applications.where((a) => a.estado.esActiva).toList();

  /// Filtra los estados que cuentan horas para la segunda pestaña.
  List<Application> get completadas =>
      _applications.where((a) => a.estado.cuentaHoras).toList();

  /// Agrupa rechazado, noShow, retirado y cancelado según esCerrada del modelo.
  List<Application> get cerradas =>
      _applications.where((a) => a.estado.esCerrada).toList();

  // SECCIÓN: Valores derivados
  // Un getter se lee como propiedad, pero calcula su resultado al consultarlo.

  /// Suma horasQueCuentan del modelo; fold acumula desde cero.
  int get horasCompletadas =>
      _applications.fold(0, (total, a) => total + a.horasQueCuentan);

  /// Lee la meta del perfil; ?. evita acceder a null y ?? usa cero si falta.
  int get horasRequeridas => _user?.horasRequeridas ?? 0;

  /// Resta las horas acreditadas y evita devolver un saldo negativo.
  int get horasFaltantes {
    final faltan = horasRequeridas - horasCompletadas;
    // El ternario condición ? valorSiCierto : valorSiFalso elige el saldo.
    return faltan < 0 ? 0 : faltan;
  }

  /// Devuelve una fracción entre 0 y 1; evita dividir entre cero y limita con clamp.
  double get progreso => horasRequeridas == 0
      ? 0
      : (horasCompletadas / horasRequeridas).clamp(0.0, 1.0);

  /// Convierte la fracción de progreso a porcentaje entero redondeado.
  int get progresoPorcentaje => (progreso * 100).round();

  /// Nivel de impacto: sube uno cada 15 horas acreditadas.
  // ~/ divide y descarta la parte decimal para subir por bloques de 15 horas.
  int get nivel => 1 + horasCompletadas ~/ 15;

  /// Indica si existe alguna postulación no retirada para opportunityId.
  /// También cuenta las completadas o rechazadas; no comprueba vigencia ni cupos.
  bool hasApplied(String opportunityId) => _applications.any(
    (a) =>
        a.opportunityId == opportunityId &&
        a.estado != EstadoPostulacion.retirado,
  );

  // SECCIÓN: Bloqueo de envíos repetidos

  /// Envía opportunity al Repository, que crea una Application pendiente.
  /// Devuelve true si termina la escritura; false si está bloqueada o falla.
  Future<bool> postular(Opportunity opportunity) async {
    // 1. Captura la sesión y valida antes de bloquear la convocatoria.
    final user = _user;
    if (user == null || !canApply(opportunity.id)) return false;
    // 2. El bloqueo es compartido entre pantallas. notifyListeners hace que
    // los widgets con watch reconstruyan sus botones con el estado actualizado.
    _postulando.add(opportunity.id);
    notifyListeners();
    try {
      // 3. await espera la escritura sin bloquear la interfaz. El Repository
      // copia título, organización y horario y delega create al DataSource.
      // El bloqueo se conserva hasta el stream, aunque este Future ya termine.
      await _repository.postular(opportunity: opportunity, user: user);
      return true;
    } catch (_) {
      // 4. Si falla, habilita reintento solo para la misma sesión y Provider vivo.
      // Aquí no hay mounted: es un ChangeNotifier, por eso usa _disposed.
      if (!_disposed && _user?.uid == user.uid) {
        _postulando.remove(opportunity.id);
        notifyListeners();
      }
      return false;
    }
  }

  // SECCIÓN: Retiro de postulación
  /// Busca el estado actual de application y delega el retiro al Repository.
  /// Devuelve true al completar la escritura o false si no se permite o falla.
  Future<bool> retirar(Application application) async {
    // 1. Usa la lista más reciente; firstOrNull devuelve null si ya no está.
    final current = _applications
        .where((a) => a.id == application.id)
        .firstOrNull;
    // 2. Exige propietario, carga completa, transición permitida y ningún retiro
    // en curso. siguientes pertenece al modelo y excluye retirarse en enCurso.
    if (current == null ||
        _user?.uid != current.userId ||
        _isLoading ||
        _error != null ||
        !current.estado.siguientes.contains(EstadoPostulacion.retirado) ||
        isWithdrawing(application.id)) {
      return false;
    }
    // 3. Bloquea por ID de postulación y actualiza los botones que la muestran.
    _retirando.add(application.id);
    notifyListeners();
    try {
      // 4. Espera updateEstado(retirado) a través del Repository.
      // El stream quitará el bloqueo cuando observe el estado retirado.
      await _repository.retirar(application);
      return true;
    } catch (_) {
      // 5. Un error de escritura libera el bloqueo y permite volver a intentarlo.
      if (!_disposed && _user?.uid == application.userId) {
        _retirando.remove(application.id);
        notifyListeners();
      }
      return false;
    }
  }

  /// Reinicia la lectura para la sesión actual; no repite escrituras.
  void retry() => _subscribeFor(_user);

  /// Recibe usuario o null de AuthRepository y adapta la suscripción de la lista.
  void _onUserChanged(AppUser? user) {
    final sameUser = user?.uid == _user?.uid;
    _user = user;
    if (sameUser && _subscription != null) {
      notifyListeners(); // solo cambió el perfil (ej. horasRequeridas)
      return;
    }
    // Al cambiar de cuenta o cerrar sesión se descartan bloqueos de la anterior.
    _postulando.clear();
    _retirando.clear();
    _subscribeFor(user);
  }

  // SECCIÓN: Actualización mediante stream
  /// Sustituye la escucha por la del usuario; null limpia datos al cerrar sesión.
  /// watchMine delega a watchByUser del DataSource y ordena cada lista por fecha.
  void _subscribeFor(AppUser? user) {
    // 1. Cancela la escucha anterior para no mantener dos listas activas.
    _subscription?.cancel();
    _subscription = null;
    _applications = const [];
    _error = null;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    // 2. Presenta carga mientras se espera el primer evento de watchMine.
    _isLoading = true;
    notifyListeners();
    _subscription = _repository
        .watchMine(user.uid)
        .listen(
          // 3. Este callback se ejecuta por cada lista emitida, no solo al entrar.
          (items) {
            _applications = items;
            // El bloqueo continúa hasta que el stream refleja la escritura.
            _postulando.removeWhere(hasApplied);
            _retirando.removeWhere(
              (id) => items.any(
                (a) => a.id == id && a.estado == EstadoPostulacion.retirado,
              ),
            );
            // 4. Con la nueva lista, getters y pestañas se recalculan en build.
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          // 5. La lectura fallida muestra error y permite retry desde la pantalla.
          // No se anuncia éxito ni se eliminan aquí los bloqueos de escritura.
          onError: (Object _) {
            _isLoading = false;
            _error = 'No pudimos cargar tus postulaciones.';
            notifyListeners();
          },
        );
  }

  /// Cancela escuchas y marca el Provider como destruido antes de liberar recursos.
  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
