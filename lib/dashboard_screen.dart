import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haywatch_ai/drying_input_card.dart'; // Make sure the path matches

...

body: Column(
  children: [
    DryingInputCard(), // 👈 This goes up top
    Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fields').snapshots(),
        builder: (context, snapshot) {
          // your existing list view code here
        },
      ),
    ),
  ],
),
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tagged Fields')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fields').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final lat = data['lat'];
              final lng = data['lng'];
              final crop = data['crop'];
              final timestamp = data['timestamp'];

              return ListTile(
                leading: Icon(Icons.grass, color: Colors.green),
                title: Text('$crop'),
                subtitle: Text('Lat: $lat\nLng: $lng'),
                trailing: timestamp != null
                    ? Text(_formatTimestamp(timestamp))
                    : SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final dt = ts.toDate();
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}