import 'package:drift/drift.dart';

class Products extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().named('name')();
  TextColumn get categoryId => text().named('category_id')();
  TextColumn get unitId => text().named('unit_id')();
  IntColumn get price => integer().named('price')();
  RealColumn get stockQty => real().named('stock_qty')();
  RealColumn get minStock => real().named('min_stock')();
  BoolColumn get isActive => boolean().named('is_active')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'products';
}

class Categories extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().named('name')();
  BoolColumn get isActive => boolean().named('is_active')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'categories';
}

class Units extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().named('name')();
  TextColumn get symbol => text().named('symbol')();
  BoolColumn get isActive => boolean().named('is_active')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'units';
}

class Transactions extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get trxNumber => text().named('trx_number')();
  IntColumn get total => integer().named('total')();
  IntColumn get paidAmount => integer().named('paid_amount')();
  IntColumn get changeAmount => integer().named('change_amount')();
  TextColumn get paymentMethod => text().named('payment_method')();
  TextColumn get status => text().named('status')();
  TextColumn get note => text().named('note').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'transactions';
}

class TransactionItems extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get transactionId => text().named('transaction_id')();
  TextColumn get productId => text().named('product_id')();
  RealColumn get qty => real().named('qty')();
  IntColumn get price => integer().named('price')();
  IntColumn get subtotal => integer().named('subtotal')();
  TextColumn get note => text().named('note').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'transaction_items';
}

class StockMovements extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get productId => text().named('product_id')();
  TextColumn get type => text().named('type')();
  RealColumn get qty => real().named('qty')();
  TextColumn get refId => text().named('ref_id').nullable()();
  TextColumn get note => text().named('note').nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'stock_movements';
}

class Settings extends Table {
  TextColumn get key => text().named('key')();
  TextColumn get value => text().named('value')();

  @override
  Set<Column> get primaryKey => {key};

  @override
  String get tableName => 'settings';
}

class Pins extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().named('name')();
  TextColumn get pinHash => text().named('pin_hash')();
  TextColumn get role => text().named('role')();
  BoolColumn get isActive => boolean().named('is_active')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'pins';
}
