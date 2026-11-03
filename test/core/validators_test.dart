import 'package:flutter_test/flutter_test.dart';

import 'package:nodara/core/utils/validators.dart';

/// Pruebas unitarias de los validadores del formulario de acceso.
/// Convención del curso: `null` = válido; un texto = mensaje de error.
void main() {
  group('Validators.email', () {
    test('acepta un correo válido', () {
      expect(Validators.email('ana@correo.com'), isNull);
    });

    test('ignora espacios al inicio y al final', () {
      expect(Validators.email('  ana@correo.com  '), isNull);
    });

    test('pide el correo si está vacío o es null', () {
      expect(Validators.email(''), 'Ingresa tu correo.');
      expect(Validators.email(null), 'Ingresa tu correo.');
    });

    test('rechaza un correo sin dominio', () {
      expect(Validators.email('ana@'), 'El correo no es válido.');
      expect(Validators.email('ana.correo.com'), 'El correo no es válido.');
    });
  });

  group('Validators.password', () {
    test('acepta 6 caracteres o más', () {
      expect(Validators.password('secreta1'), isNull);
      expect(Validators.password('123456'), isNull);
    });

    test('pide la contraseña si está vacía', () {
      expect(Validators.password(''), 'Ingresa una contraseña.');
    });

    test('rechaza menos de 6 caracteres', () {
      expect(Validators.password('123'), 'Usa al menos 6 caracteres.');
    });
  });

  group('Validators.nombre', () {
    test('acepta un nombre de 2 letras o más', () {
      expect(Validators.nombre('Ana'), isNull);
    });

    test('pide el nombre si está vacío', () {
      expect(Validators.nombre('   '), 'Ingresa tu nombre.');
    });

    test('rechaza un nombre de 1 letra', () {
      expect(Validators.nombre('A'), 'El nombre es muy corto.');
    });
  });

  group('Validators.horasOpcionales', () {
    test('vacío es válido porque el campo es opcional', () {
      expect(Validators.horasOpcionales(''), isNull);
      expect(Validators.horasOpcionales(null), isNull);
    });

    test('acepta un número entre 1 y 2000', () {
      expect(Validators.horasOpcionales('80'), isNull);
      expect(Validators.horasOpcionales('2000'), isNull);
    });

    test('rechaza texto, cero y números fuera de rango', () {
      const mensaje = 'Ingresa un número entre 1 y 2000.';
      expect(Validators.horasOpcionales('abc'), mensaje);
      expect(Validators.horasOpcionales('0'), mensaje);
      expect(Validators.horasOpcionales('2001'), mensaje);
    });
  });
}
