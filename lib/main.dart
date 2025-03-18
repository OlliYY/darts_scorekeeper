import 'package:flutter/material.dart';

void main() {
  runApp(DartsScorekeeperApp());
}

class DartsScorekeeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Darts Scorekeeper',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
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
      if (player1Score - totalScore == 0) {
        showWinnerDialog('Player 1');
      } else if (player1Score - totalScore > 0) {
        player1Score -= totalScore;
      }
    } else {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Darts Scorekeeper')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            PlayerScore(name: 'Player 1', score: player1Score, isCurrent: currentPlayer == 1),
            PlayerScore(name: 'Player 2', score: player2Score, isCurrent: currentPlayer == 2),
            SizedBox(height: 20),
            ThrowDisplay(throws: currentThrows), // Fixed missing ThrowDisplay
            SizedBox(height: 20),
            NumberPad(onScoreEntered: enterScore, onMultiplierSelected: (String value) {
              setState(() {
                multiplier = value;
              });
            }),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays the player's name and current score.
class PlayerScore extends StatelessWidget {
  final String name;
  final int score;
  final bool isCurrent;

  PlayerScore({required this.name, required this.score, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      color: isCurrent ? Colors.green[800] : Colors.grey[850], // Highlight current player
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              score.toString(),
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that displays the three most recent dart throws.
class ThrowDisplay extends StatelessWidget {
  final List<int> throws;

  ThrowDisplay({required this.throws});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: throws.map((throwScore) {
        return Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            throwScore.toString(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }).toList(),
    );
  }
}
