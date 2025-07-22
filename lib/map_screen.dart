import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(34.1743, -97.1436); // Ardmore, OK
  final List<Marker> _markers = [];

  void _saveFieldToFirestore(Map<String, dynamic> fieldData) async {
    try {
      await FirebaseFirestore.instance.collection('fields').add(fieldData);
    } catch (e) {
      print('Error saving field: $e');
    }
  }

  void _onTap(TapPosition tapPosition, LatLng latLng) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedCrop;
        return AlertDialog(
          title: const Text('Select Crop Type'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lat: ${latLng.latitude.toStringAsFixed(4)}\nLng: ${latLng.longitude.toStringAsFixed(4)}'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCrop,
                    items: const [
                      DropdownMenuItem(value: 'Alfalfa', child: Text('🌿 Alfalfa')),
                      DropdownMenuItem(value: 'Bermuda', child: Text('🌱 Bermuda')),
                      DropdownMenuItem(value: 'Ryegrass', child: Text('🌾 Ryegrass')),
                      DropdownMenuItem(value: 'Sudan Grass', child: Text('🌻 Sudan Grass')),
                      DropdownMenuItem(value: 'Other', child: Text('🌽 Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCrop = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Crop Type'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedCrop != null) {
                  final fieldData = {
                    'name': 'Field ${_markers.length + 1}',
                    'lat': latLng.latitude,
                    'lng': latLng.longitude,
                    'crop': selectedCrop,
                    'moisture': 50.0,
                    'temperature': 75.0,
                    'windSpeed': 5.0,
                    'timestamp': Timestamp.now(),
                  };
                  _saveFieldToFirestore(fieldData);
                  _addMarker(latLng, selectedCrop!);
                  Navigator.of(context).pop();
                  _showConfirmationDialog(latLng, selectedCrop!);
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addMarker(LatLng position, String crop) {
    setState(() {
      _markers.add(
        Marker(
          point: position,
          child: const Icon(Icons.location_on, color: Colors.green, size: 32),
        ),
      );
    });
  }

  void _showConfirmationDialog(LatLng position, String crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Field Tagged!'),
        content: Text('Crop: $crop\nLat: ${position.latitude.toStringAsFixed(4)}\nLng: ${position.longitude.toStringAsFixed(4)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag a Field'),
        backgroundColor: Colors.teal[700],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 13.0,
          onTap: _onTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
