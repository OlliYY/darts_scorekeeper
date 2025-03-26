import 'package:flutter/material.dart';

/// A widget that displays the player's name, current score and last turn total.
class PlayerScore extends StatelessWidget {
  final String name;
  final int score;
  final int lastTurn;
  final bool isCurrent;

  const PlayerScore({
    super.key,
    required this.name,
    required this.score,
    required this.lastTurn,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      color: isCurrent ? Colors.green[800] : Colors.grey[850], // Highlight current player
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$name (Last: $lastTurn)', // Show last turn result
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              score.toString(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
          ],
        ),
      ),
    );
  }
}
