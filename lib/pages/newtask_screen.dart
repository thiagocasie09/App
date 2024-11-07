import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTaskScreen extends StatefulWidget {
  final DateTime selectedDate;

  const NewTaskScreen(
      {Key? key, required this.selectedDate, required List<String> subjects})
      : super(key: key);

  @override
  _NewTaskScreenState createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  String selectedSubject = ''; // Materia seleccionada
  String taskDescription = ''; // Descripción de la tarea
  DateTime? selectedDate; // Fecha de entrega de la tarea
  bool isLoading = false;
  List<String> subjects = []; // Lista de materias disponibles

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    _loadSubjects();
  }

  // Cargar las materias desde Firestore
  Future<void> _loadSubjects() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Subjects').get();

    if (snapshot.docs.isEmpty) {
      print("No hay materias en Firestore.");
      setState(() {
        subjects = [];
        selectedSubject = ''; // Evitamos que selectedSubject sea null
      });
    } else {
      final loadedSubjects = snapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      setState(() {
        subjects = loadedSubjects;
        // Si hay materias, se asigna la primera materia seleccionada por defecto.
        selectedSubject = subjects.isNotEmpty ? subjects[0] : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Verifica si la lista de materias está vacía y muestra un indicador de carga si es necesario
            if (subjects.isEmpty)
              const CircularProgressIndicator() // Mientras se cargan las materias, se muestra un cargando.
            else
              DropdownButton<String>(
                value: selectedSubject.isEmpty
                    ? null
                    : selectedSubject, // Aseguramos que nunca sea null.
                hint: Text(subjects.isEmpty
                    ? 'No hay materias disponibles'
                    : 'Selecciona una Materia'),
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value!; // Garantizamos que no sea null
                  });
                },
                items: subjects.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: "Descripción"),
              onChanged: (value) => setState(() {
                taskDescription = value;
              }),
            ),
            const SizedBox(height: 16),
            // Selector de fecha
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Fecha de Entrega",
                hintText: selectedDate == null
                    ? "Selecciona una fecha"
                    : "${selectedDate!.toLocal()}".split(' ')[0],
              ),
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (selectedSubject.isNotEmpty &&
                          taskDescription.isNotEmpty &&
                          selectedDate != null) {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          await FirebaseFirestore.instance
                              .collection('Tasks')
                              .add({
                            'date': Timestamp.fromDate(selectedDate!),
                            'subject': selectedSubject,
                            'description': taskDescription,
                            'status': 'Pendiente',
                          });
                          Navigator.pop(context, true);
                        } catch (e) {
                          print("Error al guardar la tarea: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Error al guardar la tarea")),
                          );
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Completa todos los campos")),
                        );
                      }
                    },
                    child: const Text("Guardar Tarea"),
                  ),
          ],
        ),
      ),
    );
  }
}
