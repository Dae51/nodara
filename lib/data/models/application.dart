import 'model_utils.dart';
import 'opportunity.dart';

/// Ciclo de vida de una postulación.
///
/// pendiente → aceptado | rechazado → completado.
/// retirado = el voluntario canceló.
enum EstadoPostulacion {
  pendiente('Pendiente de aprobación'),
  aceptado('Seleccionado / En curso'),
  rechazado('No aceptada'),
  completado('Finalizado y Acreditado'),
  retirado('Retirada');

  const EstadoPostulacion(this.label);

  final String label;

  bool get esActiva => this == pendiente || this == aceptado;

  bool get esCerrada => this == rechazado || this == retirado;
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

  /// Horas que cuentan para el perfil (solo si está completada).
  int get horasQueCuentan => estado == EstadoPostulacion.completado
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
      };

  Application copyWith({
    String? id,
    EstadoPostulacion? estado,
    int? horasAcreditadas,
    String? motivo,
    DateTime? actualizadaEn,
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
      );
}
