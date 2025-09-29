import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

/// Database tables
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleId => text().named('sale_id')();
  TextColumn get title => text()();
  RealColumn get total => real()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  BoolColumn get isSynced =>
      boolean().named('is_synced').withDefault(const Constant(false))();
}

/// Database access object
@DriftDatabase(tables: [Sales])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Get all sales
  Future<List<Sale>> getAllSales() async {
    return await select(sales).get();
  }

  /// Get sales by ID
  Future<Sale?> getSaleById(String saleId) async {
    return await (select(
      sales,
    )..where((t) => t.saleId.equals(saleId))).getSingleOrNull();
  }

  /// Insert or update sale
  Future<void> upsertSale(SalesCompanion sale) async {
    await into(sales).insertOnConflictUpdate(sale);
  }

  /// Insert multiple sales
  Future<void> insertSales(List<SalesCompanion> salesList) async {
    await batch((batch) {
      batch.insertAll(sales, salesList);
    });
  }

  /// Update sale sync status
  Future<void> markAsSynced(String saleId) async {
    await (update(sales)..where((t) => t.saleId.equals(saleId))).write(
      SalesCompanion(isSynced: const Value(true)),
    );
  }

  /// Get unsynced sales
  Future<List<Sale>> getUnsyncedSales() async {
    return await (select(sales)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Delete sale
  Future<void> deleteSale(String saleId) async {
    await (delete(sales)..where((t) => t.saleId.equals(saleId))).go();
  }

  /// Clear all data
  Future<void> clearAll() async {
    await delete(sales).go();
  }
}

/// Database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}
