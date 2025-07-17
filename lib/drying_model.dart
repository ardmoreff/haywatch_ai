List<double> simulateDrying({
  required double initialMoisture,
  required double et,
  required double wind,
  required double humidity,
}) {
  double moisture = initialMoisture;
  List<double> forecast = [moisture];

  for (int i = 0; i < 5; i++) {
    double dropRate = (et * (wind / 10)) - (humidity / 200);
    moisture = (moisture - dropRate).clamp(0, 100);
    forecast.add(double.parse(moisture.toStringAsFixed(1)));
  }

  return forecast;
}
