import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  const TitleText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: const Color.fromARGB(255, 15, 42, 28),
        fontSize: 60,
        fontWeight: FontWeight.bold,
        fontFamily: "Yellowtail"
      ),
    );
  }
}