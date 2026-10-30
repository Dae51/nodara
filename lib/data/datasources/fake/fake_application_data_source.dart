import 'package:nodara/data/datasources/application_data_source.dart';
import 'package:nodara/data/datasources/fake/fake_seed.dart';
import 'package:nodara/data/datasources/fake/in_memory_collection.dart';
import 'package:nodara/data/models/application.dart';

class FakeApplicationDataSource implements ApplicationDataSource {
  FakeApplicationDataSource([List<Application>? seed])
      : _collection =
            InMemoryCollection<Application>(seed ?? FakeSeed.applications());

  final InMemoryCollection<Application> _collection;

  @override
  Stream<List<Application>> watchByUser(String userId) =>
      _collection.watchWhere((a) => a.userId == userId);

  @override
  Stream<List<Application>> watchByOrg(String orgId) =>
      _collection.watchWhere((a) => a.orgId == orgId);

  @override
  Future<String> create(Application application) async {
    final id = fakeId('app');
    _collection.add(application.copyWith(id: id));
    return id;
  }

  @override
  Future<void> updateEstado({
    required String applicationId,
    required EstadoPostulacion estado,
    int? horasAcreditadas,
    String? motivo,
  }) async {
    _collection.replaceFirst(
      (a) => a.id == applicationId,
      (a) => a.copyWith(
        estado: estado,
        horasAcreditadas: horasAcreditadas,
        motivo: motivo,
        actualizadaEn: DateTime.now(),
      ),
    );
  }
}
