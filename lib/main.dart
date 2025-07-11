import 'package:haywatch_ai/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:haywatch_ai/dashboard_screen.dart';
void main() {
  runApp(HayWatchApp());
}

class HayWatchApp extends StatelessWidget {
  const HayWatchApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HayWatch AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FieldDashboard(),
    );
  }
}

class FieldDashboard extends StatelessWidget {
  const FieldDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HayWatch AI')),
body: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      },
      child: Text('📍 Select Field on Map'),
    ),
    SizedBox(height: 20),
    ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      },
      child: Text('📋 View Tagged Fields'),
    ),
  ],
),
    );
  }
}
