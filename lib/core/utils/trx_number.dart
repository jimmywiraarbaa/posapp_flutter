String generateTrxNumber() {
  final now = DateTime.now();
  final date = [
    now.year.toString().padLeft(4, '0'),
    now.month.toString().padLeft(2, '0'),
    now.day.toString().padLeft(2, '0'),
  ].join('');
  final time = [
    now.hour.toString().padLeft(2, '0'),
    now.minute.toString().padLeft(2, '0'),
    now.second.toString().padLeft(2, '0'),
  ].join('');
  final suffix = now.microsecondsSinceEpoch.remainder(1000).toString().padLeft(3, '0');
  return 'TRX$date-$time-$suffix';
}
