import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/datasources/fake/in_memory_collection.dart';
import 'package:nodara/data/datasources/opportunity_data_source.dart';
import 'package:nodara/data/models/opportunity.dart';

class FakeOpportunityDataSource implements OpportunityDataSource {
  FakeOpportunityDataSource([List<Opportunity>? seed])
      : _collection =
            InMemoryCollection<Opportunity>(seed ?? FakeSeed.opportunities());

  final InMemoryCollection<Opportunity> _collection;

  @override
  Stream<List<Opportunity>> watchActive() =>
      _collection.watchWhere((o) => o.activa);

  @override
  Stream<List<Opportunity>> watchByOrg(String orgId) =>
      _collection.watchWhere((o) => o.orgId == orgId);

  @override
  Future<String> create(Opportunity opportunity) async {
    final id = fakeId('opp');
    _collection.add(opportunity.copyWith(id: id));
    return id;
  }

  @override
  Future<void> incrementCuposOcupados(String opportunityId, int delta) async {
    _collection.replaceFirst(
      (o) => o.id == opportunityId,
      (o) => o.copyWith(cuposOcupados: o.cuposOcupados + delta),
    );
  }

  @override
  Future<void> update(Opportunity opportunity) async {
    _collection.replaceFirst((o) => o.id == opportunity.id, (_) => opportunity);
  }
}
