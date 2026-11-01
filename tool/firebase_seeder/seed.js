/*
 * Seeder administrativo e idempotente para NODARA.
 *
 * Requiere credenciales de una cuenta de servicio o Application Default
 * Credentials. Nunca agregues el JSON de la cuenta de servicio al repositorio.
 */
const admin = require('firebase-admin');

const projectId = process.env.FIREBASE_PROJECT_ID || 'nodara-community';
const password = process.env.NODARA_SEED_PASSWORD;

if (!password || password.length < 6) {
  throw new Error(
    'Define NODARA_SEED_PASSWORD (mínimo 6 caracteres) antes de ejecutar el seeder.',
  );
}

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId,
});

const db = admin.firestore();
const now = new Date();
const daysFromNow = (days) => new Date(now.getTime() + days * 86400000);
const daysAgo = (days) => daysFromNow(-days);

const organizations = [
  ['seed-org-01', 'Fundación Futuro Joven', 'futuro.joven@nodara.demo'],
  ['seed-org-02', 'EcoVida El Salvador', 'ecovida@nodara.demo'],
  ['seed-org-03', 'Red Solidaria', 'red.solidaria@nodara.demo'],
];

const volunteers = [
  ['seed-vol-01', 'Sofía Martínez', 'sofia@nodara.demo', 'estudiante', 80],
  ['seed-vol-02', 'Diego Hernández', 'diego@nodara.demo', 'estudiante', 60],
  ['seed-vol-03', 'Valeria López', 'valeria@nodara.demo', 'graduado', 0],
  ['seed-vol-04', 'Mateo Ramírez', 'mateo@nodara.demo', 'trabajador', 0],
  ['seed-vol-05', 'Ana García', 'ana@nodara.demo', 'estudiante', 100],
  ['seed-vol-06', 'Carlos Rivera', 'carlos@nodara.demo', 'estudiante', 40],
  ['seed-vol-07', 'Lucía Flores', 'lucia@nodara.demo', 'graduado', 0],
];

const causes = [
  'educacion',
  'medioambiente',
  'comunidades',
  'animales',
  'salud',
  'cultura',
  'emergencias',
  'educacion',
  'medioambiente',
  'comunidades',
];

const opportunityTitles = [
  'Tutorías de Matemáticas y Ciencias',
  'Reforestación en El Boquerón',
  'Banco de Alimentos Comunitario',
  'Jornada de Bienestar Animal',
  'Acompañamiento a Adultos Mayores',
  'Festival de Arte Comunitario',
  'Brigada de Respuesta ante Emergencias',
  'Club de Lectura para Niñez',
  'Limpieza de Playa El Tunco',
  'Huerto Urbano Comunitario',
];

const departments = [
  'San Salvador',
  'La Libertad',
  'Santa Ana',
  'San Salvador',
  'San Miguel',
  'Sonsonate',
  'La Libertad',
  'Santa Ana',
  'La Libertad',
  'San Salvador',
];

function userDocument([uid, nombre, email, tipo, horasRequeridas]) {
  return {
    nombre,
    email,
    tipo,
    rol: 'voluntario',
    intereses: ['educacion', 'comunidades', 'medioambiente'],
    favoritos: [],
    horasRequeridas,
    carrera: tipo === 'estudiante' ? 'Ingeniería y Negocios' : null,
    avatarUrl: '',
    creadoEn: daysAgo(90),
  };
}

function organizationDocument([uid, nombre, email]) {
  return {
    nombre,
    email,
    tipo: 'trabajador',
    rol: 'organizacion',
    intereses: [],
    favoritos: [],
    horasRequeridas: 0,
    avatarUrl: '',
    creadoEn: daysAgo(120),
  };
}

function opportunity(index) {
  const [orgId, orgNombre] = organizations[index % organizations.length];
  const causa = causes[index];
  const horas = 8 + (index % 4) * 4;
  const fechaInicio = daysFromNow(7 + index * 3);
  return {
    orgId,
    orgNombre,
    titulo: opportunityTitles[index],
    tituloCorto: opportunityTitles[index],
    descripcion: `Únete a ${opportunityTitles[index].toLowerCase()} y genera impacto local junto a NODARA.`,
    causa,
    formato: index % 3 === 0 ? 'programa' : index % 3 === 1 ? 'jornada' : 'permanente',
    modalidad: index === 3 || index === 7 ? 'virtual' : 'presencial',
    etiqueta: `${causa[0].toUpperCase()}${causa.slice(1)} · Voluntariado`,
    departamento: departments[index],
    lat: 13.69 + index * 0.006,
    lng: -89.24 - index * 0.004,
    ubicacion: `Centro comunitario ${departments[index]}`,
    direccion: `Zona ${index + 1}, ${departments[index]}, El Salvador`,
    referencia: 'A dos cuadras del punto de transporte público',
    horario: index % 2 === 0 ? 'Sábados · 8:00 a 12:00' : 'Domingos · 9:00 a 13:00',
    compromiso: index % 3 === 0 ? '4 jornadas consecutivas' : 'Una jornada',
    fechaInicio,
    fechaFin: daysFromNow(14 + index * 3),
    cierreInscripcion: daysFromNow(3 + index),
    acreditaHoras: true,
    horasEstimadas: horas,
    cuposTotal: 15 + index,
    cuposOcupados: 0,
    requisitos: ['Tener 18 años o más', 'Compromiso y puntualidad'],
    beneficios: [
      { iconKey: 'verified', titulo: 'Horas acreditables', subtitulo: `${horas} horas estimadas` },
      { iconKey: 'groups', titulo: 'Impacto colectivo', subtitulo: 'Conoce a otros voluntarios' },
    ],
    imagenUrl: '',
    avataresInscritos: [],
    calificacion: 4.5 + (index % 5) / 10,
    resenas: 10 + index * 3,
    verificada: true,
    activa: true,
    creadoEn: daysAgo(15 - index),
  };
}

const applicationStates = [
  'pendiente',
  'enRevision',
  'entrevista',
  'listaEspera',
  'aceptado',
  'confirmado',
  'enCurso',
  'completado',
  'rechazado',
  'noShow',
];

function historyFor(state, userId, orgId) {
  const path = {
    pendiente: ['pendiente'],
    enRevision: ['pendiente', 'enRevision'],
    entrevista: ['pendiente', 'enRevision', 'entrevista'],
    listaEspera: ['pendiente', 'enRevision', 'listaEspera'],
    aceptado: ['pendiente', 'enRevision', 'aceptado'],
    confirmado: ['pendiente', 'enRevision', 'aceptado', 'confirmado'],
    enCurso: ['pendiente', 'enRevision', 'aceptado', 'confirmado', 'enCurso'],
    completado: ['pendiente', 'enRevision', 'aceptado', 'confirmado', 'enCurso', 'completado'],
    rechazado: ['pendiente', 'enRevision', 'rechazado'],
    noShow: ['pendiente', 'enRevision', 'aceptado', 'confirmado', 'enCurso', 'noShow'],
  }[state];
  return path.map((estado, index) => ({
    estado,
    en: daysAgo(path.length - index + 1),
    actorId: index === 0 ? userId : orgId,
    motivo: estado === 'rechazado' ? 'El perfil no coincide con los cupos disponibles.' : null,
  }));
}

function application(index, opportunities) {
  const opportunityId = `seed-opp-${String(index + 1).padStart(2, '0')}`;
  const opportunityData = opportunities[index];
  const [userId] = volunteers[index % volunteers.length];
  const state = applicationStates[index];
  const isCompleted = state === 'completado';
  const reason = state === 'rechazado'
    ? 'El perfil no coincide con los cupos disponibles.'
    : state === 'noShow'
      ? 'No registró asistencia en la jornada.'
      : null;
  return {
    opportunityId,
    oportunidadTitulo: opportunityData.tituloCorto,
    orgId: opportunityData.orgId,
    orgNombre: opportunityData.orgNombre,
    userId,
    causa: opportunityData.causa,
    imagenUrl: '',
    horario: opportunityData.horario,
    horasEstimadas: opportunityData.horasEstimadas,
    horasAcreditadas: isCompleted ? opportunityData.horasEstimadas : null,
    estado: state,
    motivo: reason,
    creadaEn: daysAgo(14 - index),
    actualizadaEn: daysAgo(1),
    historial: historyFor(state, userId, opportunityData.orgId),
  };
}

function donationPoint(index) {
  const [orgId] = organizations[index % organizations.length];
  const causa = causes[index];
  return {
    orgId,
    nombre: `Punto solidario ${index + 1}`,
    causa,
    aceptan: causa === 'animales'
      ? ['Alimento para mascotas', 'Toallas', 'Medicinas veterinarias']
      : ['Víveres', 'Ropa en buen estado', 'Artículos de higiene'],
    direccion: `Colonia ${index + 1}, ${departments[index]}, El Salvador`,
    departamento: departments[index],
    lat: 13.69 + index * 0.008,
    lng: -89.24 - index * 0.006,
    horario: 'Lunes a sábado · 8:00 a 16:00',
    activa: true,
  };
}

async function ensureAuthUser({ uid, email, displayName, role }) {
  const payload = { email, password, displayName, emailVerified: true, disabled: false };
  try {
    await admin.auth().getUser(uid);
    await admin.auth().updateUser(uid, payload);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
    await admin.auth().createUser({ uid, ...payload });
  }
  await admin.auth().setCustomUserClaims(uid, { role });
}

async function verifySeed() {
  const collections = [
    ['users', [...organizations.map(([uid]) => `users/${uid}`), ...volunteers.map(([uid]) => `users/${uid}`)]],
    ['opportunities', Array.from({ length: 10 }, (_, index) => `opportunities/seed-opp-${String(index + 1).padStart(2, '0')}`)],
    ['applications', Array.from({ length: 10 }, (_, index) => `applications/seed-app-${String(index + 1).padStart(2, '0')}`)],
    ['donationPoints', Array.from({ length: 10 }, (_, index) => `donationPoints/seed-donation-${String(index + 1).padStart(2, '0')}`)],
    ['certificates', Array.from({ length: 10 }, (_, index) => `certificates/NOD-SEED-${String(index + 1).padStart(2, '0')}`)],
  ];
  for (const [name, paths] of collections) {
    const documents = await db.getAll(...paths.map((path) => db.doc(path)));
    if (documents.filter((document) => document.exists).length < 10) {
      throw new Error(`La verificación falló: ${name} tiene menos de 10 registros seed.`);
    }
  }
  const notificationDocuments = await db.getAll(...Array.from(
    { length: 10 },
    (_, index) => db.doc(`users/${volunteers[index % volunteers.length][0]}/notifications/seed-notification-${String(index + 1).padStart(2, '0')}`),
  ));
  if (notificationDocuments.filter((document) => document.exists).length < 10) {
    throw new Error('La verificación falló: hay menos de 10 notificaciones seed.');
  }
}

async function main() {
  const users = [
    ...organizations.map(([uid, nombre, email]) => ({ uid, email, displayName: nombre, role: 'organizacion' })),
    ...volunteers.map(([uid, nombre, email]) => ({ uid, email, displayName: nombre, role: 'voluntario' })),
  ];
  await Promise.all(users.map(ensureAuthUser));

  const opportunities = Array.from({ length: 10 }, (_, index) => opportunity(index));
  const applications = opportunities.map((item, index) => application(index, opportunities));
  const acceptedStates = new Set(['aceptado', 'confirmado', 'enCurso', 'completado']);
  applications.forEach((item, index) => {
    if (acceptedStates.has(item.estado)) opportunities[index].cuposOcupados = 1;
  });

  const batch = db.batch();
  organizations.forEach((org) => batch.set(db.doc(`users/${org[0]}`), organizationDocument(org), { merge: true }));
  volunteers.forEach((volunteer) => batch.set(db.doc(`users/${volunteer[0]}`), userDocument(volunteer), { merge: true }));
  opportunities.forEach((item, index) => batch.set(
    db.doc(`opportunities/seed-opp-${String(index + 1).padStart(2, '0')}`), item, { merge: true },
  ));
  applications.forEach((item, index) => batch.set(
    db.doc(`applications/seed-app-${String(index + 1).padStart(2, '0')}`), item, { merge: true },
  ));
  Array.from({ length: 10 }, (_, index) => donationPoint(index)).forEach((item, index) => batch.set(
    db.doc(`donationPoints/seed-donation-${String(index + 1).padStart(2, '0')}`), item, { merge: true },
  ));
  Array.from({ length: 10 }, (_, index) => {
    const volunteer = volunteers[index % volunteers.length];
    const applicationId = `seed-app-${String((index % 10) + 1).padStart(2, '0')}`;
    return {
      userId: volunteer[0],
      nombre: volunteer[1],
      applicationIds: [applicationId],
      totalHoras: 8 + (index % 4) * 4,
      emitidoEn: daysAgo(index + 1),
    };
  }).forEach((item, index) => batch.set(
    db.doc(`certificates/NOD-SEED-${String(index + 1).padStart(2, '0')}`), item, { merge: true },
  ));
  Array.from({ length: 10 }, (_, index) => {
    const volunteer = volunteers[index % volunteers.length];
    const applicationId = `seed-app-${String(index + 1).padStart(2, '0')}`;
    return { volunteer, applicationId, index };
  }).forEach(({ volunteer, applicationId, index }) => batch.set(
    db.doc(`users/${volunteer[0]}/notifications/seed-notification-${String(index + 1).padStart(2, '0')}`),
    {
      titulo: 'Actualización de solicitud',
      cuerpo: `Tu solicitud ${index + 1} tiene información nueva.`,
      applicationId,
      leida: index % 3 === 0,
      creadaEn: daysAgo(index),
    },
    { merge: true },
  ));

  await batch.commit();
  await verifySeed();
  console.log(`Seeder completado en ${projectId}.`);
  console.table({
    usuariosAuthYFirestore: users.length,
    oportunidades: opportunities.length,
    solicitudes: applications.length,
    puntosDeDonacion: 10,
    certificados: 10,
    notificaciones: 10,
  });
}

main().catch((error) => {
  console.error('No se pudo cargar el seed:', error);
  process.exitCode = 1;
});
