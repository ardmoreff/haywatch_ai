import 'package:flutter/material.dart';
import 'drying_model.dart';

class DryingInputCard extends StatefulWidget {
  const DryingInputCard({super.key});

  @override
  State<DryingInputCard> createState() => _DryingInputCardState();
}

class _DryingInputCardState extends State<DryingInputCard> {
  double moistureLevel = 50;
  double temperature = 75;
  double windSpeed = 10;
  String dryingSummary = '';

  void updateSummary() {
    final model = DryingModel(
      moistureLevel: moistureLevel,
      temperature: temperature,
      windSpeed: windSpeed,
    );
    setState(() {
      dryingSummary = model.estimateDryingSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drying Conditions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Moisture Level: ${moistureLevel.toStringAsFixed(1)}%'),
            Slider(
              value: moistureLevel,
              min: 0,
              max: 100,
              divisions: 100,
              label: moistureLevel.toStringAsFixed(1),
              onChanged: (val) {
                setState(() => moistureLevel = val);
                updateSummary();
              },
            ),
            Text('Temperature: ${temperature.toStringAsFixed(1)}°F'),
            Slider(
              value: temperature,
              min: 32,
              max: 120,
              divisions: 88,
              label: temperature.toStringAsFixed(1),
              onChanged: (val) {
                setState(() => temperature = val);
                updateSummary();
              },
            ),
            Text('Wind Speed: ${windSpeed.toStringAsFixed(1)} mph'),
            Slider(
              value: windSpeed,
              min: 0,
              max: 40,
              divisions: 40,
              label: windSpeed.toStringAsFixed(1),
              onChanged: (val) {
                setState(() => windSpeed = val);
                updateSummary();
              },
            ),
            const SizedBox(height: 16),
            Text(
              dryingSummary.isEmpty
                  ? 'Adjust sliders to estimate drying.'
                  : dryingSummary,
              style: const TextStyle(fontSize: 16, color: Colors.brown),
            ),
          ],
        ),
      ),
    );
  }
}
