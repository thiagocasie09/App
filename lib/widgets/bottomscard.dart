import 'package:modernlogintute/widgets/guardar.dart';
import 'package:modernlogintute/widgets/likebuttom.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class bottomscard extends StatelessWidget {
  const bottomscard({
    super.key,
    //required this.textStyle,
  });

  //final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
        color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const LikeButton(),
        TextButton(
            onPressed: () {},
            child: const Text(
              "Comentar",
              style: textStyle,
            )),
        TextButton(
            onPressed: () {},
            child: const Text(
              "Compartir",
              style: textStyle,
            )),
        const Guardar(),
      ],
    );
  }
}
