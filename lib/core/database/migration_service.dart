import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../logging/talker_config.dart';
import '../error/failure.dart';
import '../network/result.dart';
import 'supabase_service.dart';

/// Database migration service for schema management
///
/// Usage:
/// ```dart
/// final migrationService = MigrationService();
/// await migrationService.initialize();
/// await migrationService.runMigrations();
/// ```
class MigrationService {
  static final MigrationService _instance = MigrationService._internal();
  factory MigrationService() => _instance;
  MigrationService._internal();

  late Database _database;
  late SupabaseService _supabaseService;
  bool _isInitialized = false;

  /// Initialize migration service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local SQLite database
      final databasesPath = await getDatabasesPath();
      final dbPath = path.join(databasesPath, 'pos_database.db');

      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      // Initialize Supabase service
      _supabaseService = SupabaseService();
      await _supabaseService.initialize();

      _isInitialized = true;
      TalkerConfig.logInfo('Migration service initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize migration service',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales (
          id TEXT PRIMARY KEY,
          customer_id TEXT,
          total REAL NOT NULL,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          synced_at TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales_items (
          id TEXT PRIMARY KEY,
          sale_id TEXT NOT NULL,
          product_id TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT,
          phone TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          synced_at TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS inventory (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          sku TEXT UNIQUE NOT NULL,
          price REAL NOT NULL,
          stock INTEGER NOT NULL,
          category TEXT,
          description TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          synced_at TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS payments (
          id TEXT PRIMARY KEY,
          sale_id TEXT NOT NULL,
          amount REAL NOT NULL,
          method TEXT NOT NULL,
          status TEXT NOT NULL,
          transaction_id TEXT,
          created_at TEXT NOT NULL,
          synced_at TEXT,
          FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          table_name TEXT NOT NULL,
          record_id TEXT NOT NULL,
          operation TEXT NOT NULL,
          status TEXT NOT NULL,
          error_message TEXT,
          created_at TEXT NOT NULL,
          synced_at TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS migrations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          version INTEGER NOT NULL,
          name TEXT NOT NULL,
          executed_at TEXT NOT NULL
        )
      ''');

      TalkerConfig.logInfo('Database tables created successfully');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to create database tables', e, stackTrace);
      rethrow;
    }
  }

  /// Upgrade database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      TalkerConfig.logInfo(
        'Upgrading database from version $oldVersion to $newVersion',
      );

      // Add migration logic here for future versions
      if (oldVersion < 2) {
        // Example: Add new column
        // await db.execute('ALTER TABLE sales ADD COLUMN notes TEXT');
      }

      TalkerConfig.logInfo('Database upgrade completed');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to upgrade database', e, stackTrace);
      rethrow;
    }
  }

  /// Run all pending migrations
  Future<Result<void>> runMigrations() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Get current migration version
      final currentVersion = await _getCurrentMigrationVersion();
      final latestVersion = _getLatestMigrationVersion();

      if (currentVersion >= latestVersion) {
        TalkerConfig.logInfo('Database is up to date');
        return const Success(null);
      }

      // Run migrations
      for (
        int version = currentVersion + 1;
        version <= latestVersion;
        version++
      ) {
        await _runMigration(version);
      }

      TalkerConfig.logInfo('All migrations completed successfully');
      return const Success(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to run migrations', e, stackTrace);
      return Error(Failure('Failed to run migrations: $e'));
    }
  }

  /// Get current migration version
  Future<int> _getCurrentMigrationVersion() async {
    try {
      final result = await _database.rawQuery(
        'SELECT MAX(version) as version FROM migrations',
      );
      return result.first['version'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get latest migration version
  int _getLatestMigrationVersion() {
    return 1; // Current schema version
  }

  /// Run specific migration
  Future<void> _runMigration(int version) async {
    try {
      final migrationName = 'migration_$version';

      // Check if migration already executed
      final existing = await _database.query(
        'migrations',
        where: 'version = ?',
        whereArgs: [version],
      );

      if (existing.isNotEmpty) {
        TalkerConfig.logInfo('Migration $version already executed');
        return;
      }

      // Execute migration based on version
      switch (version) {
        case 1:
          await _migration001();
          break;
        default:
          TalkerConfig.logWarning('Unknown migration version: $version');
          return;
      }

      // Record migration
      await _database.insert('migrations', {
        'version': version,
        'name': migrationName,
        'executed_at': DateTime.now().toIso8601String(),
      });

      TalkerConfig.logInfo('Migration $version executed successfully');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to execute migration $version',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Migration 001: Initial schema
  Future<void> _migration001() async {
    // This migration is handled by _onCreate
    TalkerConfig.logInfo('Migration 001: Initial schema already created');
  }

  /// Sync data with Supabase
  Future<Result<void>> syncWithSupabase() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Sync sales
      await _syncTable('sales');

      // Sync customers
      await _syncTable('customers');

      // Sync inventory
      await _syncTable('inventory');

      // Sync payments
      await _syncTable('payments');

      TalkerConfig.logInfo('Data sync with Supabase completed');
      return const Success(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to sync with Supabase', e, stackTrace);
      return Error(Failure('Failed to sync with Supabase: $e'));
    }
  }

  /// Sync specific table
  Future<void> _syncTable(String tableName) async {
    try {
      // Get unsynced records
      final unsyncedRecords = await _database.query(
        tableName,
        where: 'synced_at IS NULL',
      );

      for (final record in unsyncedRecords) {
        try {
          // Upload to Supabase
          await _supabaseService.client.from(tableName).upsert(record);

          // Mark as synced
          await _database.update(
            tableName,
            {'synced_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [record['id']],
          );

          // Log sync
          await _database.insert('sync_log', {
            'table_name': tableName,
            'record_id': record['id'],
            'operation': 'upload',
            'status': 'success',
            'created_at': DateTime.now().toIso8601String(),
            'synced_at': DateTime.now().toIso8601String(),
          });

          TalkerConfig.logInfo('Synced $tableName record: ${record['id']}');
        } catch (e) {
          // Log sync error
          await _database.insert('sync_log', {
            'table_name': tableName,
            'record_id': record['id'],
            'operation': 'upload',
            'status': 'error',
            'error_message': e.toString(),
            'created_at': DateTime.now().toIso8601String(),
          });

          TalkerConfig.logError(
            'Failed to sync $tableName record: ${record['id']}',
            e,
          );
        }
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to sync table $tableName', e, stackTrace);
      rethrow;
    }
  }

  /// Get sync status
  Future<Result<Map<String, dynamic>>> getSyncStatus() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final status = <String, dynamic>{};

      // Get unsynced counts
      final salesUnsynced = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM sales WHERE synced_at IS NULL',
      );
      final customersUnsynced = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM customers WHERE synced_at IS NULL',
      );
      final inventoryUnsynced = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM inventory WHERE synced_at IS NULL',
      );

      status['sales_unsynced'] = salesUnsynced.first['count'];
      status['customers_unsynced'] = customersUnsynced.first['count'];
      status['inventory_unsynced'] = inventoryUnsynced.first['count'];
      status['last_sync'] = DateTime.now().toIso8601String();

      return Success(status);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get sync status', e, stackTrace);
      return Error(Failure('Failed to get sync status: $e'));
    }
  }

  /// Close database connection
  Future<void> close() async {
    try {
      await _database.close();
      await _supabaseService.close();
      _isInitialized = false;
      TalkerConfig.logInfo('Migration service closed');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to close migration service', e, stackTrace);
    }
  }
}
