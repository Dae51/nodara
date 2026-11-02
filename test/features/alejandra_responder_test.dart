import 'package:flutter_test/flutter_test.dart';
import 'package:nodara/data/datasources/fake/fake_application_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_auth_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_notification_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_opportunity_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/models/app_notification.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/data/repositories/auth_repository.dart';
import 'package:nodara/data/repositories/notification_repository.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';
import 'package:nodara/features/applicants/applicants_provider.dart';
import 'package:nodara/features/notifications/local_notification_service.dart';
import 'package:nodara/features/notifications/notifications_provider.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

class RecordingLocal implements LocalNoticeService {
  final List<AppNotification> shown = [];
  @override
  Future<void> show(AppNotification notification) async {
    shown.add(notification);
  }

  @override
  Future<void> clear() async {}
}

class FailingNotifications extends FakeNotificationDataSource {
  bool fail = true;
  @override
  Future<void> create(String userId, AppNotification notification) async {
    if (fail) throw StateError('Sin conexión');
    await super.create(userId, notification);
  }
}

void main() {
  late ApplicantsProvider provider;
  late ApplicationRepository applications;
  late OpportunityRepository opportunities;
  late NotificationRepository notifications;
  late FailingNotifications notificationSource;
  late Application pending;
  setUp(() async {
    final opportunity = FakeSeed.opportunities().first;
    pending = FakeSeed.applications().first.copyWith(
      estado: EstadoPostulacion.pendiente,
    );
    applications = ApplicationRepository(FakeApplicationDataSource([pending]));
    opportunities = OpportunityRepository(
      FakeOpportunityDataSource([opportunity]),
    );
    notificationSource = FailingNotifications()..fail = false;
    notifications = NotificationRepository(notificationSource);
    provider = ApplicantsProvider(
      opportunityId: opportunity.id,
      applications: applications,
      opportunities: opportunities,
      notifications: notifications,
      auth: AuthRepository(FakeAuthDataSource(initialUser: FakeSeed.orgFuturo)),
    );
    await flush();
  });
  tearDown(() => provider.dispose());

  test(
    'Aceptar crea aviso, ocupa exactamente un cupo y evita doble aceptación',
    () async {
      final before = provider.opportunity?.cuposOcupados;
      expect(await provider.responder(pending, aceptar: true), isTrue);
      await flush();
      expect(provider.items.single.estado, EstadoPostulacion.aceptado);
      expect(provider.opportunity?.cuposOcupados, (before ?? 0) + 1);
      final notices = await notifications.watchMine(pending.userId).first;
      expect(
        notices.where((notice) => notice.applicationId == pending.id).length,
        1,
      );
      expect(await provider.responder(pending, aceptar: true), isFalse);
      expect(provider.opportunity?.cuposOcupados, (before ?? 0) + 1);
    },
  );

  test('Rechazar exige motivo y no ocupa cupos', () async {
    final before = provider.opportunity?.cuposOcupados;
    expect(
      await provider.responder(pending, aceptar: false, motivo: '  '),
      isFalse,
    );
    expect(
      await provider.responder(
        pending,
        aceptar: false,
        motivo: 'Horario incompatible',
      ),
      isTrue,
    );
    await flush();
    expect(provider.items.single.estado, EstadoPostulacion.rechazado);
    expect(provider.opportunity?.cuposOcupados, before);
    final notices = await notifications.watchMine(pending.userId).first;
    expect(notices.first.cuerpo, contains('Horario incompatible'));
  });

  test(
    'Reenviar aviso tras fallo no vuelve a ocupar cupo ni cambiar estado',
    () async {
      notificationSource.fail = true;
      final before = provider.opportunity?.cuposOcupados;
      expect(await provider.responder(pending, aceptar: true), isFalse);
      await flush();
      expect(provider.items.single.estado, EstadoPostulacion.aceptado);
      expect(provider.hasPendingNotice(pending.id), isTrue);
      notificationSource.fail = false;
      await provider.retryNotice(provider.items.single);
      await flush();
      expect(provider.hasPendingNotice(pending.id), isFalse);
      expect(provider.opportunity?.cuposOcupados, (before ?? 0) + 1);
    },
  );

  test('Sin cupos no acepta ni crea aviso', () async {
    final opportunity = provider.opportunity;
    if (opportunity == null) fail('Falta convocatoria del Fake');
    await opportunities.actualizar(
      opportunity.copyWith(cuposOcupados: opportunity.cuposTotal),
    );
    await flush();
    expect(await provider.responder(pending, aceptar: true), isFalse);
    expect(provider.items.single.estado, EstadoPostulacion.pendiente);
  });

  test('Avisos: historial silencioso, nuevos una vez, leído actualiza contador y salir limpia', () async {
    final auth = AuthRepository(FakeAuthDataSource());
    final local = RecordingLocal();
    final avisos = NotificationsProvider(
      notifications,
      auth,
      localNotifications: local,
    );
    addTearDown(avisos.dispose);
    await flush();
    expect(local.shown, isEmpty);
    final before = avisos.unreadCount;
    await notifications.enviar(
      FakeSeed.sofiaId,
      AppNotification(
        id: '',
        titulo: 'Nuevo',
        cuerpo: 'Aceptada',
        creadaEn: DateTime.now(),
      ),
    );
    await flush();
    expect(local.shown.length, 1);
    expect(avisos.unreadCount, before + 1);
    await avisos.markAsRead(avisos.items.first);
    await flush();
    expect(avisos.unreadCount, before);
    expect(local.shown.length, 1);
    await auth.signOut();
    await flush();
    expect(avisos.items, isEmpty);
    expect(avisos.unreadCount, 0);
  });
}
