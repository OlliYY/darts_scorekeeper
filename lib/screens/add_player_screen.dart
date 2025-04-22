import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import '../supabase_config.dart'; // tarvitaan URL ja avain


/// A screen for adding a new player to the Supabase database.
class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final TextEditingController _nameController = TextEditingController();
  
   // Manually create the Supabase client
  final SupabaseClient supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);


  /// Sends a new player to the Supabase 'players' table
  Future<void> _addPlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      await supabase.from('players').insert({'name': name});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Player "$name" added!')),
      );
      Navigator.pop(context); // return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding player: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Player')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPlayer,
              child: const Text('Add Player'),
            ),
          ],
        ),
      ),
    );
  }
}
