import 'package:nodara/data/datasources/donation_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/datasources/fake/in_memory_collection.dart';
import 'package:nodara/data/models/donation_point.dart';

class FakeDonationDataSource implements DonationDataSource {
  FakeDonationDataSource([List<DonationPoint>? seed])
      : _collection =
            InMemoryCollection<DonationPoint>(seed ?? FakeSeed.donationPoints());

  final InMemoryCollection<DonationPoint> _collection;

  @override
  Stream<List<DonationPoint>> watchActive() =>
      _collection.watchWhere((d) => d.activa);
}
