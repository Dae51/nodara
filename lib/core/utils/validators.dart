/// Validadores para `TextFormField.validator`.
///
/// Convención vista en clase: devolver `null` = válido; devolver un texto =
/// mensaje de error que se muestra bajo el campo.
abstract final class Validators {
  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? requerido(String? value, {String campo = 'este campo'}) {
    if (value == null || value.trim().isEmpty) return 'Completa $campo.';
    return null;
  }

  static String? nombre(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Ingresa tu nombre.';
    if (texto.length < 2) return 'El nombre es muy corto.';
    return null;
  }

  static String? email(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Ingresa tu correo.';
    if (!_emailRegExp.hasMatch(texto)) return 'El correo no es válido.';
    return null;
  }

  static String? password(String? value) {
    final texto = value ?? '';
    if (texto.isEmpty) return 'Ingresa una contraseña.';
    if (texto.length < 6) return 'Usa al menos 6 caracteres.';
    return null;
  }

  /// Campo opcional: vacío es válido; si tiene algo, debe ser 1..2000.
  static String? horasOpcionales(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return null;
    final horas = int.tryParse(texto);
    if (horas == null || horas < 1 || horas > 2000) {
      return 'Ingresa un número entre 1 y 2000.';
    }
    return null;
  }
}
