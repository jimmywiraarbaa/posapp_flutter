import '../entities/top_product.dart';

abstract class ReportRepository {
  Future<List<TopProduct>> fetchTopProducts({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  });
}
