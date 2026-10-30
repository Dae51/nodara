import 'dart:async';

/// Colección en memoria que imita `snapshots()` de Firestore: cada
/// suscriptor recibe primero el contenido actual y luego cada cambio.
class InMemoryCollection<T> {
  InMemoryCollection(Iterable<T> seed) : _items = List<T>.of(seed);

  final List<T> _items;
  final StreamController<List<T>> _changes =
      StreamController<List<T>>.broadcast();

  List<T> get items => List<T>.unmodifiable(_items);

  Stream<List<T>> watch() async* {
    yield items;
    yield* _changes.stream;
  }

  Stream<List<T>> watchWhere(bool Function(T item) test) =>
      watch().map((list) => list.where(test).toList());

  void add(T item) {
    _items.insert(0, item);
    _emit();
  }

  /// Reemplaza el primer elemento que cumpla [test].
  bool replaceFirst(bool Function(T item) test, T Function(T item) update) {
    final index = _items.indexWhere(test);
    if (index == -1) return false;
    _items[index] = update(_items[index]);
    _emit();
    return true;
  }

  void _emit() => _changes.add(items);
}

int _fakeIdCounter = 0;

/// Genera IDs únicos para los fakes.
String fakeId(String prefix) {
  _fakeIdCounter++;
  return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_fakeIdCounter';
}
