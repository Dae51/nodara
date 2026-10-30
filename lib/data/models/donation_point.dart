import 'model_utils.dart';
import 'opportunity.dart';

/// Punto físico donde se reciben donaciones (víveres, ropa, alimento para
/// animales, etc.).
class DonationPoint {
  const DonationPoint({
    required this.id,
    required this.orgId,
    required this.nombre,
    required this.causa,
    this.aceptan = const [],
    required this.direccion,
    this.departamento = 'San Salvador',
    required this.lat,
    required this.lng,
    required this.horario,
    this.activa = true,
  });

  factory DonationPoint.fromMap(String id, Map<String, Object?> map) =>
      DonationPoint(
        id: id,
        orgId: readString(map['orgId']),
        nombre: readString(map['nombre']),
        causa: readEnum(Causa.values, map['causa'], Causa.comunidades),
        aceptan: readStringList(map['aceptan']),
        direccion: readString(map['direccion']),
        departamento: readString(map['departamento'], 'San Salvador'),
        lat: readDouble(map['lat']) ?? 0,
        lng: readDouble(map['lng']) ?? 0,
        horario: readString(map['horario']),
        activa: readBool(map['activa'], true),
      );

  final String id;
  final String orgId;
  final String nombre;
  final Causa causa;

  /// Qué reciben, ej. ["Víveres", "Ropa"].
  final List<String> aceptan;
  final String direccion;
  final String departamento;
  final double lat;
  final double lng;
  final String horario;
  final bool activa;

  /// Link para abrir la ubicación en Google Maps (usar con url_launcher).
  Uri get mapsUri => Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );

  Map<String, Object?> toMap() => {
        'orgId': orgId,
        'nombre': nombre,
        'causa': causa.name,
        'aceptan': aceptan,
        'direccion': direccion,
        'departamento': departamento,
        'lat': lat,
        'lng': lng,
        'horario': horario,
        'activa': activa,
      };
}
