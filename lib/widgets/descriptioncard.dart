import 'package:flutter/material.dart';

class descriptioncard extends StatelessWidget {
  const descriptioncard({super.key, required this.description});

  final String description;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Text(
        description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
