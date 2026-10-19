import 'package:flutter/material.dart';

import '../models/application.dart';
import '../models/opportunity.dart';
import '../models/student_profile.dart';

/// Remote assets shipped with the Stitch designs (Google-hosted).
abstract final class MockAssets {
  static const logo =
      'https://lh3.googleusercontent.com/aida/AEtjO1WMNPgKvEeUZYfuunnC_jd5tn4wOuQLmRxJ0gHuMNS2qW4JpuDAepPSdF-Mzf-TAp4WaHPklp9AfC7rA5xKmJ3rZsS-910LLJyrfcy9Ey-O0Ufg9v5r7SLOJv4wC2gMgoD64dt8tBtwGEYq-pJweylS5SJLHQGLdG2w1SMY91wDw4WC0iOZMEAfIg7fDM2ogNw2yo_yn8_shcScXI20cYzniS1QsDEdj6tEgMGGNtkN1JuOnIJl5Nz4JE8';
  static const sofiaAvatar =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAZwnUdUVyY5xV1x4kRnHNEJVPOAHZZl_TWwKeA1bBI-Nlsrua3M9eyHCpKSjzrgKK3Or3ufpTWc5cQb5Nrv5cw6wf5gxQOEti_KZwqMuYWv3GLA0ftBhVAvtKOhtAUtvwFPGbOxZ2TiEB9F-M1N9FdY4AgOWhvlKpGoqWxzGjEBSfOwdawWQ-XQwra_LGIz6O-kNZ03Weo-v9I5s_Rq-RMupv9HgEH9WYoWTLhsASND35ea-4e1JcA3A';

  static const onboardingHero =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDc28gWUpWgGTL9omEze1TRhReKPCaLfKxx9q_vJF0wM6d8SQA6p71hZKH3iyn2X0FGIbMUMfRrzuIxnE_k4dS2T_-UkeOGATDkaOgH_V3rnyabOcXG6raYNVtUxSM8JY2-ne22YAuSwdjzPfCUeXVNS7p3JOx_7SLmuD7vEagvWee7sDTUjhR-m-mTmF8Hsr9qyu7lYkgZU6usNmYmn-lGkckLt1Dj6EOscQ2APIBEurwp4wd0H0QW6Q';

  static const tutoriasImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCucdI0M5bReCybvjRXdBe1aboCcaPuPPnPh-o4kqRzBxA5V6scEIcvSW4QKD4EoSlnFGsO64ywKhuLNk917OBdFl7Dcv71N_rgVmlGqWzpQ2nL5_yVkOjBYkTyMErhwUx3uB3pjE9enLOJEQnDdxT2ZvckSJ5WuVjslEX4HSoQRUKrESlcK3G7Y4fz1a5Fg2fvNYy5OfSuInC5_bHrWbeLj-elnv21oomu7GxEJMPn9YRYKuLqtLvx8g';
  static const reforestacionImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA598CrxlFW3ji3W2XK0wtSgL_tBoKCIxT7Ww2OQMicS3Vzsx9McTyax3PnS38eV4S1nLMTVa8MqkYBRHwdmVe9mCIXPlDRUqz1e_3VdCPAy9-QnMEDbbqeTx8pW0RVT-xRXs8jotPwwPW4hgcfDqHA6Or6B8V0xRNKGFlIYzNWSKcu-OJZK2JGRJ9oGU2ybilgI3QfnguxhMjqCvYie2z5TiLrUXedlHvt1OXV6xJj59PM5GQDt0XwdA';
  static const saludImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBaRoHoiX3LWcwQiYpimpZ6sddiqkB55hFC64Q_8XxQ8Eu7a3doH0GA6bEzI8k89_5SGbtwdAOjREhQ32zzsbu3RMUJ8xariwV4LXlubVp0TwaoCztHkhnLpJys9W4hEVGEWDL4ojwRc-AxSge1eeoU450SHhyI37LyyXp3TRLJMoEbp9Mxg1Lo8x9LuIuBxoxyJcqy1CzkmtHPXlmf4-qzIp_D0-7r7RW7aJ7dRDQg3rp77ChDhAbWtg';

  static const detailHero =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCSeLKNv2dOuK8IQmrA8DKJM9VUfSEn5KVPKHaf2FKS4v5beiRvzFEH0J0E3mXbBrYIz5j9OXdl98g9ODTwKDhHSbC3lO0B9GM-EWZCiM0GYK8raisjExeDIv3zzn7WCR0Xt2Vkp6VizbmS1sVRht4DSChZcwm4G2KLknSHReJjTD4QAtsA3vOt1j1IRVI-eHtoTZBY2-Klay_vtC_HleuDDclpE5EMv_NO9Fg2CDknJIotrI8m6SbrtA';

  static const attendee1 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxY36agvj9q4XNYrkL79WGzhimG5m7ouoG4ycqnlK9IU_GkhCcDofAyTd8hlDp_j0oBDagZJ1RRtdQkdaTvZC85JHU5oh6i-wlgMIwqDx60_u9YjbNOkZbG5uKZuxpc5on6PSt4apux0F4MZOzJ9SE5Tr8QAu6ECkrEQuCtUPQQzFoJ9sbhCEqyBpzib11AVPMm3Pi-JvnXNYvuzdL4iKnkqDyYFmEPflrNe1qfKAScoJH8K2ytmVlxQ';
  static const attendee2 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDHa4pHMB_SKB5kOMVPt9N8ppcWeMqc5oKGV1xUGsNU-HshAHGzqejGnn3ixRdzcCRCB4iof02o7BgZf1SZM6ack4FpuP2TpNv2ePeFgRBFi_3cRjk7876Sp8Mr9du3iwyZMvab_daKwyuytYwEYvUK2MS_msKG4qiEdc4zwC-olNHS8AZr0zdCKAPcPNB1n0humBNgpODapPw6JLDjKIDJpGFk1zJ8SQ3C5LaQIXBKuac5yPJDC6xvhw';
  static const attendee3 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAjM48S7ZnqgrchD2zTTYqE59IFccW27uCeBcpXolkk_Uuis3QEgXlabIzDmsR553ROvXH3HkrmgWt4CN4sI_5nSddsgIN4CHLQ-UyCeDPXfRBAIlLYU-X21UBl78yZ9IZ4j3xAFqK1K57CoHDhuDsgXiod1FYuZH1y0OYsYv5ctHCUYYt1U-5C4a66YmHqOkVmM1M3PyqjIoClibhLtzNn72wV_mRwgc15pj-pqQozvu6806GDoUJY_g';

  static const mapImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDqMpsyLzYnTcv6sw_5-7TzKVptBUAvA6nUv6rTZR2eOlsv6lEtbZAWKkMagbhVcc7OiJJ6_10UsDf4Slqa3a3Rky4dgErRA4yNQIFC2C_oLgBNMc4OKrSfobwC_lC3KnQ__0UArHRDIyJlbIPzINnJ88ZKPfYPQkAYXzc1LZ9zTe7KhTG_42sMYrPilYXHniWusHDvPblLlEwTECVsCq335fs44iIPFvNglnkx0jLSjYAcRz3-Svde7w';

  static const testimonialAvatar =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAODP0A19FjGMKsBCQk7W3YvavOm82tN2yt1g3kA7tEf5wNnkhwbg_9nybrZhgjpQ83puNdg-W0Vz4bJIK6Jp8YB0OoNOqjiqkh8ctO_pL2-jmG323kqeSUV_Qr8Q5gQk32FKqfArTo8ThlkbDm5yCBrWzdAQWzdlhUMXAxCisj5j2KfBqQ13K0kzHR1m9q88qVJvNoWW9J-dkeZzhSn0Xx4rzHr5NBj74ctnp2A6-g_7B_nRQlwO6wmg';

  static const appTutoriasThumb =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBmGknL21XdBRKmDt0wnRsh2i002LegEhW2_rnbORlKOf6CQ0DrrRO-k0uCzVQ-WdpcunB_z_8ddMGpBsu9df7d8tYAsDG41_18EdCHAnZO3vkjzVWfyO5sztQk66FRLj4qlyxjgMQzLsgFvdNcAqhfl0JFyFrVK63qofqlDB7cDsJzFzS86dR2pC7AZQIC8z1NnannBlHxp79IggTHdQZZ0hdmpwVrdu_rMdUntsVKRcxiZKZq1Z3rmg';
  static const appReforestacionThumb =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBCU-gG2QpsZ_xdSStoMdzlcrw6FZMRJ5H4JcKrfaZde88-2TAE5FMFptDlj7gLqzzbTSzemznoxMjV4MABzVVw-YTK-ZD0yN2T4_P7TTHHOtpfh1jAiqPqcOAkbDXXVjgO9Cd_EdZkLsZ38ENn0jDRFuN4Ys8v8zAKMIcwbJWt8cj8Aaq47iAH7V9qxbUf0Ue_QK0icOkya9e5-Yr-j_1cTytShAGbhMRMCctQJatgojsdhvwXu-t6mA';
  static const appBancoThumb =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD56fOv-KQDdpnJUdtHXlYAHREsfrdQO8GQL81kuDKMGqKMQDG1G9kWkvBe8IzU8RdXBBG_DMLCC11o_2Odtw_PkokphNLcIMDOnGLj6C_aAQUNcniQRcDe_emkl-4_FZayaOpF7MytC9mIGa_9nvMuafCRPShcWFKJYsyrijSqDySkILkmY6f3XkzcPOCatqXeJgeVdnvSQBENa8XazDTiqsUhdf-4JKkcDTJK8TKi8wuOWWRpG67b2Q';
}

const _tutorias = Opportunity(
  id: 'tutorias',
  title: 'Tutorías Universitarias de Matemáticas y Apoyo Escolar',
  cardTitle: 'Tutorías de Matemáticas y Ciencias',
  organization: 'Fundación Futuro Joven & Facultad de Ciencias',
  category: OpportunityCategory.education,
  badgeLabel: 'Educación · Escolar',
  location: 'Centro Comunitario San Martín',
  hours: 15,
  imageUrl: MockAssets.detailHero,
  rating: 4.9,
  reviews: 120,
  modality: 'Modalidad Presencial · A 2 cuadras del Campus Central',
  schedule: 'Sábados de 9:00 a 13:00 hrs',
  startInfo: 'Inicio formal: 15 de Abril (4 sábados consecutivos)',
  description:
      'Este programa acompaña a más de 45 adolescentes de barrios vulnerables que cursan los últimos años de secundaria y preparatoria. Como tutor voluntario, facilitarás talleres de refuerzo práctico en álgebra básica, resolución de problemas y razonamiento lógico.',
  requirements: [
    'Estudiantes universitarios activos a partir de 2° año (todas las carreras son bienvenidas).',
    'Disponibilidad presencial los sábados por la mañana durante el período del programa.',
    'Empatía, vocación social y compromiso ético de asistir a un mínimo de 4 sesiones consecutivas.',
    'Participar en el taller virtual de bienvenida e inducción pedagógica (viernes 14 Abril, 18:00 hrs).',
  ],
  benefits: [
    Benefit(
      icon: Icons.badge_outlined,
      title: 'Certificado Oficial Académico',
      subtitle: 'Con validez curricular de 15 horas de servicio social.',
    ),
    Benefit(
      icon: Icons.health_and_safety_outlined,
      title: 'Póliza y Cobertura Integral',
      subtitle: 'Seguro contra accidentes de voluntariado durante las actividades.',
    ),
    Benefit(
      icon: Icons.local_cafe_outlined,
      title: 'Refrigerio y Materiales Incluidos',
      subtitle: 'Kit de enseñanza, cuadernillos y snack energizante en cada sesión.',
    ),
  ],
  spotsTotal: 12,
  spotsLeft: 8,
  attendees: [
    MockAssets.attendee1,
    MockAssets.attendee2,
    MockAssets.attendee3,
  ],
  spotsNote: 'Cupos limitados',
  address: 'Av. San Martín 1420',
  sealId: 'UCR-2024-884',
);

const _reforestacion = Opportunity(
  id: 'reforestacion',
  title: 'Jornada de Reforestación y Limpieza de Cuencas',
  organization: 'EcoVida ONG',
  category: OpportunityCategory.environment,
  badgeLabel: 'Medio Ambiente',
  location: 'Reserva Ribereña',
  hours: 20,
  imageUrl: MockAssets.reforestacionImage,
  rating: 4.7,
  reviews: 86,
  modality: 'Modalidad Presencial · Reserva Ribereña',
  schedule: 'Jornadas de sábado, 8:00 a 14:00 hrs',
  startInfo: 'Próxima jornada: 20 de Abril',
  description:
      'Sumate a la restauración de la ribera plantando especies nativas y limpiando las cuencas del sector. Una jornada en equipo para recuperar el ecosistema local y crear conciencia ambiental.',
  requirements: [
    'Ganas de trabajar al aire libre en equipo.',
    'Ropa cómoda y calzado cerrado para actividad en exteriores.',
    'Asistir a la charla de seguridad previa a la jornada.',
  ],
  benefits: [
    Benefit(
      icon: Icons.eco_outlined,
      title: 'Certificado de Participación',
      subtitle: 'Con validez de 20 horas de servicio social.',
    ),
    Benefit(
      icon: Icons.health_and_safety_outlined,
      title: 'Kit de Seguridad',
      subtitle: 'Guantes, herramientas y seguro de voluntariado.',
    ),
  ],
  spotsTotal: 20,
  spotsLeft: 4,
  attendees: [
    MockAssets.attendee2,
    MockAssets.attendee3,
  ],
  cardFooter: OpportunityCardFooter.spotsLeft,
  spotsNote: '4 cupos restantes',
);

const _salud = Opportunity(
  id: 'salud',
  title: 'Campaña de Salud y Prevención Dental Comunitaria',
  organization: 'Cruz Universitaria',
  category: OpportunityCategory.health,
  badgeLabel: 'Salud Comunitaria',
  location: 'Centro de Salud Sur',
  hours: 12,
  imageUrl: MockAssets.saludImage,
  rating: 4.8,
  reviews: 64,
  modality: 'Modalidad Presencial · Centro de Salud Sur',
  schedule: 'Sábado 9:00 a 15:00 hrs',
  startInfo: 'Inicia este sábado',
  description:
      'Acompañá a las familias del barrio en la campaña de prevención y educación en salud bucal. Colaborás en la recepción, organización de turnos y talleres de higiene para niños.',
  requirements: [
    'Estudiantes de cualquier carrera con vocación de servicio.',
    'Disponibilidad el sábado durante toda la jornada.',
    'Manejo básico de atención al público.',
  ],
  benefits: [
    Benefit(
      icon: Icons.badge_outlined,
      title: 'Certificado de Participación',
      subtitle: 'Con validez de 12 horas de servicio social.',
    ),
    Benefit(
      icon: Icons.local_cafe_outlined,
      title: 'Refrigerio Incluido',
      subtitle: 'Snack y agua durante la jornada.',
    ),
  ],
  spotsTotal: 15,
  spotsLeft: 9,
  attendees: [
    MockAssets.attendee1,
    MockAssets.attendee3,
  ],
  cardFooter: OpportunityCardFooter.startsSoon,
  spotsNote: 'Inicia este sábado',
);

/// Opportunities highlighted in the explore feed (matches the 3 designs).
const kFeaturedOpportunities = [_tutorias, _reforestacion, _salud];

/// Thumbnail used on the "Mis Postulaciones" cards for a given cause.
String applicationThumbnail(String opportunityId) {
  switch (opportunityId) {
    case 'tutorias':
      return MockAssets.appTutoriasThumb;
    case 'reforestacion':
      return MockAssets.appReforestacionThumb;
    case 'banco-alimentos':
      return MockAssets.appBancoThumb;
    case 'salud':
      return MockAssets.saludImage;
    default:
      return MockAssets.onboardingHero;
  }
}

/// The signed-in student.
const kStudentProfile = StudentProfile(
  name: 'Sofía',
  avatarUrl: MockAssets.sofiaAvatar,
  level: 4,
  completedHours: 45,
  requiredHours: 80,
  activeProjects: 3,
  accredited: 2,
  career: 'Servicio Social',
);

/// Seed application used for testing the "Mis Postulaciones" screen.
const kInitialApplications = [
  Application(
    opportunity: _tutorias,
    status: ApplicationStatus.selected,
    hours: 15,
    hoursLabel: '+15 hrs',
    infoTitle: 'Próxima sesión obligatoria',
    infoSubtitle: 'Sábado 15 Abr · 09:00 hrs (Campus Central)',
    infoIcon: Icons.calendar_month,
  ),
];
