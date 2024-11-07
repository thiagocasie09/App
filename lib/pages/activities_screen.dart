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
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    loadActivities();
    _loadSubjects();
  }

  void loadActivities() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Activities').get();

    final loadedActivities = snapshot.docs.map((doc) {
      return Activity.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();

    setState(() {
      activities = loadedActivities;
    });
  }

  Future<void> _loadSubjects() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Subjects').get();

    final loadedSubjects = snapshot.docs.map((doc) {
      return doc['name'] as String;
    }).toList();

    setState(() {
      subjects = loadedSubjects;
    });
  }

  // Eliminar materia de Firestore
  Future<void> _deleteSubject(String subject) async {
    try {
      final subjectDoc = await FirebaseFirestore.instance
          .collection('Subjects')
          .where('name', isEqualTo: subject)
          .get();
      if (subjectDoc.docs.isNotEmpty) {
        await subjectDoc.docs.first.reference.delete();
        setState(() {
          subjects.remove(subject);
        });
      }
    } catch (e) {
      print("Error al eliminar la materia: $e");
    }
  }

  // Eliminar actividad de Firestore
  Future<void> _deleteActivity(String activityId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Activities')
          .doc(activityId)
          .delete();
      setState(() {
        activities.removeWhere((activity) => activity.id == activityId);
      });
    } catch (e) {
      print("Error al eliminar la actividad: $e");
    }
  }

  void _toggleActivityCompletion(Activity activity) async {
    try {
      final activityRef =
          FirebaseFirestore.instance.collection('Activities').doc(activity.id);
      await activityRef.update({
        'isCompleted': !activity.isCompleted,
      });
      setState(() {
        activity.isCompleted = !activity.isCompleted;
      });
    } catch (e) {
      print("Error al actualizar la actividad: $e");
    }
  }

  // Crear una nueva materia
  void _createSubject(BuildContext context) async {
    String subjectName = '';

    final subject = await _showCreateSubjectDialog(context);
    if (subject != null) {
      await FirebaseFirestore.instance.collection('Subjects').add({
        'name': subject['name'],
      });
      _loadSubjects();
    }
  }

  Future<Map<String, String>?> _showCreateSubjectDialog(
      BuildContext context) async {
    String subjectName = '';

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Crear Nueva Materia'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Nombre de la materia'),
            onChanged: (value) {
              subjectName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'name': subjectName,
                });
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildSubjectList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        heroTag: 'activities_fab', // Cambiado para que sea único
        onPressed: () => _createSubject(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Widget _buildSubjectList() {
    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final subjectActivities = activities
            .where((activity) => activity.subject == subject)
            .toList();
        final completionPercentage =
            _getCompletionPercentage(subjectActivities);

        return Dismissible(
          key: Key(subject),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _deleteSubject(subject);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Materia eliminada")));
          },
          background: Container(color: Colors.red),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 5,
            child: ListTile(
              title: Text(subject),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: completionPercentage,
                    backgroundColor: Colors.grey[200],
                    color: Colors.pink,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${(completionPercentage * 100).toStringAsFixed(0)}% completado',
                    style: TextStyle(fontSize: 12, color: Colors.pinkAccent),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              onTap: () => _navigateToActivities(subjectActivities),
            ),
          ),
        );
      },
    );
  }

  double _getCompletionPercentage(List<Activity> activities) {
    int completedCount =
        activities.where((activity) => activity.isCompleted).length;
    return activities.isEmpty ? 0 : completedCount / activities.length;
  }

  void _navigateToActivities(List<Activity> activities) {
    if (activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No hay actividades disponibles para esta materia")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityListScreen(activities: activities),
      ),
    );
  }

  ActivityListScreen({required List<Activity> activities}) {}
}
