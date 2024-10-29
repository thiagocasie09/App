import 'package:modernlogintute/widgets/bottomscard.dart';
import 'package:modernlogintute/widgets/descriptioncard.dart';
import 'package:modernlogintute/widgets/imagecard.dart';
import 'package:modernlogintute/widgets/titlecard.dart';
import 'package:flutter/material.dart';

class card extends StatelessWidget {
  const card({super.key, required this.data});

  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      width: double.infinity,
      height: 450,
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 255, 251, 251)),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
            ),
            Titlecard(name: data["name"]!),
            descriptioncard(description: data["description"]!),
            imagecard(imagen: data["imagen"]!),
            const bottomscard(),
          ],
        ),
      ),
    );
  }
}
