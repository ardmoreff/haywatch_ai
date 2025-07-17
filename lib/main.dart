import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'map_screen.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Firebase can initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setUrlStrategy(
      const HashUrlStrategy()); // Enables web-safe routing (e.g. /#/dashboard)
  runApp(const HayWatchApp());
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
      initialRoute: '/',
      routes: {
        '/': (context) => const FieldDashboard(),
        '/map': (context) => const MapScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

class FieldDashboard extends StatelessWidget {
  const FieldDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HayWatch AI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/map'),
              child: const Text('📍 Select Field on Map'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              child: const Text('📋 View Tagged Fields'),
            ),
          ],
        ),
      ),
    );
  }
}
