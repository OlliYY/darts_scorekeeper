import 'package:flutter/material.dart';
import '../widgets/player_score.dart';
import '../widgets/throw_display.dart';
import '../widgets/number_pad.dart';

/// The main game screen containing score, throw display and input buttons.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
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
  void showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("$winner wins!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text("OK"),
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
      appBar: AppBar(title: const Text('Darts Scorekeeper')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PlayerScore(
              name: 'Player 1',
              score: player1Score,
              lastTurn: lastPlayer1Turn,
              isCurrent: currentPlayer == 1,
            ),
            PlayerScore(
              name: 'Player 2',
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
