import 'model_utils.dart';
import 'opportunity.dart';

/// Ciclo de vida de una postulación.
///
/// pendiente → aceptado | rechazado → completado.
/// retirado = el voluntario canceló.
enum EstadoPostulacion {
  pendiente('Pendiente de aprobación'),
  enRevision('En revisión'),
  entrevista('Entrevista / validación'),
  listaEspera('En lista de espera'),
  aceptado('Seleccionado / En curso'),
  confirmado('Asistencia confirmada'),
  enCurso('Jornada en curso'),
  rechazado('No aceptada'),
  completado('Finalizado y Acreditado'),
  noShow('No se presentó'),
  retirado('Retirada'),
  cancelado('Cancelada por la organización');

  const EstadoPostulacion(this.label);

  final String label;

  bool get esActiva => {
        pendiente,
        enRevision,
        entrevista,
        listaEspera,
        aceptado,
        confirmado,
        enCurso,
      }.contains(this);

  bool get esCerrada => {
        rechazado,
        noShow,
        retirado,
        cancelado,
      }.contains(this);

  bool get esTerminal => esCerrada || this == completado;

  bool get cuentaHoras => this == completado;

  /// Estados que la organización puede seleccionar desde el estado actual.
  /// La fuente de datos vuelve a validar esta transición antes de escribir.
  List<EstadoPostulacion> get siguientes => switch (this) {
        pendiente => [enRevision, rechazado, retirado],
        enRevision => [entrevista, aceptado, listaEspera, rechazado, retirado],
        entrevista => [aceptado, listaEspera, rechazado, retirado],
        listaEspera => [aceptado, rechazado, retirado],
        aceptado => [confirmado, enCurso, cancelado, retirado],
        confirmado => [enCurso, cancelado, retirado],
        enCurso => [completado, noShow, cancelado],
        rechazado || completado || noShow || retirado || cancelado => const [],
      };
}

class ApplicationStatusChange {
  const ApplicationStatusChange({
    required this.estado,
    required this.en,
    required this.actorId,
    this.motivo,
  });

  factory ApplicationStatusChange.fromMap(Map<String, Object?> map) =>
      ApplicationStatusChange(
        estado: readEnum(EstadoPostulacion.values, map['estado'], EstadoPostulacion.pendiente),
        en: readDate(map['en']) ?? DateTime.now(),
        actorId: readString(map['actorId']),
        motivo: map['motivo'] is String ? map['motivo'] as String : null,
      );

  final EstadoPostulacion estado;
  final DateTime en;
  final String actorId;
  final String? motivo;

  Map<String, Object?> toMap() => {
        'estado': estado.name,
        'en': en,
        'actorId': actorId,
        'motivo': motivo,
      };
}

/// Postulación de un voluntario a una [Opportunity].
///
/// Guarda una copia de los datos de la oportunidad que se muestran en la
/// tarjeta (título, org, imagen, horario) para no tener que leer otro
/// documento por cada tarjeta.
class Application {
  const Application({
    required this.id,
    required this.opportunityId,
    required this.oportunidadTitulo,
    required this.orgId,
    required this.orgNombre,
    required this.userId,
    required this.causa,
    this.imagenUrl = '',
    this.horario = '',
    required this.horasEstimadas,
    this.horasAcreditadas,
    required this.estado,
    this.motivo,
    required this.creadaEn,
    required this.actualizadaEn,
    this.historial = const [],
  });

  factory Application.fromMap(String id, Map<String, Object?> map) {
    final creada = readDate(map['creadaEn']) ?? DateTime.now();
    return Application(
      id: id,
      opportunityId: readString(map['opportunityId']),
      oportunidadTitulo: readString(map['oportunidadTitulo']),
      orgId: readString(map['orgId']),
      orgNombre: readString(map['orgNombre']),
      userId: readString(map['userId']),
      causa: readEnum(Causa.values, map['causa'], Causa.comunidades),
      imagenUrl: readString(map['imagenUrl']),
      horario: readString(map['horario']),
      horasEstimadas: readInt(map['horasEstimadas']),
      horasAcreditadas:
          map['horasAcreditadas'] is num ? readInt(map['horasAcreditadas']) : null,
      estado: readEnum(
        EstadoPostulacion.values,
        map['estado'],
        EstadoPostulacion.pendiente,
      ),
      motivo: map['motivo'] is String ? map['motivo'] as String : null,
      creadaEn: creada,
      actualizadaEn: readDate(map['actualizadaEn']) ?? creada,
      historial: readMapList(map['historial'])
          .map(ApplicationStatusChange.fromMap)
          .toList(growable: false),
    );
  }

  final String id;
  final String opportunityId;
  final String oportunidadTitulo;
  final String orgId;
  final String orgNombre;
  final String userId;
  final Causa causa;
  final String imagenUrl;
  final String horario;
  final int horasEstimadas;

  /// Horas que la organización acreditó al marcarla como completada.
  final int? horasAcreditadas;
  final EstadoPostulacion estado;

  /// Motivo de rechazo (opcional).
  final String? motivo;
  final DateTime creadaEn;
  final DateTime actualizadaEn;
  final List<ApplicationStatusChange> historial;

  /// Horas que cuentan para el perfil (solo si está completada).
  int get horasQueCuentan => estado.cuentaHoras
      ? (horasAcreditadas ?? horasEstimadas)
      : 0;

  Map<String, Object?> toMap() => {
        'opportunityId': opportunityId,
        'oportunidadTitulo': oportunidadTitulo,
        'orgId': orgId,
        'orgNombre': orgNombre,
        'userId': userId,
        'causa': causa.name,
        'imagenUrl': imagenUrl,
        'horario': horario,
        'horasEstimadas': horasEstimadas,
        'horasAcreditadas': horasAcreditadas,
        'estado': estado.name,
        'motivo': motivo,
        'creadaEn': creadaEn,
        'actualizadaEn': actualizadaEn,
        'historial': historial.map((item) => item.toMap()).toList(),
      };

  Application copyWith({
    String? id,
    EstadoPostulacion? estado,
    int? horasAcreditadas,
    String? motivo,
    DateTime? actualizadaEn,
    List<ApplicationStatusChange>? historial,
  }) =>
      Application(
        id: id ?? this.id,
        opportunityId: opportunityId,
        oportunidadTitulo: oportunidadTitulo,
        orgId: orgId,
        orgNombre: orgNombre,
        userId: userId,
        causa: causa,
        imagenUrl: imagenUrl,
        horario: horario,
        horasEstimadas: horasEstimadas,
        horasAcreditadas: horasAcreditadas ?? this.horasAcreditadas,
        estado: estado ?? this.estado,
        motivo: motivo ?? this.motivo,
        creadaEn: creadaEn,
        actualizadaEn: actualizadaEn ?? this.actualizadaEn,
        historial: historial ?? this.historial,
      );
}
