class DryingModel {
  final double moistureLevel;    // 0–100%
  final double temperature;      // in °F
  final double windSpeed;        // in mph

  DryingModel({
    required this.moistureLevel,
    required this.temperature,
    required this.windSpeed,
  });

  String estimateDryingSummary() {
    if (moistureLevel < 20) {
      return 'Already dry. No action needed.';
    }

    final double dryingRate = (temperature * 0.02) + (windSpeed * 0.05) - (moistureLevel * 0.01);
    final double days = (moistureLevel / dryingRate).clamp(0.5, 7.0);

    if (days <= 1.5) {
      return 'Rapid drying expected — ready in ~${days.toStringAsFixed(1)} day(s).';
    } else if (days <= 3.5) {
      return 'Moderate drying expected — ready in ~${days.toStringAsFixed(1)} days.';
    } else {
      return 'Slow drying — monitor conditions daily (~${days.toStringAsFixed(1)} days).';
    }
  }
}