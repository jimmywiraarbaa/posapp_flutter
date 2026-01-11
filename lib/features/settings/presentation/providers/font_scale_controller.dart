import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/settings_repository.dart';

const _minFontScale = 0.8;
const _maxFontScale = 1.3;
const _defaultFontScale = 1.0;

class FontScaleController extends StateNotifier<double> {
  FontScaleController(this._settingsRepository)
      : super(_defaultFontScale) {
    _load();
  }

  final SettingsRepository _settingsRepository;

  Future<void> _load() async {
    final value = await _settingsRepository.getFontScale();
    state = _normalizeScale(value);
  }

  Future<void> setFontScale(double scale) async {
    final normalized = _normalizeScale(scale);
    state = normalized;
    await _settingsRepository.setFontScale(normalized);
  }

  double _normalizeScale(double value) {
    if (value.isNaN || value.isInfinite) {
      return _defaultFontScale;
    }
    return value.clamp(_minFontScale, _maxFontScale).toDouble();
  }
}
