import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  ActivitiesScreenState createState() => ActivitiesScreenState();
}

class ActivitiesScreenState extends State<ActivitiesScreen> {
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final snapshot = await FirebaseFirestore.instance.collection('Tasks').get();

    if (snapshot.docs.isEmpty) {
      print("No hay actividades en Firestore.");
    } else {
      print("Actividades cargadas: ${snapshot.docs.length}");
    }

    final loadedActivities = snapshot.docs.map((doc) {
      print("Actividad cargada: ${doc.data()}");
      return Activity.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();

    setState(() {
      activities = loadedActivities;
    });
  }

  Future<void> reloadActivities() async {
    await _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildActivityList()),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Dismissible(
            key: Key(activity.id),
            onDismissed: (direction) {
              _deleteActivity(activity.id);
              setState(() {
                activities.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Actividad eliminada')),
              );
            },
            background: Container(color: Colors.red),
            child: ListTile(
              title: Text('${activity.subject} - ${activity.description}'),
              leading: Checkbox(
                value: activity.isCompleted,
                onChanged: (bool? value) {
                  setState(() {
                    activity.isCompleted = value ?? false;
                    _updateActivityStatus(activity.id, value ?? false);
                  });
                },
              ),
              onTap: () => _editActivity(index),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateActivityStatus(String id, bool isCompleted) async {
    await FirebaseFirestore.instance.collection('Tasks').doc(id).update({
      'status': isCompleted ? 'Completada' : 'Pendiente',
    });
  }

  Future<void> _deleteActivity(String id) async {
    await FirebaseFirestore.instance.collection('Tasks').doc(id).delete();
  }

  Future<void> _updateActivityName(String id, String newSubject) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(id).update({
        'subject':
            newSubject, // Actualiza el campo "subject" con el nuevo valor
      });
      print('Actividad actualizada correctamente');
    } catch (e) {
      print('Error al actualizar la actividad: $e');
    }
  }

  void _editActivity(int index) async {
    final activity = activities[index];
    final newName =
        await _showEditDialog(activity.subject, activity.description);
    if (newName != null) {
      setState(() {
        activity.subject = newName;
      });
      _updateActivityName(activity.id, newName);
    }
  }

  Future<String?> _showEditDialog(
      String existingName, String existingDescription) {
    String newName = existingName;
    String newDescription = existingDescription;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Actividad'),
          content: Column(
            children: [
              TextField(
                controller: TextEditingController(text: existingName),
                onChanged: (value) {
                  newName = value;
                },
                decoration: InputDecoration(hintText: 'Nombre de la materia'),
              ),
              TextField(
                controller: TextEditingController(text: existingDescription),
                onChanged: (value) {
                  newDescription = value;
                },
                decoration: InputDecoration(hintText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(newName);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
