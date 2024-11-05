// NewTaskScreen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTaskScreen extends StatefulWidget {
  final DateTime selectedDate;

  const NewTaskScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _NewTaskScreenState createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  String selectedSubject = '';
  String taskDescription = '';
  DateTime? selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Materia"),
              onChanged: (value) => setState(() {
                selectedSubject = value;
              }),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Descripción"),
              onChanged: (value) => setState(() {
                taskDescription = value;
              }),
            ),
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
