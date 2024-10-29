import 'package:flutter/material.dart';

// ignore: camel_case_types
class imagecard extends StatelessWidget {
  const imagecard({super.key, required this.imagen});

  final String imagen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Image.network(
        imagen,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
