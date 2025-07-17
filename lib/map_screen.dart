import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _center = const LatLng(34.1743, -97.1436); // Default: Ardmore, OK
  final List<Map<String, dynamic>> _taggedFields = [];
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 📡 Try fetching location on startup
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('📵 Location services disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print('🚫 Location permission denied forever.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          point: _center,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
        ),
      );
    });

    print('📍 Current location: $_center');
  }

  void _saveFieldToFirestore(Map<String, dynamic> fieldData) async {
    print('📤 Attempting to save field: $fieldData');
    try {
      await FirebaseFirestore.instance.collection('fields').add(fieldData);
      print(
          '✅ Field saved: ${fieldData['crop']} at ${fieldData['lat']}, ${fieldData['lng']}');
    } catch (e) {
      print('❌ Error saving field: $e');
    }
  }

  void _onTap(TapPosition tapPosition, LatLng latLng) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Crop Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lat: ${latLng.latitude}\nLng: ${latLng.longitude}'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'Alfalfa', child: Text('🌿 Alfalfa')),
                DropdownMenuItem(value: 'Bermuda', child: Text('🌱 Bermuda')),
                DropdownMenuItem(value: 'Ryegrass', child: Text('🌾 Ryegrass')),
                DropdownMenuItem(
                    value: 'Sudan Grass', child: Text('🌻 Sudan Grass')),
                DropdownMenuItem(value: 'Other', child: Text('🌽 Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  final fieldData = {
                    'lat': latLng.latitude,
                    'lng': latLng.longitude,
                    'crop': value,
                    'timestamp': Timestamp.now(),
                  };

                  _taggedFields.add(fieldData);
                  _saveFieldToFirestore(fieldData);
                  _addMarker(latLng, value);

                  Navigator.pop(context);
                  _showConfirmationDialog(latLng, value);
                }
              },
              decoration: const InputDecoration(labelText: 'Crop Type'),
            ),
          ],
        ),
      ),
    );
  }

  void _addMarker(LatLng latLng, String cropType) {
    final marker = Marker(
      point: latLng,
      child: const Icon(Icons.location_on, color: Colors.green, size: 36),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _showConfirmationDialog(LatLng latLng, String cropType) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Field Tagged'),
        content: Text(
            'Lat: ${latLng.latitude}\nLng: ${latLng.longitude}\nCrop: $cropType'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📍 Tap to Select Field')),
      body: FlutterMap(
        options: MapOptions(
          center: _center,
          zoom: 15,
          maxZoom: 18,
          minZoom: 3,
          interactiveFlags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom,
          onTap: _onTap,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.haywatch_ai',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
