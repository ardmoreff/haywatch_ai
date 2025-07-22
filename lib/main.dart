import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dashboard_screen.dart';
import 'field_planner_screen.dart';
import 'map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HayWatchApp());
}

class HayWatchApp extends StatelessWidget {
  const HayWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HayWatch AI',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/field-planner': (context) => const FieldPlannerScreen(),
        '/map': (context) => const MapScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
