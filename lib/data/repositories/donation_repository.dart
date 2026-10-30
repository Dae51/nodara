import 'package:nodara/data/datasources/donation_data_source.dart';
import 'package:nodara/data/models/donation_point.dart';

class DonationRepository {
  DonationRepository(this._dataSource);

  final DonationDataSource _dataSource;

  Stream<List<DonationPoint>> watchActivos() => _dataSource.watchActive();
}
