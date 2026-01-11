String formatRupiah(int amount) {
  final isNegative = amount < 0;
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final reverseIndex = digits.length - i;
    buffer.write(digits[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }
  final formatted = buffer.toString();
  return isNegative ? '-Rp $formatted' : 'Rp $formatted';
}

String formatQty(double value) {
  final fixed = value.toStringAsFixed(2);
  if (fixed.endsWith('.00')) {
    return fixed.substring(0, fixed.length - 3);
  }
  if (fixed.endsWith('0')) {
    return fixed.substring(0, fixed.length - 1);
  }
  return fixed;
}
