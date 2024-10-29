import 'package:flutter/material.dart';

class Titlecard extends StatelessWidget {
  const Titlecard({super.key, required this.name});

  final String name;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 76, 161, 241),
          child: Text("S&P"),
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color.fromARGB(255, 21, 21, 21),
          ),
        )
      ],
    );
  }
}
