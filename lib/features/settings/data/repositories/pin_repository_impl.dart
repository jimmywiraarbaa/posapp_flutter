import '../../../../core/utils/pin_hash.dart';
import '../../domain/repositories/pin_repository.dart';
import '../datasources/pin_local_data_source.dart';

class PinRepositoryImpl implements PinRepository {
  PinRepositoryImpl(this._localDataSource);

  final PinLocalDataSource _localDataSource;

  void _ensureSixDigitPin(String pin) {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw StateError('PIN harus 6 digit angka.');
    }
  }

  @override
  Future<bool> hasPin() {
    return _localDataSource.hasPin();
  }

  @override
  Future<void> setPin(String pin) {
    final normalized = pin.trim();
    _ensureSixDigitPin(normalized);
    final hash = hashPin(normalized);
    return _localDataSource.setPin(pinHash: hash);
  }

  @override
  Future<bool> verifyPin(String pin) {
    final normalized = pin.trim();
    _ensureSixDigitPin(normalized);
    final hash = hashPin(normalized);
    return _localDataSource.verifyPin(pinHash: hash);
  }
}
