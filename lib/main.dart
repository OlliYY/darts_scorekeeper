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
      theme: ThemeData(primarySwatch: Colors.green),
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

  /// Updates the score of the selected player, ensuring the score does not go negative.
  /// If the player reaches exactly 0 with a double, they win the game.
  void updateScore(int player, int score) {
    setState(() {
      if (player == 1) {
        if (player1Score - score >= 0) {
          if (isWinningThrow(1, score)) {
            showWinnerDialog("Player 1");
          } else {
            player1Score -= score;
          }
        }
      } else {
        if (player2Score - score >= 0) {
          if (isWinningThrow(2, score)) {
            showWinnerDialog("Player 2");
          } else {
            player2Score -= score;
          }
        }
      }
    });
  }

  /// Checks if the player wins with the given score.
  /// The player must reach exactly 0 and the score must be a double (even number).
  bool isWinningThrow(int player, int score) {
    if (player == 1) {
      return (player1Score - score == 0 && score % 2 == 0);
    } else {
      return (player2Score - score == 0 && score % 2 == 0);
    }
  }

  /// Displays a dialog box announcing the winner and resets the game.
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

  /// Resets the game by restoring the initial scores.
  void resetGame() {
    setState(() {
      player1Score = 501;
      player2Score = 501;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Darts Scorekeeper')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlayerScore(name: 'Player 1', score: player1Score),
          PlayerScore(name: 'Player 2', score: player2Score),
          SizedBox(height: 20),
          NumberPad(onScoreEntered: updateScore),
        ],
      ),
    );
  }
}

/// A widget that displays a player's name and current score.
class PlayerScore extends StatelessWidget {
  final String name;
  final int score;

  PlayerScore({required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListTile(
        title: Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        trailing: Text(score.toString(), style: TextStyle(fontSize: 30)),
      ),
    );
  }
}

/// A numeric keypad that allows players to enter their score.
/// Each button represents a possible score reduction.
class NumberPad extends StatelessWidget {
  final Function(int, int) onScoreEntered;

  NumberPad({required this.onScoreEntered});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        int score = (index + 1) * 10;
        return ElevatedButton(
          onPressed: () => onScoreEntered(1, score), // For now, assigns score to Player 1
          child: Text(score.toString(), style: TextStyle(fontSize: 20)),
        );
      },
    );
  }
}
