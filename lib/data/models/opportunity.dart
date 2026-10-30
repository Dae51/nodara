import 'model_utils.dart';

/// Causa a la que ayuda la oportunidad (chips del feed).
enum Causa {
  medioambiente('Medio Ambiente'),
  animales('Animales'),
  comunidades('Comunidades'),
  educacion('Educación'),
  salud('Salud'),
  cultura('Cultura'),
  emergencias('Emergencias');

  const Causa(this.label);

  final String label;
}

/// Cómo participa la persona.
enum Formato {
  jornada('Jornada'),
  programa('Programa'),
  permanente('Permanente');

  const Formato(this.label);

  final String label;
}

enum Modalidad {
  presencial('Presencial'),
  virtual('Virtual');

  const Modalidad(this.label);

  final String label;
}

/// Beneficio que recibe el voluntario ("Qué te otorgamos").
///
/// Guarda un [iconKey] (texto) en lugar de `IconData` para poder
/// serializarse; la UI lo convierte con `iconFromKey`.
class Benefit {
  const Benefit({
    required this.iconKey,
    required this.titulo,
    required this.subtitulo,
  });

  factory Benefit.fromMap(Map<String, Object?> map) => Benefit(
        iconKey: readString(map['iconKey'], 'star'),
        titulo: readString(map['titulo']),
        subtitulo: readString(map['subtitulo']),
      );

  final String iconKey;
  final String titulo;
  final String subtitulo;

  Map<String, Object?> toMap() => {
        'iconKey': iconKey,
        'titulo': titulo,
        'subtitulo': subtitulo,
      };
}

/// Convocatoria publicada por una organización.
class Opportunity {
  const Opportunity({
    required this.id,
    required this.orgId,
    required this.orgNombre,
    required this.titulo,
    this.tituloCorto,
    required this.descripcion,
    required this.causa,
    required this.formato,
    this.modalidad = Modalidad.presencial,
    required this.etiqueta,
    this.departamento = 'San Salvador',
    required this.ubicacion,
    this.direccion = '',
    this.referencia = '',
    required this.horario,
    required this.compromiso,
    this.fechaInicio,
    this.fechaFin,
    required this.cierreInscripcion,
    this.acreditaHoras = true,
    required this.horasEstimadas,
    required this.cuposTotal,
    this.cuposOcupados = 0,
    this.requisitos = const [],
    this.beneficios = const [],
    this.imagenUrl = '',
    this.avataresInscritos = const [],
    this.calificacion,
    this.resenas = 0,
    this.verificada = true,
    this.activa = true,
  });

  factory Opportunity.fromMap(String id, Map<String, Object?> map) =>
      Opportunity(
        id: id,
        orgId: readString(map['orgId']),
        orgNombre: readString(map['orgNombre']),
        titulo: readString(map['titulo']),
        tituloCorto: map['tituloCorto'] is String
            ? map['tituloCorto'] as String
            : null,
        descripcion: readString(map['descripcion']),
        causa: readEnum(Causa.values, map['causa'], Causa.comunidades),
        formato: readEnum(Formato.values, map['formato'], Formato.jornada),
        modalidad:
            readEnum(Modalidad.values, map['modalidad'], Modalidad.presencial),
        etiqueta: readString(map['etiqueta']),
        departamento: readString(map['departamento'], 'San Salvador'),
        ubicacion: readString(map['ubicacion']),
        direccion: readString(map['direccion']),
        referencia: readString(map['referencia']),
        horario: readString(map['horario']),
        compromiso: readString(map['compromiso']),
        fechaInicio: readDate(map['fechaInicio']),
        fechaFin: readDate(map['fechaFin']),
        cierreInscripcion: readDate(map['cierreInscripcion']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        acreditaHoras: readBool(map['acreditaHoras'], true),
        horasEstimadas: readInt(map['horasEstimadas']),
        cuposTotal: readInt(map['cuposTotal']),
        cuposOcupados: readInt(map['cuposOcupados']),
        requisitos: readStringList(map['requisitos']),
        beneficios:
            readMapList(map['beneficios']).map(Benefit.fromMap).toList(),
        imagenUrl: readString(map['imagenUrl']),
        avataresInscritos: readStringList(map['avataresInscritos']),
        calificacion: readDouble(map['calificacion']),
        resenas: readInt(map['resenas']),
        verificada: readBool(map['verificada'], true),
        activa: readBool(map['activa'], true),
      );

  final String id;
  final String orgId;
  final String orgNombre;
  final String titulo;

  /// Título más corto para la tarjeta del feed.
  final String? tituloCorto;
  final String descripcion;
  final Causa causa;
  final Formato formato;
  final Modalidad modalidad;

  /// Texto de la insignia, ej. "Educación · Programa".
  final String etiqueta;
  final String departamento;
  final String ubicacion;
  final String direccion;

  /// Referencia del lugar, ej. "A 2 cuadras del Campus Central".
  final String referencia;

  /// Días y horas, ej. "Sábados de 9:00 a 13:00 hrs".
  final String horario;

  /// Compromiso esperado, ej. "4 sábados consecutivos".
  final String compromiso;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  /// Fecha límite para postularse: define si la convocatoria está vigente.
  final DateTime cierreInscripcion;
  final bool acreditaHoras;
  final int horasEstimadas;
  final int cuposTotal;
  final int cuposOcupados;
  final List<String> requisitos;
  final List<Benefit> beneficios;
  final String imagenUrl;
  final List<String> avataresInscritos;
  final double? calificacion;
  final int resenas;
  final bool verificada;
  final bool activa;

  // ---- Valores derivados (getters, no se guardan) ----

  String get tituloTarjeta => tituloCorto ?? titulo;

  int get cuposLibres {
    final libres = cuposTotal - cuposOcupados;
    return libres < 0 ? 0 : libres;
  }

  bool get hayCupos => cuposLibres > 0;

  /// Proporción de cupos ocupados (0..1).
  double get ocupacion => cuposTotal == 0 ? 0 : cuposOcupados / cuposTotal;

  /// Vigente = activa y todavía dentro del plazo de inscripción.
  bool estaVigente([DateTime? ahora]) =>
      activa && (ahora ?? DateTime.now()).isBefore(cierreInscripcion);

  Map<String, Object?> toMap() => {
        'orgId': orgId,
        'orgNombre': orgNombre,
        'titulo': titulo,
        'tituloCorto': tituloCorto,
        'descripcion': descripcion,
        'causa': causa.name,
        'formato': formato.name,
        'modalidad': modalidad.name,
        'etiqueta': etiqueta,
        'departamento': departamento,
        'ubicacion': ubicacion,
        'direccion': direccion,
        'referencia': referencia,
        'horario': horario,
        'compromiso': compromiso,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'cierreInscripcion': cierreInscripcion,
        'acreditaHoras': acreditaHoras,
        'horasEstimadas': horasEstimadas,
        'cuposTotal': cuposTotal,
        'cuposOcupados': cuposOcupados,
        'requisitos': requisitos,
        'beneficios': beneficios.map((b) => b.toMap()).toList(),
        'imagenUrl': imagenUrl,
        'avataresInscritos': avataresInscritos,
        'calificacion': calificacion,
        'resenas': resenas,
        'verificada': verificada,
        'activa': activa,
      };

  Opportunity copyWith({
    String? id,
    int? cuposOcupados,
    bool? activa,
  }) =>
      Opportunity(
        id: id ?? this.id,
        orgId: orgId,
        orgNombre: orgNombre,
        titulo: titulo,
        tituloCorto: tituloCorto,
        descripcion: descripcion,
        causa: causa,
        formato: formato,
        modalidad: modalidad,
        etiqueta: etiqueta,
        departamento: departamento,
        ubicacion: ubicacion,
        direccion: direccion,
        referencia: referencia,
        horario: horario,
        compromiso: compromiso,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        cierreInscripcion: cierreInscripcion,
        acreditaHoras: acreditaHoras,
        horasEstimadas: horasEstimadas,
        cuposTotal: cuposTotal,
        cuposOcupados: cuposOcupados ?? this.cuposOcupados,
        requisitos: requisitos,
        beneficios: beneficios,
        imagenUrl: imagenUrl,
        avataresInscritos: avataresInscritos,
        calificacion: calificacion,
        resenas: resenas,
        verificada: verificada,
        activa: activa ?? this.activa,
      );
}
