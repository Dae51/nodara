/// Funciones auxiliares para leer mapas (Firestore / JSON) de forma segura,
/// sin usar `!` ni `dynamic`.
library;

/// Convierte DateTime, milisegundos o texto ISO a [DateTime].
///
/// La capa de Firestore convierte sus `Timestamp` a DateTime antes de
/// llamar a `fromMap`, así los modelos no dependen de Firebase.
DateTime? readDate(Object? value) {
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}

String readString(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

int readInt(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

double? readDouble(Object? value) => value is num ? value.toDouble() : null;

bool readBool(Object? value, [bool fallback = false]) =>
    value is bool ? value : fallback;

List<String> readStringList(Object? value) =>
    value is List ? value.whereType<String>().toList() : <String>[];

List<Map<String, Object?>> readMapList(Object? value) => value is List
    ? value.whereType<Map>().map(Map<String, Object?>.from).toList()
    : <Map<String, Object?>>[];

/// Busca un valor de enum por su `name`; si no existe devuelve [fallback].
T readEnum<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
