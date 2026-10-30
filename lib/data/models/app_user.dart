import 'model_utils.dart';
import 'opportunity.dart';

enum TipoUsuario {
  estudiante('Estudiante'),
  graduado('Recién graduado'),
  trabajador('Trabajo actualmente');

  const TipoUsuario(this.label);

  final String label;
}

enum RolUsuario { voluntario, organizacion }

/// Usuario autenticado (voluntario u organización).
class AppUser {
  const AppUser({
    required this.uid,
    required this.nombre,
    required this.email,
    this.tipo = TipoUsuario.estudiante,
    this.rol = RolUsuario.voluntario,
    this.intereses = const [],
    this.favoritos = const [],
    this.horasRequeridas = 0,
    this.carrera,
    this.avatarUrl = '',
    required this.creadoEn,
  });

  factory AppUser.fromMap(String uid, Map<String, Object?> map) => AppUser(
        uid: uid,
        nombre: readString(map['nombre']),
        email: readString(map['email']),
        tipo: readEnum(TipoUsuario.values, map['tipo'], TipoUsuario.estudiante),
        rol: readEnum(RolUsuario.values, map['rol'], RolUsuario.voluntario),
        intereses: readStringList(map['intereses'])
            .map((name) => readEnum(Causa.values, name, Causa.comunidades))
            .toList(),
        favoritos: readStringList(map['favoritos']),
        horasRequeridas: readInt(map['horasRequeridas']),
        carrera: map['carrera'] is String ? map['carrera'] as String : null,
        avatarUrl: readString(map['avatarUrl']),
        creadoEn: readDate(map['creadoEn']) ?? DateTime.now(),
      );

  final String uid;
  final String nombre;
  final String email;
  final TipoUsuario tipo;
  final RolUsuario rol;
  final List<Causa> intereses;

  /// IDs de oportunidades guardadas.
  final List<String> favoritos;

  /// Horas sociales que exige su universidad (0 = no aplica).
  final int horasRequeridas;
  final String? carrera;
  final String avatarUrl;
  final DateTime creadoEn;

  bool get esOrganizacion => rol == RolUsuario.organizacion;

  /// Solo los estudiantes con meta de horas ven el progreso.
  bool get tieneMetaDeHoras => horasRequeridas > 0;

  Map<String, Object?> toMap() => {
        'nombre': nombre,
        'email': email,
        'tipo': tipo.name,
        'rol': rol.name,
        'intereses': intereses.map((c) => c.name).toList(),
        'favoritos': favoritos,
        'horasRequeridas': horasRequeridas,
        'carrera': carrera,
        'avatarUrl': avatarUrl,
        'creadoEn': creadoEn,
      };

  AppUser copyWith({
    String? nombre,
    TipoUsuario? tipo,
    List<Causa>? intereses,
    List<String>? favoritos,
    int? horasRequeridas,
    String? carrera,
    String? avatarUrl,
  }) =>
      AppUser(
        uid: uid,
        nombre: nombre ?? this.nombre,
        email: email,
        tipo: tipo ?? this.tipo,
        rol: rol,
        intereses: intereses ?? this.intereses,
        favoritos: favoritos ?? this.favoritos,
        horasRequeridas: horasRequeridas ?? this.horasRequeridas,
        carrera: carrera ?? this.carrera,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        creadoEn: creadoEn,
      );
}
