import 'package:modernlogintute/widgets/listcard.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/NewPublishForm.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Santiago'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: const ListCard(),
      backgroundColor: Colors.pink[300],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewPublishForm()), // Abrir el formulario
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
