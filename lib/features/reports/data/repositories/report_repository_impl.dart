import '../../domain/entities/top_product.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._localDataSource);

  final ReportLocalDataSource _localDataSource;

  @override
  Future<List<TopProduct>> fetchTopProducts({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) {
    return _localDataSource.fetchTopProducts(
      start: start,
      end: end,
      limit: limit,
    );
  }
}
