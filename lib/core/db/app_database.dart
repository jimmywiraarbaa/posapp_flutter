import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Categories,
    Units,
    Transactions,
    TransactionItems,
    StockMovements,
    Settings,
    Pins,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(products, products.imagePath);
          }
          if (from < 3) {
            await m.addColumn(categories, categories.sortOrder);

            final existing = await (select(categories)
                  ..orderBy([
                    (tbl) => OrderingTerm(expression: tbl.createdAt),
                  ]))
                .get();
            var order = 1;
            for (final row in existing) {
              await (update(categories)..where((tbl) => tbl.id.equals(row.id)))
                  .write(CategoriesCompanion(sortOrder: Value(order)));
              order++;
            }

            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS categories_sort_order_unique '
              'ON categories(sort_order)',
            );
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'posapp.sqlite'));
    return NativeDatabase(file);
  });
}
