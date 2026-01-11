import '../../../../core/utils/pin_hash.dart';
import '../../domain/repositories/pin_repository.dart';
import '../datasources/pin_local_data_source.dart';

class PinRepositoryImpl implements PinRepository {
  PinRepositoryImpl(this._localDataSource);

  final PinLocalDataSource _localDataSource;

  @override
  Future<bool> hasPin() {
    return _localDataSource.hasPin();
  }

  @override
  Future<void> setPin(String pin) {
    final hash = hashPin(pin);
    return _localDataSource.setPin(pinHash: hash);
  }

  @override
  Future<bool> verifyPin(String pin) {
    final hash = hashPin(pin);
    return _localDataSource.verifyPin(pinHash: hash);
  }
}
