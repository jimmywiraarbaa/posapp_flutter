import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../data/datasources/report_local_data_source.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/top_product.dart';
import '../../domain/repositories/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportRepositoryImpl(ReportLocalDataSource(db));
});

final reportDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  return DateTimeRange(start: start, end: end);
});

final topProductsProvider = FutureProvider.family<List<TopProduct>, DateTimeRange>(
  (ref, range) {
    final repo = ref.watch(reportRepositoryProvider);
    return repo.fetchTopProducts(
      start: range.start,
      end: range.end,
      limit: 5,
    );
  },
);
