import 'package:flutter/material.dart';
import 'screens/select_players_screen.dart';

void main() {
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
      home: const SelectPlayersScreen(), // Loads the main screen of the game
    );
  }
}
