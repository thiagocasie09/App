import 'package:feedcards/services/firebase_service.dart';
import 'package:flutter/material.dart';

class NewPublishForm extends StatefulWidget {
  @override
  _NewPublishFormState createState() => _NewPublishFormState();
}

class _NewPublishFormState extends State<NewPublishForm> {
  final _formKey = GlobalKey<FormState>();
  String publisher = '';
  String description = '';
  String publishimage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Nueva Publicación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (value) {
                  publisher = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) {
                  description = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'URL de la Imagen'),
                onSaved: (value) {
                  publishimage = value ?? '';
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Map<String, dynamic> newPublish = {
                      'publisher': publisher,
                      'description': description,
                      'publishimage': publishimage,
                    };
                    addPublish(
                        newPublish); // Llamamos a la función para guardar en Firestore
                    Navigator.pop(context); // Volver atrás tras guardar
                  }
                },
                child: Text('Guardar Publicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
