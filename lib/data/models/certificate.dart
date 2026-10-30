import 'model_utils.dart';

/// Reporte de horas emitido. Su [codigo] es el ID del documento en
/// `certificates/{codigo}` y sirve para validarlo.
class Certificate {
  const Certificate({
    required this.codigo,
    required this.userId,
    required this.nombre,
    required this.applicationIds,
    required this.totalHoras,
    required this.emitidoEn,
  });

  factory Certificate.fromMap(String codigo, Map<String, Object?> map) =>
      Certificate(
        codigo: codigo,
        userId: readString(map['userId']),
        nombre: readString(map['nombre']),
        applicationIds: readStringList(map['applicationIds']),
        totalHoras: readInt(map['totalHoras']),
        emitidoEn: readDate(map['emitidoEn']) ?? DateTime.now(),
      );

  final String codigo;
  final String userId;
  final String nombre;
  final List<String> applicationIds;
  final int totalHoras;
  final DateTime emitidoEn;

  Map<String, Object?> toMap() => {
        'userId': userId,
        'nombre': nombre,
        'applicationIds': applicationIds,
        'totalHoras': totalHoras,
        'emitidoEn': emitidoEn,
      };
}
