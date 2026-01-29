import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/db/app_database.dart' as db;
import '../../domain/entities/backup_file.dart';

const _backupDirName = 'backups';
const _backupVersion = 3;

class BackupLocalDataSource {
  BackupLocalDataSource(this._db);

  final db.AppDatabase _db;

  Future<String> createBackup() async {
    final dir = await _getBackupDir();
    final timestamp = DateTime.now();
    final fileName = _formatFileName(timestamp);
    final file = File(p.join(dir.path, fileName));

    final payload = await _exportDatabase();
    await file.writeAsString(jsonEncode(payload));

    return file.path;
  }

  Future<void> restoreBackup(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('File backup tidak ditemukan.');
    }

    final contents = await file.readAsString();
    final decoded = jsonDecode(contents);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Format backup tidak valid.');
    }

    final rawVersion = decoded['version'];
    final version = rawVersion is int
        ? rawVersion
        : int.tryParse(rawVersion?.toString() ?? '');
    if (version == null ||
        (version != 1 && version != 2 && version != _backupVersion)) {
      throw StateError('Versi backup tidak didukung.');
    }

    final tables = decoded['tables'];
    if (tables is! Map<String, dynamic>) {
      throw StateError('Data backup tidak lengkap.');
    }

    final products = _parseList(tables['products'])
        .map((row) => db.Product.fromJson(row))
        .toList();
    final categories = _parseCategories(
      _parseList(tables['categories']),
      version,
    );
    final units =
        _parseList(tables['units']).map((row) => db.Unit.fromJson(row)).toList();
    final transactions = _parseList(tables['transactions'])
        .map((row) => db.Transaction.fromJson(row))
        .toList();
    final transactionItems = _parseList(tables['transaction_items'])
        .map((row) => db.TransactionItem.fromJson(row))
        .toList();
    final stockMovements = _parseList(tables['stock_movements'])
        .map((row) => db.StockMovement.fromJson(row))
        .toList();
    final expenses = version >= 3
        ? _parseList(tables['expenses'])
            .map((row) => db.Expense.fromJson(row))
            .toList()
        : <db.Expense>[];
    final settings = _parseList(tables['settings'])
        .map((row) => db.Setting.fromJson(row))
        .toList();
    final pins =
        _parseList(tables['pins']).map((row) => db.Pin.fromJson(row)).toList();

    await _db.transaction(() async {
      await _db.delete(_db.transactionItems).go();
      await _db.delete(_db.stockMovements).go();
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.expenses).go();
      await _db.delete(_db.products).go();
      await _db.delete(_db.units).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.settings).go();
      await _db.delete(_db.pins).go();

      await _db.batch((batch) {
        if (categories.isNotEmpty) {
          batch.insertAll(
            _db.categories,
            categories.map((item) => item.toCompanion(true)).toList(),
          );
        }
        if (units.isNotEmpty) {
          batch.insertAll(
            _db.units,
            units.map((item) => item.toCompanion(true)).toList(),
          );
        }
        if (products.isNotEmpty) {
          batch.insertAll(
            _db.products,
            products.map((item) => item.toCompanion(true)).toList(),
          );
        }
        if (transactions.isNotEmpty) {
          batch.insertAll(
            _db.transactions,
            transactions.map((item) => item.toCompanion(true)).toList(),
          );
        }
        if (transactionItems.isNotEmpty) {
          batch.insertAll(
            _db.transactionItems,
            transactionItems.map((item) => item.toCompanion(true)).toList(),
          );
        }
        if (stockMovements.isNotEmpty) {
          batch.insertAll(
            _db.stockMovements,
            stockMovements.map((item) => item.toCompanion(true)).toList(),
          );
        }
        if (expenses.isNotEmpty) {
          batch.insertAll(
            _db.expenses,
            expenses.map((item) => item.toCompanion(true)).toList(),
          );
        }
        if (settings.isNotEmpty) {
          batch.insertAll(
            _db.settings,
            settings.map((item) => item.toCompanion(true)).toList(),
          );
        }
        if (pins.isNotEmpty) {
          batch.insertAll(
            _db.pins,
            pins.map((item) => item.toCompanion(true)).toList(),
          );
        }
      });
    });
  }

  Future<List<BackupFile>> listBackups() async {
    final dir = await _getBackupDir();
    if (!await dir.exists()) {
      return [];
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList();

    final backups = files.map((file) {
      final stat = file.statSync();
      return BackupFile(
        path: file.path,
        name: p.basename(file.path),
        modifiedAt: stat.modified,
        sizeBytes: stat.size,
      );
    }).toList();

    backups.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return backups;
  }

  Future<Map<String, dynamic>> _exportDatabase() async {
    final products = await _db.select(_db.products).get();
    final categories = await _db.select(_db.categories).get();
    final units = await _db.select(_db.units).get();
    final transactions = await _db.select(_db.transactions).get();
    final transactionItems = await _db.select(_db.transactionItems).get();
    final stockMovements = await _db.select(_db.stockMovements).get();
    final expenses = await _db.select(_db.expenses).get();
    final settings = await _db.select(_db.settings).get();
    final pins = await _db.select(_db.pins).get();

    return {
      'version': _backupVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'tables': {
        'products': products.map((item) => item.toJson()).toList(),
        'categories': categories.map((item) => item.toJson()).toList(),
        'units': units.map((item) => item.toJson()).toList(),
        'transactions': transactions.map((item) => item.toJson()).toList(),
        'transaction_items':
            transactionItems.map((item) => item.toJson()).toList(),
        'stock_movements':
            stockMovements.map((item) => item.toJson()).toList(),
        'expenses': expenses.map((item) => item.toJson()).toList(),
        'settings': settings.map((item) => item.toJson()).toList(),
        'pins': pins.map((item) => item.toJson()).toList(),
      },
    };
  }

  Future<Directory> _getBackupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _backupDirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _formatFileName(DateTime timestamp) {
    final y = timestamp.year.toString().padLeft(4, '0');
    final m = timestamp.month.toString().padLeft(2, '0');
    final d = timestamp.day.toString().padLeft(2, '0');
    final h = timestamp.hour.toString().padLeft(2, '0');
    final min = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return 'posapp_backup_${y}${m}${d}_${h}${min}${s}.json';
  }

  List<Map<String, dynamic>> _parseList(dynamic value) {
    if (value is! List) {
      return [];
    }
    return value
        .whereType<Map>()
        .map((item) => item.map(
              (key, val) => MapEntry(key.toString(), val),
            ))
        .toList();
  }

  List<db.Category> _parseCategories(
    List<Map<String, dynamic>> rows,
    int version,
  ) {
    if (version >= 2) {
      return rows.map((row) => db.Category.fromJson(row)).toList();
    }

    final normalized = rows
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    normalized.sort((a, b) {
      final left = (a['createdAt'] ?? '').toString();
      final right = (b['createdAt'] ?? '').toString();
      return left.compareTo(right);
    });
    var order = 1;
    for (final row in normalized) {
      row.putIfAbsent('sortOrder', () => order);
      order++;
    }
    return normalized.map((row) => db.Category.fromJson(row)).toList();
  }
}
