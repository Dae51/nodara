import 'model_utils.dart';

/// Aviso dentro de la app (`users/{uid}/notifications/{id}`).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    this.applicationId,
    this.leida = false,
    required this.creadaEn,
  });

  factory AppNotification.fromMap(String id, Map<String, Object?> map) =>
      AppNotification(
        id: id,
        titulo: readString(map['titulo']),
        cuerpo: readString(map['cuerpo']),
        applicationId: map['applicationId'] is String
            ? map['applicationId'] as String
            : null,
        leida: readBool(map['leida']),
        creadaEn: readDate(map['creadaEn']) ?? DateTime.now(),
      );

  final String id;
  final String titulo;
  final String cuerpo;
  final String? applicationId;
  final bool leida;
  final DateTime creadaEn;

  Map<String, Object?> toMap() => {
        'titulo': titulo,
        'cuerpo': cuerpo,
        'applicationId': applicationId,
        'leida': leida,
        'creadaEn': creadaEn,
      };

  AppNotification copyWith({String? id, bool? leida}) => AppNotification(
        id: id ?? this.id,
        titulo: titulo,
        cuerpo: cuerpo,
        applicationId: applicationId,
        leida: leida ?? this.leida,
        creadaEn: creadaEn,
      );
}
