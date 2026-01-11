import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/transaction_local_data_source.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_sale.dart';

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
