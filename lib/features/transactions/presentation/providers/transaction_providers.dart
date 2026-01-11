import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/transaction_local_data_source.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction_item_record.dart';
import '../../domain/entities/transaction_record.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_sale.dart';
import '../../domain/usecases/fetch_transaction_items.dart';
import '../../domain/usecases/void_transaction.dart';
import '../../domain/usecases/watch_transactions.dart';

final transactionLocalDataSourceProvider =
    Provider<TransactionLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionLocalDataSource(db);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final local = ref.watch(transactionLocalDataSourceProvider);
  return TransactionRepositoryImpl(local);
});

final createSaleProvider = Provider<CreateSale>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return CreateSale(repo);
});

final watchTransactionsProvider = Provider<WatchTransactions>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return WatchTransactions(repo);
});

final fetchTransactionItemsProvider = Provider<FetchTransactionItems>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return FetchTransactionItems(repo);
});

final voidTransactionProvider = Provider<VoidTransaction>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return VoidTransaction(repo);
});

final transactionsStreamProvider =
    StreamProvider.family<List<TransactionRecord>, bool>((ref, includeVoid) {
  final watchTransactions = ref.watch(watchTransactionsProvider);
  return watchTransactions(includeVoid: includeVoid);
});

final transactionItemsProvider =
    FutureProvider.family<List<TransactionItemRecord>, String>(
  (ref, transactionId) {
    final fetchItems = ref.watch(fetchTransactionItemsProvider);
    return fetchItems(transactionId);
  },
);
