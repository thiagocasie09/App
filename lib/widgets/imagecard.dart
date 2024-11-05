import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String image;

  const ImageCard({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: image.isNotEmpty
          ? Image.network(image)
          : const SizedBox.shrink(), // Si no hay imagen, no se muestra nada
    );
  }
}
