import 'package:flutter/material.dart';

/// A widget that displays the three most recent dart throws.
class ThrowDisplay extends StatelessWidget {
  final List<int> throws;

  const ThrowDisplay({super.key, required this.throws});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: throws.map((throwScore) {
        return Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            throwScore.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }).toList(),
    );
  }
}
