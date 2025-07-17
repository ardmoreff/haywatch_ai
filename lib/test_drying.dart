import 'drying_model.dart';

void main() {
  final result = simulateDrying(
    initialMoisture: 75,
    et: 0.2,
    wind: 10,
    humidity: 60,
  );
  print('Forecast result: $result');
}
