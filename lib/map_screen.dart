import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final LatLng _center = LatLng(34.1743, -97.1436); // Ardmore, OK
  late GoogleMapController _controller;

  List<Map<String, dynamic>> _taggedFields = [];
  Set<Marker> _markers = {};

  void _onTap(LatLng latLng) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select Crop Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lat: ${latLng.latitude}\nLng: ${latLng.longitude}'),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              items: [
                DropdownMenuItem(value: 'Alfalfa', child: Text('🌿 Alfalfa')),
                DropdownMenuItem(value: 'Bermuda', child: Text('🌱 Bermuda')),
                DropdownMenuItem(value: 'Ryegrass', child: Text('🌾 Ryegrass')),
                DropdownMenuItem(
                  value: 'Sudan Grass',
                  child: Text('🌻 Sudan Grass'),
                ),
                DropdownMenuItem(value: 'Other', child: Text('🌽 Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _taggedFields.add({
                    'lat': latLng.latitude,
                    'lng': latLng.longitude,
                    'crop': value,
                  });

                  _markerForCrop(latLng, value);

                  Navigator.pop(context);
                  _showConfirmationDialog(latLng, value);
                }
              },
              decoration: InputDecoration(labelText: 'Crop Type'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(LatLng latLng, String cropType) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Field Tagged'),
        content: Text(
          'Lat: ${latLng.latitude}\nLng: ${latLng.longitude}\nCrop: $cropType',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _markerForCrop(LatLng latLng, String cropType) {
    final marker = Marker(
      markerId: MarkerId('${latLng.latitude}_${latLng.longitude}'),
      position: latLng,
      infoWindow: InfoWindow(title: cropType),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tap to Select Field')),
      body: GoogleMap(
        onMapCreated: (controller) => _controller = controller,
        initialCameraPosition: CameraPosition(target: _center, zoom: 15),
        onTap: _onTap,
        markers: _markers,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
