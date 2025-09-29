import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'sales_db.g.dart';

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Sales])
class SalesDb extends _$SalesDb {
  SalesDb() : super(_open());
  @override
  int get schemaVersion => 1;

  Future<List<Sale>> all() => select(sales).get();
  Future<void> upsert(SalesCompanion data) =>
      into(sales).insertOnConflictUpdate(data);
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
