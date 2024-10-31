// Importa el paquete Flutter para los widgets básicos de la interfaz de usuario
import 'package:flutter/material.dart';

// Importa `cloud_firestore` para interactuar con la base de datos Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

// Define el widget `NewTaskScreen` como un `StatefulWidget` para gestionar el estado de una nueva tarea
class NewTaskScreen extends StatefulWidget {
  // Variable que contiene la fecha seleccionada para la nueva tarea
  final DateTime selectedDate;

  // Constructor de `NewTaskScreen` que recibe la fecha seleccionada como parámetro obligatorio
  const NewTaskScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _NewTaskScreenState createState() => _NewTaskScreenState();
}

// Clase privada `_NewTaskScreenState` que contiene el estado de `NewTaskScreen`
class _NewTaskScreenState extends State<NewTaskScreen> {
  // Variable para almacenar la materia seleccionada
  String? selectedSubject;

  // Variable para almacenar la descripción de la tarea
  String taskDescription = '';

  // Método `build` que define la interfaz de usuario del widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Nueva Tarea"), // Título de la pantalla
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Espacio alrededor del contenido
        child: Column(
          children: [
            // `FutureBuilder` para cargar las materias desde Firebase Firestore
            FutureBuilder<QuerySnapshot>(
              // Solicita la colección 'Subjects' de Firebase
              future: FirebaseFirestore.instance.collection('Subjects').get(),
              builder: (context, snapshot) {
                // Muestra un indicador de carga si los datos aún no están disponibles
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                // Obtiene una lista de nombres de materias desde los documentos de Firestore
                final subjects =
                    snapshot.data!.docs.map((doc) => doc['name']).toList();

                // Dropdown para seleccionar una materia
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      labelText: "Materia"), // Etiqueta del dropdown
                  items: subjects.map((subject) {
                    // Itera sobre las materias y crea los items del dropdown
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject), // Muestra el nombre de cada materia
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    selectedSubject =
                        value; // Actualiza la materia seleccionada
                  }),
                );
              },
            ),
            // Campo de texto para ingresar la descripción de la tarea
            TextField(
              decoration: InputDecoration(
                  labelText: "Descripción de la Tarea"), // Etiqueta del campo
              onChanged: (value) => setState(() {
                taskDescription = value; // Actualiza la descripción de la tarea
              }),
            ),
            SizedBox(height: 20), // Espacio entre el campo de texto y el botón

            // Botón para guardar la tarea en Firebase
            ElevatedButton(
              onPressed: () async {
                // Verifica que se haya seleccionado una materia y que la descripción no esté vacía
                if (selectedSubject != null && taskDescription.isNotEmpty) {
                  // Agrega la nueva tarea a la colección 'Tasks' en Firebase
                  await FirebaseFirestore.instance.collection('Tasks').add({
                    'date': Timestamp.fromDate(
                        widget.selectedDate), // Fecha de la tarea
                    'subject': selectedSubject, // Materia de la tarea
                    'description': taskDescription, // Descripción de la tarea
                    'status': 'Pendiente' // Estado inicial de la tarea
                  });
                  Navigator.pop(context,
                      true); // Cierra la pantalla y retorna `true` para indicar que se creó una tarea
                }
              },
              child: Text("Guardar Tarea"), // Texto del botón
            ),
          ],
        ),
      ),
    );
  }
}
