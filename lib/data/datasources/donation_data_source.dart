import 'package:nodara/data/models/donation_point.dart';

/// Contrato de acceso a `donationPoints`.
abstract class DonationDataSource {
  Stream<List<DonationPoint>> watchActive();
}
