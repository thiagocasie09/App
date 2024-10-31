import 'package:modernlogintute/pages/NewPublishForm.dart';
import 'package:flutter/material.dart';

class Titlecard extends StatelessWidget {
  const Titlecard({super.key, required this.name, required this.documentId});

  final String name;
  final String documentId; // El ID de la publicación

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .spaceBetween, // Asegura que el icono esté a la derecha
      children: [
        CircleAvatar(
          // Obtiene la primera letra del nombre y la muestra en el CircleAvatar
          child: Text(
            name.isNotEmpty
                ? name[0].toUpperCase()
                : '', // Toma la primera letra y la convierte a mayúscula
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor:
              Colors.pink, // Puedes cambiar el color de fondo si lo deseas
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 22, 22, 22),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPublishForm(
                  documentId:
                      documentId, // Pasa el ID de la publicación a editar
                ),
              ),
            );
          },
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.edit, color: Colors.black),
          ),
        )
      ],
    );
  }
}
