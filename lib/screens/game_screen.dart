import 'package:flutter/material.dart';
import '../widgets/player_score.dart';
import '../widgets/throw_display.dart';
import '../widgets/number_pad.dart';
import 'add_player_screen.dart';
import 'package:supabase/supabase.dart';
import '../supabase_config.dart';



/// The main game screen containing score, throw display and input buttons.
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


  /// Handles score input based on the selected number and applies the multiplier if active.
  void enterScore(int score) {
    setState(() {
      int calculatedScore = score;

      // Apply multiplier if selected
      if (multiplier == 'Double') {
        calculatedScore = score * 2;
      } else if (multiplier == 'Triple') {
        calculatedScore = score * 3;
      }

      // Store the throw in the current throw list
      currentThrows[throwIndex] = calculatedScore;
      throwIndex++;
      multiplier = ''; // Reset multiplier after use

      // Switch turn after three throws
      if (throwIndex == 3) {
        finalizeTurn();
      }
    });
  }

  /// Finalizes the turn by calculating total points and switching players.
  void finalizeTurn() {
    int totalScore = currentThrows.reduce((a, b) => a + b);

    if (currentPlayer == 1) {
      lastPlayer1Turn = totalScore;
      if (player1Score - totalScore == 0) {
        showWinnerDialog('Player 1');
      } else if (player1Score - totalScore > 0) {
        player1Score -= totalScore;
      }
    } else {
      lastPlayer2Turn = totalScore;
      if (player2Score - totalScore == 0) {
        showWinnerDialog('Player 2');
      } else if (player2Score - totalScore > 0) {
        player2Score -= totalScore;
      }
    }

    switchPlayer();
  }

  /// Switches turn to the next player and resets throw data.
  void switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
      currentThrows = [0, 0, 0];
      throwIndex = 0;
    });
  }

  /// Displays a dialog announcing the winner and resets the game.
void showWinnerDialog(String winnerName) async {
  final winnerId = (winnerName == widget.player1['name'])
      ? widget.player1['id']
      : widget.player2['id'];

  final winner = widget.player1['id'] == winnerId ? widget.player1 : widget.player2;

  try {
    await supabase
        .from('players')
        .update({'wins': (winner['wins'] ?? 0) + 1})
        .eq('id', winnerId);
  } catch (e) {
    print('Error updating wins: $e');
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Game Over"),
        content: Text("$winnerName wins!"),
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



  /// Resets the game to the initial state.
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
      appBar: AppBar(
      title: const Text('Darts Scorekeeper'),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add),
          tooltip: 'Add Player',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPlayerScreen()),
      );
    },
  ),
],
),
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
