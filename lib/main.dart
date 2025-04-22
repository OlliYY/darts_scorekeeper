import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with project URL and anon key
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const DartsScorekeeperApp());
}

/// The root widget of the application.
class DartsScorekeeperApp extends StatelessWidget {
  const DartsScorekeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Darts Scorekeeper',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: const GameScreen(), // Loads the main screen of the game
    );
  }
}


