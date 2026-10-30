import 'package:flutter_test/flutter_test.dart';

import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/opportunity.dart';

Opportunity _opportunity({
  int cuposTotal = 10,
  int cuposOcupados = 4,
  bool activa = true,
  required DateTime cierre,
}) =>
    Opportunity(
      id: 'o1',
      orgId: 'org',
      orgNombre: 'Org',
      titulo: 'Título largo',
      tituloCorto: 'Corto',
      descripcion: 'Desc',
      causa: Causa.animales,
      formato: Formato.jornada,
      etiqueta: 'Animales',
      ubicacion: 'San Salvador',
      horario: 'Sábado',
      compromiso: '1 día',
      cierreInscripcion: cierre,
      horasEstimadas: 8,
      cuposTotal: cuposTotal,
      cuposOcupados: cuposOcupados,
      beneficios: const [
        Benefit(iconKey: 'seguro', titulo: 'Seguro', subtitulo: 'Incluido'),
      ],
      activa: activa,
    );

void main() {
  final hoy = DateTime(2026, 10, 28);

  group('Opportunity', () {
    test('toMap / fromMap conserva los datos', () {
      final original = _opportunity(cierre: hoy);
      final copia = Opportunity.fromMap(original.id, original.toMap());

      expect(copia.titulo, original.titulo);
      expect(copia.causa, Causa.animales);
      expect(copia.formato, Formato.jornada);
      expect(copia.cierreInscripcion, hoy);
      expect(copia.beneficios.single.iconKey, 'seguro');
    });

    test('cuposLibres nunca es negativo', () {
      expect(_opportunity(cuposOcupados: 4, cierre: hoy).cuposLibres, 6);
      expect(_opportunity(cuposOcupados: 15, cierre: hoy).cuposLibres, 0);
    });

    test('estaVigente depende de activa y del cierre de inscripción', () {
      final cierre = hoy.add(const Duration(days: 2));
      expect(_opportunity(cierre: cierre).estaVigente(hoy), isTrue);
      expect(
        _opportunity(cierre: cierre, activa: false).estaVigente(hoy),
        isFalse,
      );
      expect(
        _opportunity(cierre: hoy.subtract(const Duration(days: 1)))
            .estaVigente(hoy),
        isFalse,
      );
    });

    test('un enum desconocido cae en el valor por defecto', () {
      final map = _opportunity(cierre: hoy).toMap()..['causa'] = 'otra';
      expect(Opportunity.fromMap('x', map).causa, Causa.comunidades);
    });
  });

  group('Application', () {
    Application app(EstadoPostulacion estado, {int? acreditadas}) =>
        Application(
          id: 'a1',
          opportunityId: 'o1',
          oportunidadTitulo: 'Corto',
          orgId: 'org',
          orgNombre: 'Org',
          userId: 'u1',
          causa: Causa.animales,
          horasEstimadas: 8,
          horasAcreditadas: acreditadas,
          estado: estado,
          creadaEn: hoy,
          actualizadaEn: hoy,
        );

    test('solo las completadas cuentan horas', () {
      expect(app(EstadoPostulacion.aceptado).horasQueCuentan, 0);
      expect(app(EstadoPostulacion.completado).horasQueCuentan, 8);
      expect(
        app(EstadoPostulacion.completado, acreditadas: 6).horasQueCuentan,
        6,
      );
    });

    test('esActiva / esCerrada', () {
      expect(EstadoPostulacion.pendiente.esActiva, isTrue);
      expect(EstadoPostulacion.aceptado.esActiva, isTrue);
      expect(EstadoPostulacion.rechazado.esCerrada, isTrue);
      expect(EstadoPostulacion.retirado.esCerrada, isTrue);
      expect(EstadoPostulacion.completado.esActiva, isFalse);
    });

    test('toMap / fromMap conserva estado y horas', () {
      final original = app(EstadoPostulacion.completado, acreditadas: 6);
      final copia = Application.fromMap(original.id, original.toMap());
      expect(copia.estado, EstadoPostulacion.completado);
      expect(copia.horasAcreditadas, 6);
    });
  });
}
