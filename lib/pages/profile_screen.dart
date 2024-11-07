import 'package:flutter/material.dart';
import 'package:modernlogintute/widgets/listcard.dart';
import 'package:modernlogintute/pages/NewPublishForm.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Publicaciones"),
      ),
      body: const ListCard(),
      floatingActionButton: FloatingActionButton(
        mini: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewPublishForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white, // Icono de "agregar"
      ),
    );
  }
}
