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

  /// Delete player from Supabase and refresh list
  Future<void> deletePlayer(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Player'),
        content: const Text('Are you sure you want to delete this player?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await supabase.from('players').delete().eq('id', id);
      fetchPlayers();
      setState(() {
        if (selectedPlayer1?['id'] == id) selectedPlayer1 = null;
        if (selectedPlayer2?['id'] == id) selectedPlayer2 = null;
      });
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
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: () => deletePlayer(player['id']),
        tooltip: 'Delete Player',
      ),
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
}
