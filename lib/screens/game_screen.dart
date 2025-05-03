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

  // Called when a score button is pressed
  void enterScore(int score) {
    // Prevent scoring after the game is already won
    if (player1Score == 0 || player2Score == 0) {
      print("Game already ended — ignoring further input.");
      return;
    }

    int calculatedScore = score;
    bool isDouble = false;

    //Apply multiplier
    if (multiplier == 'Double') {
      calculatedScore *= 2;
      isDouble = true;
    } else if (multiplier == 'Triple') {
      calculatedScore *= 3;
    }

    print("Raw input score: $score");
    print("Calculated score after multiplier: $calculatedScore");
    print("Multiplier was double: $isDouble");

    multiplier = ''; // Resets multiplier after use

    int currentScore = currentPlayer == 1 ? player1Score : player2Score;
    int remaining = currentScore - calculatedScore;

    print("Current Score: $currentScore");
    print("Remaining Score After Throw: $remaining");

    //Check for win: SCore must be exactly 0 and last throw must be a double multiplier
    if (remaining == 0 && isDouble) {
      print("Valid win detected for player $currentPlayer.");

      setState(() {
        if (currentPlayer == 1) {
          player1Score = 0;
        } else {
          player2Score = 0;
        }
      });

      final winnerId = (currentPlayer == 1
          ? widget.player1['id'] as String
          : widget.player2['id'] as String);

      final winnerName = (currentPlayer == 1
          ? widget.player1['name'] as String
          : widget.player2['name'] as String);

      final winnerWins = (currentPlayer == 1
          ? widget.player1['wins'] as int? ?? 0
          : widget.player2['wins'] as int? ?? 0);

      updateWinsAndShowDialog(winnerId, winnerName, winnerWins + 1);
      return;
    }

    // If overshootinf or reaching 0 without double - invalid throw
    if (remaining < 0 || (remaining == 0 && !isDouble)) {
      print("Invalid win attempt or overshoot.");
      setState(() {
        switchPlayer();
      });
      return;
    }

    // Apply score normally
    print("Score valid, applying it.");

    setState(() {
      if (currentPlayer == 1) {
        player1Score = remaining;
      } else {
        player2Score = remaining;
      }

      if (throwIndex < 3) {
        currentThrows[throwIndex] = calculatedScore;
        throwIndex++;
      }

      //  End turn after 3 throws
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

  // Switches to the other players turn
  void switchPlayer() {
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    currentThrows = [0, 0, 0];
    throwIndex = 0;
  }

  // Updates the win count in the supabase database and shows dialog
  void updateWinsAndShowDialog(String playerId, String playerName, int newWins) async {
    try {
      await supabase.from('players').update({'wins': newWins}).eq('id', playerId);
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

  // Resers the game state
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
