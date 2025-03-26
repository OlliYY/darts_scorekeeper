import 'package:flutter/material.dart';

/// A numeric keypad for score entry, including multipliers and Miss button.
class NumberPad extends StatelessWidget {
  final Function(int) onScoreEntered;
  final Function(String) onMultiplierSelected;

  // Numbers 1–20 + 25 + Miss (0)
  final List<int> scores = List.generate(20, (index) => index + 1) + [25, 0];

  NumberPad({
    super.key,
    required this.onScoreEntered,
    required this.onMultiplierSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => onMultiplierSelected("Double"),
              child: const Text("Double", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => onMultiplierSelected("Triple"),
              child: const Text("Triple", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.5,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: scores.length,
          itemBuilder: (context, index) {
            int score = scores[index];
            bool isMiss = score == 0;

            return ElevatedButton(
              onPressed: () => onScoreEntered(score),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: isMiss ? Colors.redAccent : Colors.green[700],
              ),
              child: Text(
                isMiss ? 'Miss' : score.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ],
    );
  }
}
