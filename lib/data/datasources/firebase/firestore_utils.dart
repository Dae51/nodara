import 'package:cloud_firestore/cloud_firestore.dart';

/// Convierte un documento de Firestore a un mapa "plano": los `Timestamp`
/// pasan a `DateTime`, así los modelos no dependen de Firebase.
Map<String, Object?> fromFirestore(Map<String, dynamic> data) =>
    data.map((key, value) => MapEntry(key, _convert(value)));

Object? _convert(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is Map) {
    return value.map((key, inner) => MapEntry(key.toString(), _convert(inner)));
  }
  if (value is List) return value.map(_convert).toList();
  return value;
}
