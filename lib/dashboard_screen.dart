import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drying_model.dart' as dry;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> markFieldAsCut(String fieldId) async {
    final forecast = dry.simulateDrying(
      initialMoisture: 78,
      et: 0.18,
      wind: 12,
      humidity: 60,
    );

    await FirebaseFirestore.instance.collection('fields').doc(fieldId).update({
      'forecastMoisture': forecast,
      'predictedBaleDay':
          DateTime.now().add(const Duration(days: 5)).toIso8601String(),
    });
  }

  Future<void> tagNewField() async {
    await FirebaseFirestore.instance.collection('fields').add({
      'crop': 'alfalfa',
      'lat': 34.158,
      'lng': -110.884,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String _formatTimestamp(Timestamp ts) {
    final dt = ts.toDate();
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tagged Fields')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: tagNewField,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('➕ Tag New Field'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('fields').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['crop'] ?? 'Unknown Crop',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text('📍 Location: ${data['lat']}, ${data['lng']}'),
                            if (data['timestamp'] != null)
                              Text(
                                  '🕒 Tagged: ${_formatTimestamp(data['timestamp'])}'),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => markFieldAsCut(doc.id),
                              icon: const Icon(Icons.local_florist),
                              label: const Text('Mark as Cut'),
                            ),
                            if (data['forecastMoisture'] != null &&
                                data['predictedBaleDay'] != null) ...[
                              const Divider(height: 20),
                              const Text(
                                '🌤️ Moisture Forecast:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              ...List.generate(
                                data['forecastMoisture'].length,
                                (i) => Text(
                                    'Day ${i + 1}: ${data['forecastMoisture'][i]}%'),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '📅 Predicted Bale Day: ${data['predictedBaleDay'].substring(0, 10)}',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
