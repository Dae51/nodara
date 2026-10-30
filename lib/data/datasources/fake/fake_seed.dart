import 'package:nodara/core/constants/remote_assets.dart';
import 'package:nodara/data/models/app_notification.dart';
import 'package:nodara/data/models/app_user.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/models/donation_point.dart';
import 'package:nodara/data/models/opportunity.dart';

/// Datos de ejemplo para los DataSources Fake (desarrollo y tests).
///
/// Las fechas se calculan desde "hoy" para que las convocatorias
/// siempre estén vigentes.
abstract final class FakeSeed {
  static const sofiaId = 'user_sofia';
  static const orgFuturoId = 'org_futuro';

  static AppUser get sofia => AppUser(
        uid: sofiaId,
        nombre: 'Sofía',
        email: 'sofia@nodara.app',
        tipo: TipoUsuario.estudiante,
        rol: RolUsuario.voluntario,
        intereses: const [Causa.educacion, Causa.medioambiente],
        horasRequeridas: 80,
        carrera: 'Servicio Social',
        avatarUrl: RemoteAssets.sofiaAvatar,
        creadoEn: DateTime(2026, 2, 1),
      );

  /// Cuenta de organización para probar el panel org (F3).
  static AppUser get orgFuturo => AppUser(
        uid: orgFuturoId,
        nombre: 'Fundación Futuro Joven',
        email: 'org@nodara.app',
        rol: RolUsuario.organizacion,
        creadoEn: DateTime(2026, 1, 15),
      );

  static List<AppUser> get users => [sofia, orgFuturo];

  static List<Opportunity> opportunities() {
    final hoy = DateTime.now();
    return [
      Opportunity(
        id: 'tutorias',
        orgId: orgFuturoId,
        orgNombre: 'Fundación Futuro Joven & Facultad de Ciencias',
        titulo: 'Tutorías Universitarias de Matemáticas y Apoyo Escolar',
        tituloCorto: 'Tutorías de Matemáticas y Ciencias',
        descripcion:
            'Este programa acompaña a más de 45 adolescentes de barrios vulnerables que cursan los últimos años de secundaria y preparatoria. Como tutor voluntario, facilitarás talleres de refuerzo práctico en álgebra básica, resolución de problemas y razonamiento lógico.',
        causa: Causa.educacion,
        formato: Formato.programa,
        etiqueta: 'Educación · Escolar',
        ubicacion: 'Centro Comunitario San Martín',
        direccion: 'Av. San Martín 1420',
        referencia: 'A 2 cuadras del Campus Central',
        horario: 'Sábados de 9:00 a 13:00 hrs',
        compromiso: 'Inicio formal: 15 de Abril (4 sábados consecutivos)',
        fechaInicio: hoy.add(const Duration(days: 7)),
        fechaFin: hoy.add(const Duration(days: 35)),
        cierreInscripcion: hoy.add(const Duration(days: 5)),
        horasEstimadas: 15,
        cuposTotal: 12,
        cuposOcupados: 4,
        requisitos: const [
          'Estudiantes universitarios activos a partir de 2° año (todas las carreras son bienvenidas).',
          'Disponibilidad presencial los sábados por la mañana durante el período del programa.',
          'Empatía, vocación social y compromiso ético de asistir a un mínimo de 4 sesiones consecutivas.',
          'Participar en el taller virtual de bienvenida e inducción pedagógica (viernes 14 Abril, 18:00 hrs).',
        ],
        beneficios: const [
          Benefit(
            iconKey: 'certificado',
            titulo: 'Certificado Oficial Académico',
            subtitulo: 'Con validez curricular de 15 horas de servicio social.',
          ),
          Benefit(
            iconKey: 'seguro',
            titulo: 'Póliza y Cobertura Integral',
            subtitulo:
                'Seguro contra accidentes de voluntariado durante las actividades.',
          ),
          Benefit(
            iconKey: 'refrigerio',
            titulo: 'Refrigerio y Materiales Incluidos',
            subtitulo:
                'Kit de enseñanza, cuadernillos y snack energizante en cada sesión.',
          ),
        ],
        imagenUrl: RemoteAssets.detailHero,
        avataresInscritos: const [
          RemoteAssets.attendee1,
          RemoteAssets.attendee2,
          RemoteAssets.attendee3,
        ],
        calificacion: 4.9,
        resenas: 120,
      ),
      Opportunity(
        id: 'reforestacion',
        orgId: 'org_ecovida',
        orgNombre: 'EcoVida ONG',
        titulo: 'Jornada de Reforestación y Limpieza de Cuencas',
        descripcion:
            'Sumate a la restauración de la ribera plantando especies nativas y limpiando las cuencas del sector. Una jornada en equipo para recuperar el ecosistema local y crear conciencia ambiental.',
        causa: Causa.medioambiente,
        formato: Formato.jornada,
        etiqueta: 'Medio Ambiente',
        ubicacion: 'Reserva Ribereña',
        horario: 'Jornadas de sábado, 8:00 a 14:00 hrs',
        compromiso: 'Próxima jornada: 20 de Abril',
        fechaInicio: hoy.add(const Duration(days: 10)),
        cierreInscripcion: hoy.add(const Duration(days: 8)),
        horasEstimadas: 20,
        cuposTotal: 20,
        cuposOcupados: 16,
        requisitos: const [
          'Ganas de trabajar al aire libre en equipo.',
          'Ropa cómoda y calzado cerrado para actividad en exteriores.',
          'Asistir a la charla de seguridad previa a la jornada.',
        ],
        beneficios: const [
          Benefit(
            iconKey: 'eco',
            titulo: 'Certificado de Participación',
            subtitulo: 'Con validez de 20 horas de servicio social.',
          ),
          Benefit(
            iconKey: 'seguro',
            titulo: 'Kit de Seguridad',
            subtitulo: 'Guantes, herramientas y seguro de voluntariado.',
          ),
        ],
        imagenUrl: RemoteAssets.reforestacionImage,
        avataresInscritos: const [RemoteAssets.attendee2, RemoteAssets.attendee3],
        calificacion: 4.7,
        resenas: 86,
      ),
      Opportunity(
        id: 'salud',
        orgId: 'org_cruz',
        orgNombre: 'Cruz Universitaria',
        titulo: 'Campaña de Salud y Prevención Dental Comunitaria',
        descripcion:
            'Acompañá a las familias del barrio en la campaña de prevención y educación en salud bucal. Colaborás en la recepción, organización de turnos y talleres de higiene para niños.',
        causa: Causa.salud,
        formato: Formato.jornada,
        etiqueta: 'Salud Comunitaria',
        ubicacion: 'Centro de Salud Sur',
        horario: 'Sábado 9:00 a 15:00 hrs',
        compromiso: 'Inicia este sábado',
        fechaInicio: hoy.add(const Duration(days: 4)),
        cierreInscripcion: hoy.add(const Duration(days: 3)),
        horasEstimadas: 12,
        cuposTotal: 15,
        cuposOcupados: 6,
        requisitos: const [
          'Estudiantes de cualquier carrera con vocación de servicio.',
          'Disponibilidad el sábado durante toda la jornada.',
          'Manejo básico de atención al público.',
        ],
        beneficios: const [
          Benefit(
            iconKey: 'certificado',
            titulo: 'Certificado de Participación',
            subtitulo: 'Con validez de 12 horas de servicio social.',
          ),
          Benefit(
            iconKey: 'refrigerio',
            titulo: 'Refrigerio Incluido',
            subtitulo: 'Snack y agua durante la jornada.',
          ),
        ],
        imagenUrl: RemoteAssets.saludImage,
        avataresInscritos: const [RemoteAssets.attendee1, RemoteAssets.attendee3],
        calificacion: 4.8,
        resenas: 64,
      ),
    ];
  }

  /// Postulaciones de Sofía: 1 en curso + 2 completadas (20 + 25 = 45 hrs).
  static List<Application> applications() {
    final hoy = DateTime.now();
    return [
      Application(
        id: 'app_tutorias',
        opportunityId: 'tutorias',
        oportunidadTitulo: 'Tutorías de Matemáticas y Ciencias',
        orgId: orgFuturoId,
        orgNombre: 'Fundación Futuro Joven & Facultad de Ciencias',
        userId: sofiaId,
        causa: Causa.educacion,
        imagenUrl: RemoteAssets.appTutoriasThumb,
        horario: 'Sábado · 09:00 hrs (Campus Central)',
        horasEstimadas: 15,
        estado: EstadoPostulacion.aceptado,
        creadaEn: hoy.subtract(const Duration(days: 3)),
        actualizadaEn: hoy.subtract(const Duration(days: 1)),
      ),
      Application(
        id: 'app_banco',
        opportunityId: 'banco-alimentos',
        oportunidadTitulo: 'Banco de Alimentos Comunitario',
        orgId: 'org_red_solidaria',
        orgNombre: 'Red Solidaria',
        userId: sofiaId,
        causa: Causa.comunidades,
        imagenUrl: RemoteAssets.appBancoThumb,
        horasEstimadas: 20,
        horasAcreditadas: 20,
        estado: EstadoPostulacion.completado,
        creadaEn: hoy.subtract(const Duration(days: 60)),
        actualizadaEn: hoy.subtract(const Duration(days: 40)),
      ),
      Application(
        id: 'app_playa',
        opportunityId: 'limpieza-playa',
        oportunidadTitulo: 'Jornada de Limpieza de Playa',
        orgId: 'org_ecovida',
        orgNombre: 'EcoVida ONG',
        userId: sofiaId,
        causa: Causa.medioambiente,
        imagenUrl: RemoteAssets.appReforestacionThumb,
        horasEstimadas: 25,
        horasAcreditadas: 25,
        estado: EstadoPostulacion.completado,
        creadaEn: hoy.subtract(const Duration(days: 90)),
        actualizadaEn: hoy.subtract(const Duration(days: 70)),
      ),
    ];
  }

  static List<DonationPoint> donationPoints() => const [
        DonationPoint(
          id: 'don_banco',
          orgId: 'org_red_solidaria',
          nombre: 'Centro de acopio Red Solidaria',
          causa: Causa.comunidades,
          aceptan: ['Víveres', 'Agua embotellada', 'Artículos de higiene'],
          direccion: 'Col. Escalón, San Salvador',
          lat: 13.7034,
          lng: -89.2370,
          horario: 'Lun a Vie · 8:00 a 17:00',
        ),
        DonationPoint(
          id: 'don_refugio',
          orgId: 'org_patitas',
          nombre: 'Refugio Patitas Felices',
          causa: Causa.animales,
          aceptan: ['Concentrado', 'Mantas', 'Medicinas veterinarias'],
          direccion: 'Santa Tecla, La Libertad',
          departamento: 'La Libertad',
          lat: 13.6769,
          lng: -89.2797,
          horario: 'Sáb y Dom · 9:00 a 13:00',
        ),
        DonationPoint(
          id: 'don_ropa',
          orgId: 'org_futuro',
          nombre: 'Ropero Comunitario Futuro Joven',
          causa: Causa.comunidades,
          aceptan: ['Ropa en buen estado', 'Útiles escolares'],
          direccion: 'Antiguo Cuscatlán, La Libertad',
          departamento: 'La Libertad',
          lat: 13.6730,
          lng: -89.2500,
          horario: 'Mar a Sáb · 9:00 a 16:00',
        ),
      ];

  static List<AppNotification> notifications() => [
        AppNotification(
          id: 'not_bienvenida',
          titulo: '¡Bienvenida a NODARA!',
          cuerpo: 'Explora voluntariados y puntos de donación cerca de ti.',
          leida: true,
          creadaEn: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];
}
