import 'drying_model.dart';

void main() {
  final test1 = DryingModel(
    moistureLevel: 65,
    temperature: 85,
    windSpeed: 12,
  );

  final test2 = DryingModel(
    moistureLevel: 30,
    temperature: 70,
    windSpeed: 5,
  );

  print('Test 1: ${test1.estimateDryingSummary()}');
  print('Test 2: ${test2.estimateDryingSummary()}');
}
