import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import '../supabase_config.dart';
import 'game_screen.dart';

/// Screen where user can select 2 players from the database and add new ones.
class SelectPlayersScreen extends StatefulWidget {
  const SelectPlayersScreen({super.key});

  @override
  State<SelectPlayersScreen> createState() => _SelectPlayersScreenState();
}

class _SelectPlayersScreenState extends State<SelectPlayersScreen> {
  final SupabaseClient supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);
  List<Map<String, dynamic>> players = [];
  Map<String, dynamic>? selectedPlayer1;
  Map<String, dynamic>? selectedPlayer2;

  final TextEditingController _nameController = TextEditingController();

  /// Fetch players from Supabase
  Future<void> fetchPlayers() async {
    final response = await supabase.from('players').select();
    setState(() {
      players = List<Map<String, dynamic>>.from(response);
    });
  }

  /// Add a new player to Supabase
  Future<void> addPlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      await supabase.from('players').insert({'name': name});
      _nameController.clear();
      fetchPlayers(); // update player list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Player "$name" added!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Start game with selected players
  void startGame() {
    if (selectedPlayer1 != null && selectedPlayer2 != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            player1: selectedPlayer1!,
            player2: selectedPlayer2!,
          ),
        ),
      );
    }
  }

  /// Build a selectable player list tile
  Widget buildPlayerTile(Map<String, dynamic> player) {
    final isSelected = player == selectedPlayer1 || player == selectedPlayer2;
    return ListTile(
      title: Text(player['name']),
      tileColor: isSelected ? Colors.green[700] : null,
      onTap: () {
        setState(() {
          if (selectedPlayer1 == null || selectedPlayer1 == player) {
            selectedPlayer1 = selectedPlayer1 == player ? null : player;
          } else if (selectedPlayer2 == null || selectedPlayer2 == player) {
            selectedPlayer2 = selectedPlayer2 == player ? null : player;
          }
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Players')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: players.map(buildPlayerTile).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'New Player Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addPlayer,
                  child: const Text('Add Player'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: (selectedPlayer1 != null && selectedPlayer2 != null) ? startGame : null,
                  child: const Text('Start Game'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
