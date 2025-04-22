import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import '../supabase_config.dart';
import '../widgets/player_score.dart';
import '../widgets/throw_display.dart';
import '../widgets/number_pad.dart';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> player1;
  final Map<String, dynamic> player2;

  const GameScreen({super.key, required this.player1, required this.player2});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int player1Score = 501;
  int player2Score = 501;
  int currentPlayer = 1;
  List<int> currentThrows = [0, 0, 0];
  int throwIndex = 0;
  String multiplier = '';

  int lastPlayer1Turn = 0;
  int lastPlayer2Turn = 0;

  final SupabaseClient supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  void enterScore(int score) {
    int calculatedScore = score;
    bool isDouble = false;

    if (multiplier == 'Double') {
      calculatedScore *= 2;
      isDouble = true;
    } else if (multiplier == 'Triple') {
      calculatedScore *= 3;
    }
    multiplier = '';

    int currentScore = currentPlayer == 1 ? player1Score : player2Score;
    int remaining = currentScore - calculatedScore;

    // Invalid win attempt (zero without double) or overshoot
    if (remaining < 0 || (remaining == 0 && !isDouble)) {
      setState(() {
        switchPlayer();
      });
      return;
    }

    // Valid win
    if (remaining == 0 && isDouble) {
  if (currentPlayer == 1) {
    player1Score = 0;
  } else {
    player2Score = 0;
  }

  updateWinsAndShowDialog(
    currentPlayer == 1 ? widget.player1['id'] : widget.player2['id'],
    currentPlayer == 1 ? widget.player1['name'] : widget.player2['name'],
  );
  return;
}


    // Normal scoring
    setState(() {
      if (currentPlayer == 1) {
        player1Score = remaining;
      } else {
        player2Score = remaining;
      }

      currentThrows[throwIndex] = calculatedScore;
      throwIndex++;

      if (throwIndex == 3) {
        if (currentPlayer == 1) {
          lastPlayer1Turn = currentThrows.reduce((a, b) => a + b);
        } else {
          lastPlayer2Turn = currentThrows.reduce((a, b) => a + b);
        }
        switchPlayer();
      }
    });
  }

  void switchPlayer() {
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    currentThrows = [0, 0, 0];
    throwIndex = 0;
  }

  void updateWinsAndShowDialog(int playerId, String playerName) async {
    try {
      await supabase
          .from('players')
          .update({
            'wins': ((currentPlayer == 1 ? widget.player1['wins'] : widget.player2['wins']) ?? 0) + 1
          })
          .eq('id', playerId);
    } catch (e) {
      print('Error updating wins: $e');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("$playerName wins!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      player1Score = 501;
      player2Score = 501;
      currentPlayer = 1;
      currentThrows = [0, 0, 0];
      throwIndex = 0;
      multiplier = '';
      lastPlayer1Turn = 0;
      lastPlayer2Turn = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Darts Scorekeeper')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PlayerScore(
              name: widget.player1['name'],
              score: player1Score,
              lastTurn: lastPlayer1Turn,
              isCurrent: currentPlayer == 1,
            ),
            PlayerScore(
              name: widget.player2['name'],
              score: player2Score,
              lastTurn: lastPlayer2Turn,
              isCurrent: currentPlayer == 2,
            ),
            const SizedBox(height: 20),
            ThrowDisplay(throws: currentThrows),
            const SizedBox(height: 20),
            NumberPad(
              onScoreEntered: enterScore,
              onMultiplierSelected: (String value) {
                setState(() {
                  multiplier = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}