import 'dart:math';

String generateId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final randomSuffix = Random().nextInt(1000).toString().padLeft(3, '0');
  return '$timestamp$randomSuffix';
}
