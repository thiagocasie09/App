import 'package:flutter/material.dart';

class BottomCard extends StatelessWidget {
  const BottomCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
        IconButton(icon: Icon(Icons.comment), onPressed: () {}),
      ],
    );
  }
}
