import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String documentId;

  const CardWidget({super.key, required this.data, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text(data["publisher"] ?? "Sin nombre"),
            subtitle: Text(data["description"] ?? "Sin descripción"),
          ),
          if (data["publishimage"] != null && data["publishimage"] != "")
            Image.network(data["publishimage"]),
          // Aquí puedes agregar más widgets como botones, etc.
        ],
      ),
    );
  }
}
