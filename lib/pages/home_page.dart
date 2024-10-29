import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/widgets/listcard.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/NewPublishForm.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Santiago'),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
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
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
    );
  }
}
