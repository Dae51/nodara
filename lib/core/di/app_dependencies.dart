import 'package:nodara/data/datasources/fake/fake_application_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_auth_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_certificate_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_donation_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_notification_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_opportunity_data_source.dart';
import 'package:nodara/data/datasources/firebase/firebase_auth_data_source.dart';
import 'package:nodara/data/preferences/app_preferences.dart';
import 'package:nodara/data/repositories/application_repository.dart';
import 'package:nodara/data/repositories/auth_repository.dart';
import 'package:nodara/data/repositories/certificate_repository.dart';
import 'package:nodara/data/repositories/donation_repository.dart';
import 'package:nodara/data/repositories/notification_repository.dart';
import 'package:nodara/data/repositories/opportunity_repository.dart';

/// Arma los repositorios inyectando la fuente de datos por constructor
/// (principio D de SOLID). Cambiar de Fake a Firebase solo toca este archivo.
class AppDependencies {
  AppDependencies({
    required this.auth,
    required this.opportunities,
    required this.applications,
    required this.donations,
    required this.notifications,
    required this.certificates,
    required this.preferences,
  });

  /// Todo en memoria: para desarrollar sin internet y para los tests.
  factory AppDependencies.fake({
    bool startSignedIn = true,
    bool onboardingVisto = false,
  }) =>
      AppDependencies(
        auth: AuthRepository(
          FakeAuthDataSource(startSignedIn: startSignedIn),
        ),
        opportunities: OpportunityRepository(FakeOpportunityDataSource()),
        applications: ApplicationRepository(FakeApplicationDataSource()),
        donations: DonationRepository(FakeDonationDataSource()),
        notifications: NotificationRepository(FakeNotificationDataSource()),
        certificates: CertificateRepository(FakeCertificateDataSource()),
        preferences: InMemoryAppPreferences(visto: onboardingVisto),
      );

  /// Firebase real. Cada integrante cambia su Fake por la versión Firebase
  /// cuando la termine (F2: oportunidades y donaciones, F3: postulaciones,
  /// F4: notificaciones, F5: certificados).
  factory AppDependencies.firebase() => AppDependencies(
        auth: AuthRepository(FirebaseAuthDataSource()),
        opportunities: OpportunityRepository(FakeOpportunityDataSource()),
        applications: ApplicationRepository(FakeApplicationDataSource()),
        donations: DonationRepository(FakeDonationDataSource()),
        notifications: NotificationRepository(FakeNotificationDataSource()),
        certificates: CertificateRepository(FakeCertificateDataSource()),
        preferences: SharedAppPreferences(),
      );

  final AuthRepository auth;
  final OpportunityRepository opportunities;
  final ApplicationRepository applications;
  final DonationRepository donations;
  final NotificationRepository notifications;
  final CertificateRepository certificates;
  final AppPreferences preferences;
}
